# NearDrop Architecture

## System Overview

NearDrop is a privacy-focused, encrypted peer-to-peer messaging app built entirely on Apple's native frameworks. It uses MultipeerConnectivity for device discovery and communication, with CryptoKit providing end-to-end encryption.

## Architecture Layers

```
┌─────────────────────────────────────────┐
│         SwiftUI Views Layer             │
│  (DiscoveryView, ChatView, Settings)    │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│        Service Layer (MVVM)             │
│   PeerService | MessageStore            │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│         Core Layer                      │
│   CryptoKitWrapper | Models             │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│      Apple Frameworks                   │
│  MultipeerConnectivity | CryptoKit      │
└─────────────────────────────────────────┘
```

## Core Components

### 1. CryptoKitWrapper

**Purpose**: Abstraction layer over CryptoKit for all cryptographic operations

**Key Responsibilities**:
- Identity key generation (Ed25519)
- Session key generation (X25519)
- Key exchange (ECDH)
- Encryption/Decryption (AES-GCM)
- Signing/Verification (Ed25519)
- Safety code generation

**Key Types**:
```swift
IdentityKeys {
    signingKey: Ed25519 private key
    publicKey: Ed25519 public key
}

SessionKeys {
    privateKey: X25519 private key
    publicKey: X25519 public key
}
```

**Encryption Flow**:
```
1. Generate ephemeral X25519 key pair
2. Exchange public keys with peer
3. Perform ECDH → shared secret
4. Derive AES key via HKDF-SHA256
5. Encrypt message with AES-GCM
6. Decrypt with same derived key
```

### 2. PeerService

**Purpose**: Manages all MultipeerConnectivity operations and peer state

**Key Responsibilities**:
- Device discovery (advertising + browsing)
- Connection management
- Encrypted message transmission
- Session key exchange
- Shared secret derivation per peer

**State Machine**:
```
Disconnected → Discovering → Connecting → Connected
                     ↓            ↓
                     ← ← ← ← ← ← ←
```

**Connection Protocol**:
```
Device A                          Device B
   |                                 |
   |-- Start Discovery -----------→ |
   |← - - - - - Peer Found - - - - -|
   |                                 |
   |-- Invite (session pubkey) ---→ |
   |← Accept (session pubkey) - - - |
   |                                 |
   |-- Derive Shared Secret ------→ |
   |← - - - - - - - - - - - - - - - |
   |                                 |
   |-- Encrypted Message ----------→|
   |← Encrypted Message - - - - - - |
```

**Data Structures**:
- `discoveredPeers: [MCPeerID]` - Available nearby devices
- `connectedPeers: [MCPeerID]` - Currently connected devices
- `peerSharedSecrets: [MCPeerID: SymmetricKey]` - Per-peer encryption keys
- `peerPublicKeys: [MCPeerID: Data]` - Peer identity keys for verification

### 3. MessageStore

**Purpose**: Manages message persistence and conversation state

**Key Responsibilities**:
- Save/load conversations
- Message history per peer
- Conversation metadata (last message, timestamps)

**Data Model**:
```swift
Message {
    id: UUID
    text: String
    sender: String
    timestamp: Date
    isEncrypted: Bool
}

Conversation {
    id: UUID
    peerName: String
    messages: [Message]
    createdAt: Date
    lastMessageAt: Date
}
```

**Persistence**:
- Currently: UserDefaults (JSON encoding)
- Future: Core Data for better performance and features

### 4. Views (SwiftUI)

#### DiscoveryView
- Start/stop peer discovery
- List discovered devices
- Initiate connections
- Show connection status

#### ChatsListView
- Display active conversations
- Show last message preview
- Navigate to chat view

#### ChatView
- Message bubbles (sent/received)
- Message input field
- Safety code verification
- Real-time message updates

#### SettingsView
- Device information
- Connected peers list
- Security status
- Disconnect option

## Security Model

### Key Hierarchy

```
Device Identity (Long-term)
    ├── Ed25519 Signing Key Pair
    │   ├── Private Key (Keychain)
    │   └── Public Key (Advertised)
    │
Session Keys (Ephemeral per connection)
    ├── X25519 Key Agreement Key Pair
    │   ├── Private Key (Memory)
    │   └── Public Key (Exchanged during invite)
    │
Shared Secret (Per peer)
    └── Derived via ECDH + HKDF
        └── Used for AES-GCM encryption
```

### Cryptographic Operations

**Key Generation**:
```swift
// Identity (long-term)
Ed25519.Signing.PrivateKey()

// Session (ephemeral)
X25519.KeyAgreement.PrivateKey()
```

**Key Exchange**:
```swift
sharedSecret = ECDH(myPrivateKey, theirPublicKey)
aesKey = HKDF-SHA256(sharedSecret)
```

**Message Encryption**:
```swift
encrypted = AES-GCM.encrypt(message, key: aesKey)
// Produces: ciphertext || tag || nonce (combined)
```

**Safety Code**:
```swift
combined = myPublicKey || theirPublicKey
hash = SHA256(combined)
code = formatAsDigits(hash[0..6])
// Format: XXX-XXX-XXX-XXX
```

### Threat Model

**Protects Against**:
✅ Passive eavesdropping (encryption)
✅ Message tampering (AEAD)
✅ Impersonation (identity keys)
✅ MITM (safety codes)

**Does Not Protect Against**:
❌ Device compromise (keys in memory)
❌ Physical surveillance (metadata visible)
❌ Denial of Service (MultipeerConnectivity attacks)
❌ Network-level traffic analysis (packet sizes, timing)

## Data Flow

### Discovery Flow
```
1. User taps "Start Discovery"
2. PeerService.startDiscovery()
3. MCNearbyServiceAdvertiser starts
4. MCNearbyServiceBrowser starts
5. When peer found → add to discoveredPeers
6. Update DiscoveryView UI
```

### Connection Flow
```
1. User taps "Connect" on peer
2. PeerService.invitePeer(peer)
3. Send session public key in invite context
4. Peer accepts, sends their session public key
5. Both sides derive shared secret via ECDH
6. Store in peerSharedSecrets[peer]
7. Connection established
8. Update connectedPeers list
```

### Message Send Flow
```
1. User types message, taps send
2. PeerService.sendMessage(text, to: peer)
3. Create Message object
4. JSON encode message
5. Encrypt with peer's shared secret (AES-GCM)
6. MCSession.send(encrypted, to: peer)
7. Add to local MessageStore
8. Update ChatView
```

### Message Receive Flow
```
1. MCSession receives data from peer
2. PeerService.session(_:didReceive:fromPeer:)
3. Decrypt using peer's shared secret
4. JSON decode to Message
5. Append to receivedMessages
6. MessageStore observes and saves
7. ChatView updates UI
```

## Threading & Concurrency

### Main Thread
- All UI updates (SwiftUI views)
- Published property changes (@Published)
- PeerService state updates

### Background Threads
- MultipeerConnectivity callbacks (dispatched to main)
- Crypto operations (fast enough for main thread)
- File I/O for persistence (UserDefaults handles internally)

### Future Improvements
- Use Swift Concurrency (async/await) for crypto operations
- Actor isolation for PeerService
- Structured concurrency for network operations

## State Management

### MVVM Pattern
```
View ← ObservedObject/EnvironmentObject ← ViewModel (Service)
                                              ↓
                                           Models
```

### Observable Objects
- `PeerService`: Connection state, peers, messages
- `MessageStore`: Conversations, message history

### Environment Objects
- PeerService injected at app root
- Available to all views via @EnvironmentObject

## Error Handling

### PeerService Errors
```swift
enum PeerServiceError: Error {
    case noSharedSecret
    case encryptionFailed
    case peerNotFound
}
```

### CryptoKit Errors
```swift
enum CryptoError: Error {
    case encryptionFailed
    case decryptionFailed
    case invalidKey
    case keyAgreementFailed
    case signingFailed
    case verificationFailed
}
```

### Error Recovery
- Connection failures: Retry with exponential backoff
- Encryption failures: Alert user, don't send message
- Decryption failures: Log and skip message

## Testing Strategy

### Unit Tests
- CryptoKitWrapper: All crypto operations
- Message encoding/decoding
- Safety code generation
- Key derivation

### Integration Tests
- PeerService connection flow
- Message send/receive
- Persistence operations

### UI Tests
- Discovery flow
- Connection flow
- Chat interactions

### Security Tests
- Key exchange verification
- Message encryption/decryption
- Safety code consistency

## Future Enhancements

### Phase 2: Group Chat
```
Group Session Keys:
    Group ID → Symmetric Key (AES-GCM)
    Distributed via encrypted 1:1 to each member
    Perfect Forward Secrecy: Rotate on member change
```

### Phase 3: File Transfer
```
File Encryption:
    1. Generate random file key (AES-GCM)
    2. Encrypt file in chunks
    3. Encrypt file key with peer's shared secret
    4. Send encrypted key + encrypted chunks
```

### Phase 4: Ephemeral Messages
```
Message TTL:
    Store expiration timestamp
    Background timer to delete expired messages
    Options: 24h, 7d, 30d, never
```

## Performance Considerations

### Crypto Performance
- Ed25519: ~20k signatures/sec
- X25519: ~10k key agreements/sec
- AES-GCM: >1GB/sec encryption

### MultipeerConnectivity
- Max 8 peers in session
- ~30 feet range (Bluetooth)
- ~100 feet range (WiFi Direct)
- Throughput: ~1-5 Mbps

### Memory Usage
- Each peer: ~1KB (keys + state)
- Each message: ~500 bytes (encrypted)
- Conversations: Scales with message count

### Battery Impact
- Discovery: High (constant BLE/WiFi scanning)
- Connected idle: Low (occasional heartbeat)
- Active messaging: Medium (encryption + network)

## Deployment Considerations

### Info.plist Requirements
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>NearDrop uses local networking to discover nearby devices</string>

<key>NSBonjourServices</key>
<array>
    <string>_neardrop._tcp</string>
    <string>_neardrop._udp</string>
</array>
```

### Entitlements
- Multipath networking
- Local networking

### App Store Guidelines
- Position as messaging app, not crypto wallet
- Emphasize privacy and security
- Comply with encryption export regulations

---

**Document Version**: 1.0 (PoC)
**Last Updated**: 2024
