import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DocItem {
  final String title;
  final String content; // We'll store Markdown directly for simplicity.
  DocItem({required this.title, required this.content});
}

class DocProvider extends ChangeNotifier {
  final List<DocItem> _docs = [
    // -------------- HOW ENCRYPTION WORKS
    DocItem(
      title: "How Encryptilock Works",
      content: """# 🛡️ How Encryptilock Works
---
### Encryption Overview

- **AES-256** is used to encrypt all stored data.
- **Argon2id** is used to derive the encryption key from your master password.
- Each record is encrypted field-by-field before being saved.
- The entire vault is encrypted as an additional layer.
- Data remains encrypted unless actively decrypted for display or modification.

---

### Local-Only Model

- All cryptographic operations run entirely on your device.
- No data is ever uploaded, synced, or stored in the cloud.
- The master password is never saved, cached, or transmitted.

---

### Notes

- AES-256 and Argon2id are widely regarded as industry-leading encryption algorithms.
- Security depends on the strength of your master password. Choose one that is long and unique.
- The only network-facing feature is the optional feedback button on the Home Page. If used, it opens your browser to `https://encryptilock.com/contact`.   
  No app data is ever transmitted anywhere.

<!-- tags: encryption, AES-256, argon2id, local only, local first, local-only, local-first, password manager, secure, offline encryption, cryptography -->
""",
    ),
    // -------------- NAVIGATING THE APP
    DocItem(
      title: "Navigating the App",
      content: """# 🚀 Getting Started
---

### Main Navigation
- 🏠 **Home Tab** 
  Hints, app version details, link to submit feedback to Encryptilock.

- 🔐 **Passwords Tab**  
  View, create, edit, and manage your password entries. Supports filtering and hidden records.

- ⚙️ **Settings Tab**  
  Configure themes, idle timeout, password generation settings, and other preferences.

- 🛈 **Info Tab**  
  Documentation and User Manual.

- ⏻ **Logout Button**  
  Saves changes, and logs out of the app.

---

### Notes

Encryptilock operates entirely offline. No data is ever synced, uploaded, or transmitted.  
All encryption and data storage remain local.

<!-- tags: navigation, getting started, interface, onboarding -->
""",
    ),
    // -------------- ADD EDIT AND VIEW PASSWORDS
    DocItem(
      title: "Add, Edit & View Passwords",
      content: """# 🔐 Add, Edit & View Passwords
---

### Creating a New Entry

To add a new password:

1. Open the **Passwords** tab.
2. Tap **“Create Password.”**

Available fields:

- **Title** *(required)* — e.g. "Bank of Example"
- **Password** *(encrypted, required)* — The actual credential or secret
- **Username** *(encrypted, optional)* —  login identifier
- **Category** *(optional)* — grouping label (e.g. "Social Media", "Banking")
- **URL** *(encrypted, optional)* —  Automatically normalized to use `https://` if not specified
- **Notes** *(encrypted, optional)* — Optional free-form text

---

### Viewing and Editing Entries

- Tap any entry to view its details.
- From the detail view, you can:
  - Copy fields (username, password)
  - Launch the associated URL
  - Tap the **Edit** icon to modify the entry

Changes are saved automatically and re-encrypted on save.

---

### Hidden Entries

- Entries can be marked as **Hidden**, removing them from the default list and search results.
- To view hidden items, enable **Show Hidden Passwords** in Settings.
- Use this to archive sensitive or infrequently used records without deleting them.

---

### Notes

- Entries are not limited to passwords. Use it to store important notes, license keys, anything text-based you need to securely store.
- Most fields are individually encrypted.  
However, **Title** and **Category** are stored in plaintext to support search, filtering, and hidden entry management. Do not place sensitive or identifying information in these fields.

<!-- tags: passwords, password entry, create, create entry, edit, delete, view, hidden passwords, vault, secure notes, title, username, category, URL, url, note, show Record, view password -->
""",
    ),
    // -------------- MANUAL BACKUP
    DocItem(
      title: "Manual Backup",
      content: """# 💾 Manual Backup
---

### Files to Back Up

To retain your configuration and password data, back up both of the following files:

- `s1.db` — Configuration Settings
- `s2.db` — Encrypted Password Vault

These files are located in the app's data directory:
```
{{DB_PATH}}
```

---

### Risks and Considerations

- ❌ Do not rename or modify these files outside of Encryptilock.
- ⚠️ Deleting these files resets Encryptilock to first-launch state.
- ✅ backups should be stored in a private and secure location.

---

### Notes

- Manual backups are currently the only recovery option.
- Built-in backup and restore tools are planned for a future update.

<!-- tags: backup, back-up, save, export, recovery, config, database, vault -->
""",
    ),
    // -------------- RESETTING THE APP
    DocItem(
      title: "Resetting the App",
      content: """# 🔄 Resetting the App
---

### Factory Reset via Login Screen

If the **Allow Factory Reset** option was enabled in Settings:

1. Open the **Login screen**.
2. Tap **“Having trouble logging in? Factory Reset”**.
3. Enter your exact, case-sensitive username.
4. Tap **“Delete and Restart”** (button will enable after valid input).

---

### Manual Reset (if factory reset is unavailable)

If you did not enable factory reset or no longer know your username:

1. Locate the application database files. See **Manual Backup** for file locations.
2. Delete both:
   - `s1.db` — Config Settings
   - `s2.db` — Password Vault
3. Restart the app. You will be prompted to create a new account.

---

### What This Does

- Deletes all encrypted data and configuration
- Returns Encryptilock to its first-launch state
- Cannot be undone

⚠️ Back up any important data before resetting. This action is permanent.

---

### When to Use This

- You forgot your master password
- Your data is no longer accessible
- You want to start over with a clean slate

<!-- tags: factory reset, delete account, delete data, start over, reset app, lost password, restart -->
""",
    ),
    // -------------- CONFIG SETTINGS
    DocItem(
      title: "Config Settings",
      content: """# ⚙️ Settings & Customization
---

### Appearance

- **Theme Selection**  
  Choose from 20 predefined color themes. Changes apply immediately and persist across sessions.

---

### Security

- **Idle Timeout**  
  Sets an inactivity timer (in minutes). When the app detects no interaction for the specified duration, it saves data, locks, and returns to the login screen.

- **Allow Factory Reset**  
  Enables a reset button on the login screen. This allows the app to be restored to its original state by confirming the username.

  If your username is forgotten or the option is disabled, you can manually delete the application's database files to reset.  
  See **Manual Backup** for file locations.

---

### Password List Behavior

- **Clear Filters on Logout**  
  If enabled, clears active category filters when logging out.  
  Default is off (filters persist across sessions).

- **Show Hidden Passwords**  
  Displays entries marked as inactive in the password list.

- **Add Delete Button to Password View**  
  Adds a delete button directly to the detail view of each password entry.

- **Do Not Ask Before Deleting**  
  Removes the delete confirmation prompt.  
  ⚠️ Use with caution to avoid accidental data loss.

---

### Password Generator Settings

These options define how generated passwords behave.

- **Minimum and Maximum Length**  
  Set bounds for password length.

- **Exclude Characters**  
  Prevent specific characters from appearing in generated passwords (e.g. `!@&.`).

- **Auto-Generate & Fill**  
  If enabled, tapping the key icon auto-fills a generated password.  
  If disabled, the generator dialog opens for review before use.

---
The Settings tab allows you to configure Encryptilock's appearance, security behavior, and password handling preferences.
All configuration changes are saved automatically to your settings database.

<!-- tags: settings, appearance, theme, timeout, password options, delete confirmation, generator settings, filters, factory reset -->""",
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

  Future<String> getDbPathDisplayString() async {
    final dir = await getApplicationSupportDirectory();
    return "$dir";
  }
}
