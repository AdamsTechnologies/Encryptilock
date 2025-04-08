import 'dart:io';
import 'package:flutter/material.dart';

class DocItem {
  final String title;
  final String content; // We'll store Markdown directly for simplicity.
  DocItem({required this.title, required this.content});
}

class DocProvider extends ChangeNotifier {
  final List<DocItem> _docs = [
    DocItem(
      title: "Getting Started", // TODO THIS NEEDS A REAL MAJOR REWRITE ON STUFF.
      content: """# Getting Started

Encryptilock is a local-only password manager designed for offline use. This section outlines the key screens and components of the app.

### Main Navigation

- **Info Tab (🛈)**  
  View app version, visit the Encryptilock website, and access helpful documentation.

- **Passwords Tab (🔐)**  
  The central vault where you can view, create, and manage password entries.

- **Settings Tab (⚙️)**  
  Adjust visual themes, timeout settings, and other configuration options.

- **Logout Button (⏻)**  
  Immediately lock and exit your session. Your data remains encrypted and stored locally.
---

""",
    ),
    DocItem(
      title: "What is Encryption?",
      content: """# How Encryption Works

Encryptilock uses symmetric, key-based encryption to protect all stored data.

### Encryption Components

- All records are encrypted using the **AES-256** cipher.
- The encryption key is derived from the master password using **Argon2id**.
- Sensitive fields are encrypted individually before being stored.
- The entire vault database file is encrypted before being written to disk.

### Password-Derived Key

- Your master password is never stored.
- During login, it is used to derive a key that unlocks the encrypted data.
- Without this key, the data cannot be decrypted or accessed.

### Local-Only Model

- All encryption and decryption occurs on your device.
- No data is ever uploaded or synced.

---
""",
    ),
    DocItem(
      title: "Managing your Passwords",
      content: """# Managing Your Passwords

Encryptilock provides a flexible, minimal interface for creating and organizing sensitive records.

### Creating a New Entry

- Navigate to the **Passwords Tab**.
- Click **"Create New Password"** to open the entry form.
- Each entry supports the following fields:
  - **Title** - e.g. "Bank of Example"
  - **Username** - Any identifier associated with the service.
  - **Password** - The actual secret.
  - **Category** - e.g. "Banking", "Email", "Social Media"
  - **URL** - the url to a website. if you don't include 'https://' or 'http://' it will prefix your url with https://
  - **Notes** - Optional free-form text.
- You only need to input title, username, and password. the rest are optional depending on your needs.

There is no enforced format — you're free to use the vault for account credentials, license keys, sensitive notes, or other confidential data.

### Editing & Deleting

- Tap an existing entry to view its full details.
- Initial display will allow for quick copying of credentials + opening the URL in browser
- select edit button to edit the existing password
- All edits are encrypted and saved instantly.

### Hidden (Inactive) Entries

- Each record can be toggled to "Show Record", or hide.
- Hidden entries do not appear in when searched, nor appear in the password list. 
- You can enable "Show Hidden Passwords" in the Settings tab to view these secretive entries.

---

""",
    ),
    DocItem(
      title: "Manual Backup",
      content: """# Manual Backup

In case you need to reset the app or back up your encrypted database manually, here's how it works:

### Manual Backup

You can manually back up your database files by locating them on your system:

- **Config Settings Database**: `s1.db`  
- **Password Vault Database**: `s2.db`

These are stored in your system's app data directory. On Windows, the path is usually:

```
TODO ADD PATH STUFF
```

Copy both files to a secure location (e.g. external drive or encrypted storage) to back up your data.

> ⚠️ **Reminder**: Without your master password, these files cannot be decrypted.

""",
    ),
    DocItem(
      title: "Factory Reset",
      content: """# Factory Reset

You can reset Encryptilock by choosing **"Factory Reset"** from the login screen help dialog. This action:

- completely wipes both the vault and config settings
- Returns the app to its first-launch state

> 💡 After reset, you'll need to create a new account and start fresh.

---

    """,
    ),
    DocItem(
      title: "Settings & Customization",
      content: """# Factory Reset

You can reset Encryptilock by choosing **"Factory Reset"** from the login screen help dialog. This action:

- Erases the password vault database (`s2.db`)
- Clears all configuration settings in-place (truncates `s1.db`)
- Returns the app to its first-launch state

> 💡 After reset, you'll need to create a new account and start fresh.

---

    """,
    ),
  ];

  int _selectedIndex = -1; // -1 = nothing selected
  bool get hasSelection => _selectedIndex >= 0;
  // int _selectedIndex = 0; // default selection

  List<DocItem> get docs => _docs;

  int get selectedIndex => _selectedIndex;
  DocItem get selectedDoc => _docs[_selectedIndex];

  void clearSelection() {
    _selectedIndex = -1;
    notifyListeners();
  }

  void selectDoc(int index) {
    if (index < 0 || index >= _docs.length) {
      clearSelection(); //default to base page.
    }
    _selectedIndex = index;
    notifyListeners();
  }
}
