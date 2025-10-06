import Foundation
import MultipeerConnectivity
import CryptoKit

/// Service handling peer discovery, connection, and encrypted communication via MultipeerConnectivity
class PeerService: NSObject, ObservableObject {

    // MARK: - Published Properties

    @Published var discoveredPeers: [MCPeerID] = []
    @Published var connectedPeers: [MCPeerID] = []
    @Published var receivedMessages: [Message] = []
    @Published var connectionState: ConnectionState = .disconnected

    // MARK: - MultipeerConnectivity Properties

    private let serviceType = "neardrop"
    private var peerID: MCPeerID
    private var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser
    private var browser: MCNearbyServiceBrowser

    // MARK: - Crypto Properties

    private var identityKeys: CryptoKitWrapper.IdentityKeys
    private var sessionKeys: CryptoKitWrapper.SessionKeys
    private var peerSharedSecrets: [MCPeerID: SymmetricKey] = [:]
    private var peerPublicKeys: [MCPeerID: Data] = [:]

    // MARK: - Initialization

    override init() {
        // Generate identity and session keys
        self.identityKeys = CryptoKitWrapper.generateIdentityKeys()
        self.sessionKeys = CryptoKitWrapper.generateSessionKeys()

        // Create peer ID with device name
        let deviceName = UIDevice.current.name
        self.peerID = MCPeerID(displayName: deviceName)

        // Create session
        self.session = MCSession(
            peer: peerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )

        // Create advertiser and browser
        self.advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: ["publicKey": identityKeys.publicKeyData.base64EncodedString()],
            serviceType: serviceType
        )

        self.browser = MCNearbyServiceBrowser(
            peer: peerID,
            serviceType: serviceType
        )

        super.init()

        // Set delegates
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
    }

    // MARK: - Public Methods

    /// Start advertising and browsing for peers
    func startDiscovery() {
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
        connectionState = .discovering
    }

    /// Stop advertising and browsing
    func stopDiscovery() {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        connectionState = .disconnected
    }

    /// Invite a peer to connect
    func invitePeer(_ peerID: MCPeerID) {
        // Send our session public key in invitation context
        let context = sessionKeys.publicKeyData
        browser.invitePeer(peerID, to: session, withContext: context, timeout: 30)
    }

    /// Send encrypted message to a peer
    func sendMessage(_ text: String, to peerID: MCPeerID) throws {
        guard let sharedSecret = peerSharedSecrets[peerID] else {
            throw PeerServiceError.noSharedSecret
        }

        let message = Message(
            id: UUID(),
            text: text,
            sender: self.peerID.displayName,
            timestamp: Date(),
            isEncrypted: true
        )

        let encoder = JSONEncoder()
        let messageData = try encoder.encode(message)

        // Encrypt the message
        let encryptedData = try CryptoKitWrapper.encrypt(data: messageData, using: sharedSecret)

        // Send to peer
        try session.send(encryptedData, toPeers: [peerID], with: .reliable)
    }

    /// Get safety code for verification with a peer
    func getSafetyCode(for peerID: MCPeerID) -> String? {
        guard let remotePubKey = peerPublicKeys[peerID] else {
            return nil
        }

        return CryptoKitWrapper.generateSafetyCode(
            localPublicKey: identityKeys.publicKeyData,
            remotePublicKey: remotePubKey
        )
    }

    /// Disconnect from all peers
    func disconnect() {
        session.disconnect()
        connectedPeers.removeAll()
        peerSharedSecrets.removeAll()
        peerPublicKeys.removeAll()
        connectionState = .disconnected
    }

    // MARK: - Private Methods

    private func establishSharedSecret(with peerID: MCPeerID, peerSessionPublicKey: Data) throws {
        // Convert peer's public key data to Curve25519 key
        let peerPublicKey = try Curve25519.KeyAgreement.PublicKey(rawRepresentation: peerSessionPublicKey)

        // Derive shared secret
        let sharedSecret = try CryptoKitWrapper.deriveSharedSecret(
            privateKey: sessionKeys.privateKey,
            publicKey: peerPublicKey
        )

        peerSharedSecrets[peerID] = sharedSecret
    }
}

// MARK: - MCSessionDelegate

extension PeerService: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
                self.connectionState = .connected
                print("✅ Connected to: \(peerID.displayName)")

            case .connecting:
                self.connectionState = .connecting
                print("🔄 Connecting to: \(peerID.displayName)")

            case .notConnected:
                self.connectedPeers.removeAll { $0 == peerID }
                self.peerSharedSecrets.removeValue(forKey: peerID)
                self.peerPublicKeys.removeValue(forKey: peerID)
                if self.connectedPeers.isEmpty {
                    self.connectionState = .discovering
                }
                print("❌ Disconnected from: \(peerID.displayName)")

            @unknown default:
                break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Decrypt and process received data
        guard let sharedSecret = peerSharedSecrets[peerID] else {
            print("⚠️ No shared secret for peer: \(peerID.displayName)")
            return
        }

        do {
            let decryptedData = try CryptoKitWrapper.decrypt(data: data, using: sharedSecret)
            let decoder = JSONDecoder()
            let message = try decoder.decode(Message.self, from: decryptedData)

            DispatchQueue.main.async {
                self.receivedMessages.append(message)
            }

            print("📩 Received message from \(peerID.displayName): \(message.text)")
        } catch {
            print("❌ Failed to decrypt message: \(error)")
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Handle incoming streams (for future file transfer)
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Handle incoming resources
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Handle completed resource transfer
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension PeerService: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {

        print("📨 Received invitation from: \(peerID.displayName)")

        // Extract peer's session public key from context
        if let peerSessionPubKey = context {
            do {
                try establishSharedSecret(with: peerID, peerSessionPublicKey: peerSessionPubKey)
                invitationHandler(true, session)
            } catch {
                print("❌ Failed to establish shared secret: \(error)")
                invitationHandler(false, nil)
            }
        } else {
            invitationHandler(false, nil)
        }
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension PeerService: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        DispatchQueue.main.async {
            if !self.discoveredPeers.contains(peerID) && peerID != self.peerID {
                self.discoveredPeers.append(peerID)

                // Store peer's identity public key
                if let pubKeyString = info?["publicKey"],
                   let pubKeyData = Data(base64Encoded: pubKeyString) {
                    self.peerPublicKeys[peerID] = pubKeyData
                }

                print("🔍 Discovered peer: \(peerID.displayName)")
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.discoveredPeers.removeAll { $0 == peerID }
            print("👋 Lost peer: \(peerID.displayName)")
        }
    }
}

// MARK: - Supporting Types

enum ConnectionState {
    case disconnected
    case discovering
    case connecting
    case connected
}

enum PeerServiceError: Error {
    case noSharedSecret
    case encryptionFailed
    case peerNotFound
}
