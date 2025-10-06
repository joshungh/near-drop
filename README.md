# NearDrop

A modern, privacy-focused encrypted peer-to-peer messaging and file transfer app for Apple devices.

## Overview

NearDrop enables secure, serverless local communication using MultipeerConnectivity with end-to-end encryption. Think AirDrop meets Signal - completely offline and privacy-first.

## Features

### Core Features (PoC)
- 🔒 **End-to-End Encryption** - All messages encrypted with AES-GCM
- 📱 **Peer-to-Peer Discovery** - Find nearby devices using MultipeerConnectivity
- 💬 **1:1 Encrypted Messaging** - Secure chat between connected peers
- 🛡️ **Safety Code Verification** - Verify connections with out-of-band codes
- 📵 **100% Offline** - No servers, no internet required
- 🔐 **Local-Only Storage** - All data stored encrypted on device

### Security Architecture
- **Identity**: Ed25519 signing keys
- **Key Exchange**: X25519 ephemeral keys (ECDH)
- **Encryption**: AES-GCM with 256-bit keys
- **Key Derivation**: HKDF-SHA256
- **Storage**: Keychain + Secure Enclave

## Project Structure

```
NearDrop/
├── NearDrop/
│   ├── NearDropApp.swift          # App entry point
│   ├── Core/
│   │   └── CryptoKitWrapper.swift # Encryption layer (Ed25519, X25519, AES-GCM)
│   ├── Services/
│   │   ├── PeerService.swift      # MultipeerConnectivity management
│   │   └── MessageStore.swift     # Message persistence
│   ├── Models/
│   │   └── Message.swift          # Data models
│   └── Views/
│       ├── ContentView.swift      # Main tab view
│       ├── DiscoveryView.swift    # Peer discovery interface
│       ├── ChatsListView.swift    # Active conversations
│       ├── ChatView.swift         # 1:1 chat interface
│       └── SettingsView.swift     # App settings
```

## Technology Stack

- **Language**: Swift 5.10+
- **UI Framework**: SwiftUI
- **Networking**: MultipeerConnectivity
- **Encryption**: CryptoKit (X25519, Ed25519, AES-GCM)
- **Persistence**: UserDefaults (MessageStore), Keychain (future: keys)
- **Architecture**: MVVM + Swift Concurrency

## Getting Started

### Prerequisites
- macOS Ventura or later
- Xcode 15.0+
- iOS 17.0+ / iPadOS 17.0+ target devices

### Building the PoC

1. Clone the repository:
```bash
git clone <repository-url>
cd near-drop
```

2. Open the Xcode project:
```bash
open NearDrop/NearDrop.xcodeproj
```

3. Build and run on two iOS devices or simulators (note: MultipeerConnectivity works best on physical devices)

### Usage

1. **Discovery**: Tap "Start Discovery" to find nearby NearDrop devices
2. **Connect**: Tap "Connect" on a discovered peer
3. **Verify**: Check safety codes to verify secure connection
4. **Chat**: Send encrypted messages in the Chats tab

## How It Works

### Connection Flow
1. Device A and B both start discovery (advertising + browsing)
2. When discovered, devices exchange identity public keys via discovery info
3. User initiates connection from Device A to Device B
4. During invitation, ephemeral session public keys are exchanged
5. Both devices perform ECDH key agreement to derive shared secret
6. Shared secret used to encrypt/decrypt all messages via AES-GCM

### Message Encryption
```
1. Generate ephemeral X25519 key pair for session
2. Perform ECDH with peer's public key → shared secret
3. Derive AES-GCM key using HKDF-SHA256
4. Encrypt message with AES-GCM
5. Send encrypted payload over MultipeerConnectivity
6. Recipient decrypts with same shared secret
```

### Safety Code Verification
```
1. Combine both devices' identity public keys
2. Hash with SHA256
3. Take first 6 bytes, format as 12-digit code (XXX-XXX-XXX-XXX)
4. Users compare codes out-of-band to verify no MITM
```

## Roadmap

### Phase 1: Encrypted 1:1 Chat (PoC) ✅
- [x] CryptoKit encryption wrapper
- [x] MultipeerConnectivity integration
- [x] Basic SwiftUI interface
- [x] Message persistence
- [x] Safety code verification

### Phase 2: Group Chat + Attachments (Future)
- [ ] Group chat (2-8 peers)
- [ ] Encrypted file sharing
- [ ] Image/media support
- [ ] Core Data migration

### Phase 3: Advanced Features (Future)
- [ ] Crypto payload transfer (signed transactions)
- [ ] Voice notes
- [ ] QR device linking
- [ ] Ephemeral messages (24h/7d)

### Phase 4: Production Ready (Future)
- [ ] UI/UX polish
- [ ] Comprehensive testing
- [ ] App Store preparation
- [ ] Documentation

## Security Considerations

### What's Encrypted
✅ Message content (AES-GCM)
✅ Session keys (ephemeral X25519)
✅ Identity verification (Ed25519 signatures)

### What's Not Encrypted
⚠️ Metadata (device names, discovery info)
⚠️ Presence information (who's online)
⚠️ MultipeerConnectivity transport layer (but uses TLS)

### Best Practices
- Always verify safety codes for sensitive conversations
- Keep your device's software updated
- Be aware of your physical surroundings when using discovery
- Don't share safety codes over insecure channels

## Privacy

- **No Cloud**: All data stays on device
- **No Servers**: Completely peer-to-peer
- **No Analytics**: Zero telemetry by default
- **No Tracking**: No user accounts or identifiers
- **Local Storage**: Messages stored encrypted locally only

## Known Limitations (PoC)

- MultipeerConnectivity range limited (~30 feet)
- Works best on physical devices (simulators have limitations)
- No background operation (iOS restrictions)
- Messages not synced across user's devices
- Group chat not yet implemented
- File sharing not yet implemented

## Development

### Running Tests
```bash
# Run unit tests
xcodebuild test -scheme NearDrop -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Code Style
- Follow Swift API Design Guidelines
- Use SwiftLint for consistency
- Prefer async/await over completion handlers
- Document public APIs

## Contributing

This is a proof-of-concept project. Contributions welcome for:
- Security audits
- Bug fixes
- Feature implementations from roadmap
- Documentation improvements

## License

[To be determined]

## Acknowledgments

- Built on Apple's CryptoKit and MultipeerConnectivity frameworks
- Inspired by Signal's security model and AirDrop's UX
- Thanks to the Swift community

## Contact

For security issues, please contact [your contact info]

---

**⚠️ Current Status: Proof of Concept**
This is a PoC implementation. Not yet production-ready. Use for testing and development only.
