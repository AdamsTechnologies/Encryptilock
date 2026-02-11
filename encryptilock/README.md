
# Encryptilock
[Encryptilock.com](https://www.encryptilock.com/)

### Windows (Microsoft Store)

An EV-code-signed Windows build is available on the Microsoft Store.

[Get Encryptilock on the Microsoft Store](https://apps.microsoft.com/store/detail/9MZVC69H35J2?cid=DevShareMCLPCS)

---

### Android (Google Play)

The official Android build is available on Google Play.

[Get Encryptilock on Google Play](https://play.google.com/store/apps/details?id=com.encryptilock.app&pli=1)

---


# Documentation
**Encryptilock** is a local-first, offline password manager built with Flutter.
It prioritizes security, user ownership, and simplicity over cloud dependence.

No cloud sync.
No telemetry.
No tracking.
Your vault stays on your device.

---

## Philosophy

Encryptilock is designed around a simple principle:

> Secrets should not require a server.

The application runs entirely offline and stores encrypted data locally.
Users retain full control over their data and backups.

---

## Core Features

* AES-256 encryption
* Argon2ID key derivation
* Fully local storage (SQLite)
* Cross-platform:

  * Windows
  * macOS
  * Android
  * Linux (desktop)
* Secure registration & login flow
* Category filtering (multi-select, persistent)
* DPI-aware responsive UI
* Offline-first architecture
* Signed desktop builds (EV code signing for Windows)

---

## Security Model
Encryptilock is designed to minimize exposure of sensitive data both **at rest** and **in memory**.  
Encryptilock follows these principles:

### Encryption
* encrypted using **AES-256**
* Keys derived using **Argon2ID**
* Entire database is encrypted
* Sensitive fields (password, username, URLs) are also encrypted
* No cloud backup or remote sync

### In Memory
* Database remains encrypted at rest
* When unlocked, records are loaded.
* Sensitive fields remain encrypted in memory until needed.
  * Username/URL decrypt only when a record is selected.
  * Password decrypts only when:
    * "Show" is pressed
    * "Copy" is triggered

This minimizes the lifetime of decrypted secrets in memory.

### Local-Only Storage

* SQLite database stored locally
* Config/settings stored with lightweight obfuscation
* No remote storage endpoints

### Threat Model

Encryptilock protects against:

* Casual local file inspection
* Stolen laptop without master password
* Database extraction without credentials

It does not attempt to protect against:

* Compromised OS
* Active malware
* Kernel-level attacks
* Memory scraping

If the host machine is compromised, no password manager can guarantee safety.

---

## Architecture Overview

### Application Layer

* Built in Flutter
* Desktop-first layout with mobile adaptations
* Responsive scaling (DPI-aware)

### Database Layer

* Abstract async interface (`EncryptedDatabase`)
* Platform-specific implementations:

  * `sqlite3` (desktop via FFI)
  * `sqflite` (mobile)

This allows:

* Platform-agnostic data access
* Future portability
* Clean separation of persistence from UI

### Cryptography Layer

* Key derivation using Argon2ID
* Vault encryption using AES-256
* Encryption performed before database persistence

---

## Why No Cloud?

Most password managers trade convenience for control.

Encryptilock intentionally avoids:

* Sync servers
* Subscription requirements
* Account lock-in
* Data harvesting

If you want sync, use secure file sync (e.g., encrypted storage, private cloud, manual transfer). Encryptilock does not enforce any vendor.

---

## Building from Source

### Prerequisites

* Flutter (latest stable)
* Dart SDK
* Platform-specific desktop tooling

Enable desktop support:

```bash
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
```

### Install Dependencies

```bash
flutter pub get
```

### Run

```bash
flutter run
```

### Build Release

```bash
flutter build windows --release
flutter build macos --release
flutter build linux --release
flutter build apk --release
```

---

## Project Structure (Simplified)

```
lib/
  crypto/
  database/
  models/
  services/
  ui/
  widgets/
```

* `crypto/` → encryption + key derivation
* `database/` → platform abstraction
* `ui/` → screens and layout
* `services/` → vault operations and state handling

---

## Design Goals

* Local-first security
* Minimal attack surface
* Cross-platform consistency
* Fast performance
* No feature bloat
* Transparent architecture

---

## Roadmap (Open Source Direction)

* Improved mobile UX refinements
* Enhanced search and filtering
* Export/import tooling
* Secure backup utilities
* Plugin-friendly architecture

---

## Contributing

Contributions are welcome.

Guidelines:

* Security changes must include rationale.
* Cryptographic changes require documentation.
* Keep dependencies minimal.
* Avoid unnecessary abstractions.

If submitting PRs:

* Keep changes focused.
* Include test coverage where relevant.
* Do not introduce telemetry.

---

## License

Encryptilock is licensed under the GNU General Public License v3.0.

You may:

* Use the software
* Modify the software
* Distribute the software
* Sell copies of the software

Under the condition that:

* Any distributed modifications must also be licensed under GPLv3
* Source code must be made available when distributing binaries
* You may not relicense it under a proprietary license

Full license text is available in the `LICENSE.md` file.

---

## Disclaimer

Encryptilock is provided as-is without warranty.

Security depends on:

* Strong master password
* Secure host device
* Responsible operational practices

