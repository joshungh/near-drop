import Foundation
import CryptoKit

/// Wrapper for CryptoKit operations providing end-to-end encryption
/// Uses Ed25519 for identity signing and X25519 for key exchange
class CryptoKitWrapper {

    // MARK: - Key Types

    struct IdentityKeys {
        let signingKey: Curve25519.Signing.PrivateKey
        let publicKey: Curve25519.Signing.PublicKey

        var publicKeyData: Data {
            publicKey.rawRepresentation
        }
    }

    struct SessionKeys {
        let privateKey: Curve25519.KeyAgreement.PrivateKey
        let publicKey: Curve25519.KeyAgreement.PublicKey

        var publicKeyData: Data {
            publicKey.rawRepresentation
        }
    }

    // MARK: - Key Generation

    /// Generate Ed25519 identity keys for signing
    static func generateIdentityKeys() -> IdentityKeys {
        let privateKey = Curve25519.Signing.PrivateKey()
        return IdentityKeys(signingKey: privateKey, publicKey: privateKey.publicKey)
    }

    /// Generate X25519 ephemeral session keys for key exchange
    static func generateSessionKeys() -> SessionKeys {
        let privateKey = Curve25519.KeyAgreement.PrivateKey()
        return SessionKeys(privateKey: privateKey, publicKey: privateKey.publicKey)
    }

    // MARK: - Key Exchange

    /// Perform ECDH key agreement and derive shared secret using HKDF-SHA256
    static func deriveSharedSecret(
        privateKey: Curve25519.KeyAgreement.PrivateKey,
        publicKey: Curve25519.KeyAgreement.PublicKey,
        salt: Data? = nil,
        info: Data = Data()
    ) throws -> SymmetricKey {
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: publicKey)

        return sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: salt ?? Data(),
            sharedInfo: info,
            outputByteCount: 32
        )
    }

    // MARK: - Encryption / Decryption

    /// Encrypt data using AES-GCM with the provided symmetric key
    static func encrypt(data: Data, using key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw CryptoError.encryptionFailed
        }
        return combined
    }

    /// Decrypt data using AES-GCM with the provided symmetric key
    static func decrypt(data: Data, using key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    // MARK: - Signing / Verification

    /// Sign data using Ed25519 private key
    static func sign(data: Data, with signingKey: Curve25519.Signing.PrivateKey) throws -> Data {
        return try signingKey.signature(for: data)
    }

    /// Verify signature using Ed25519 public key
    static func verify(signature: Data, for data: Data, publicKey: Curve25519.Signing.PublicKey) -> Bool {
        return publicKey.isValidSignature(signature, for: data)
    }

    // MARK: - Safety Code Generation

    /// Generate a human-readable safety code from two public keys
    /// Used for out-of-band verification between peers
    static func generateSafetyCode(
        localPublicKey: Data,
        remotePublicKey: Data
    ) -> String {
        // Combine and hash both public keys
        var combined = Data()
        combined.append(localPublicKey)
        combined.append(remotePublicKey)

        let hash = SHA256.hash(data: combined)
        let hashData = Data(hash)

        // Take first 6 bytes and convert to 12-digit code
        let bytes = hashData.prefix(6)
        let code = bytes.map { String(format: "%02d", $0 % 100) }.joined()

        // Format as XXX-XXX-XXX-XXX
        let formatted = stride(from: 0, to: code.count, by: 3)
            .map { index -> String in
                let start = code.index(code.startIndex, offsetBy: index)
                let end = code.index(start, offsetBy: min(3, code.count - index))
                return String(code[start..<end])
            }
            .joined(separator: "-")

        return formatted
    }

    // MARK: - Utility

    /// Convert Data to Base64 string for transmission
    static func dataToBase64(_ data: Data) -> String {
        data.base64EncodedString()
    }

    /// Convert Base64 string back to Data
    static func base64ToData(_ string: String) -> Data? {
        Data(base64Encoded: string)
    }
}

// MARK: - Errors

enum CryptoError: Error {
    case encryptionFailed
    case decryptionFailed
    case invalidKey
    case keyAgreementFailed
    case signingFailed
    case verificationFailed
}
