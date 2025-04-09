import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DocItem {
  final String title;
  final String content; // We'll store Markdown directly for simplicity.
  DocItem({required this.title, required this.content});
}

class DocProvider extends ChangeNotifier {
  final List<DocItem> _docs = [
    DocItem(
      title: "Navigating the App",
      content: """# 🚀 Getting Started

Encryptilock is a privacy-first password manager designed for local, offline use. This guide introduces the core areas of the app and how to navigate them.

---

### 🔍 Main Navigation

- **Info Tab (🛈)**  
  Access help documentation, app version info, and a direct link to the Encryptilock website.

- **Passwords Tab (🔐)**  
  Your secure vault for viewing, creating, editing, and organizing password entries.

- **Settings Tab (⚙️)**  
  Customize themes, auto-lock timeout, password generation rules, and other preferences.

- **Logout Button (⏻)**  
  Instantly lock the app and return to the login screen. Your data remains encrypted and stored securely on your device.

---

Encryptilock is built for simplicity — all encryption and data management happens locally. No internet required, no cloud syncing, no middlemen.

<!-- tags: navigation, getting started, interface, onboarding -->
""",
    ),
    DocItem(
      title: "How Encryption Works",
      content: """# 🔐 How Encryption Works

Encryptilock protects your data using industry-standard cryptography, all handled entirely offline and on your device.

### Encryption Basics

- All records are encrypted using the **AES-256** cipher — one of the most secure encryption algorithms available today.
- We use **Argon2id** to derive a secure encryption key.
- Sensitive fields are encrypted individually before being saved.
- The entire vault is encrypted as well.

🛡️ *AES-256 would take billions of years to crack with current computing technology. Argon2id adds another layer of protection by making password guessing extremely difficult, even with dedicated hardware.*

### Local-Only Model

- All encryption and decryption happens on your device.
- No data is synced, uploaded, or stored in the cloud.
- Your master password is never saved or transmitted.

Encryptilock ensures that only **you** hold the key to your data.

---

<!-- tags: encryption, AES-256, argon2id, local only, local encryption, security, secure data, secure password manager -->
""",
    ),
    DocItem(
      title: "Add, Edit & View Passwords",
      content: """# 🔐 Add, Edit & View Passwords

Encryptilock provides a clean, flexible interface for storing sensitive records securely.

---

### Creating a New Entry

To create a new password entry:

- Go to the **Passwords Tab**
- Click **"Create New Password"**

Each entry includes the following fields:

- **Title** - e.g. "Bank of Example"
- **Username** - Your login identifier
- **Password** - The actual secret
- **Category** - e.g. "Banking", "Email", "Social Media"
- **URL** - A website address.\
  (If it doesn't start with `http://` or `https://`, it defaults to `https://`)
- **Notes** - Optional free-form text

Only **Title**  and **Password** are required. Use remaining fields as needed.

💡 *Use the vault for more than just passwords—license keys, secure notes, or private records are all supported.*

---

### Viewing, Editing & Deleting

- Tap a saved item to view its details.
- From the view screen, you can:
  - **Copy credentials**
  - **Open the saved URL**
  - **Edit the entry** by clicking the **Edit** icon
- All changes are encrypted and saved automatically.

---

### Hidden (Inactive) Entries

- Entries can be marked as **Hidden**, removing them from the main list and search results.
- To view hidden records, enable **"Show Hidden Passwords"** in the Settings tab.
- Use this to archive or obscure sensitive items without deleting them.

---

<!-- tags: passwords, create entry, title, username, category, URL, note, show Record, edit, delete, url, hidden passwords, notes, view password -->
""",
    ),
    DocItem(
      title: "Manual Backup",
      content: """# 💾 Manual Backup

Built-in backup and restore functionality is planned for a future release, you can back up your data manually in the meantime.

---

### What to Back Up

To safeguard your encrypted data, back up the following two database files:

- **Config Settings Database**: `s1.db`  
- **Password Vault Database**: `s2.db`

These files are located in your system's app data directory:

```
{{DB_PATH}}
```
💡 *You can copy these files to an external drive, encrypted archive, or any secure offline location.*

---

### Important Notes
- ⚠️ **Handle backups with care.** Modifying, misplacing, or renaming these databases can render your vault unusable.

Encryptilock will include automatic backup and recovery tools in an upcoming update. Until then, this manual method is your primary recovery option.

---

<!-- tags: backup, back-up, back up, sync, save data -->
""",
    ),
    DocItem(
      title: "Resetting the App",
      content: """# 🔄 Resetting the App

You can return Encryptilock to a fresh state by performing a factory reset from the login screen.

---

### Factory Reset

To reset the app:

- Open the login screen and tap the **Help** icon.
- Select **Factory Reset** from the dialog options.

This will:

- Permanently delete your password vault (`s2.db`) and all configuration settings (`s1.db`)
- Return the app to its first-launch state

After resetting, you'll be prompted to create a new account as if launching the app for the first time.

⚠️ *This action is irreversible. Ensure you've backed up any important data beforehand.*

---

### When to Use Factory Reset

- If you've forgotten your master password
- If your vault is no longer accessible
- If you want to completely wipe your data and start over

---

<!-- tags: factory reset, delete account, start over, lost password, restart -->
""",
    ),
    DocItem(
      title: "Config Settings",
      content: """# ⚙️ Settings & Customization

The Settings tab allows you to personalize Encryptilock's behavior and appearance to your preferences.

---

### Theme Selection

- Choose from 20 available themes.
- Changes apply instantly and persist across sessions.

---

### Idle Timeout

- Set a custom inactivity timeout (in minutes).
- After the specified period with no interaction, the app auto-locks and returns to the login screen.
- Helps protect your data during periods of inactivity.

⚠️ *Tip: Lock your device manually when stepping away. Encryptilock adds an extra layer by auto-locking if you forget.*

---

### Password Settings

These options allow you to fine-tune how password entries are handled and generated:

- **Show Hidden Passwords**  
  Displays entries marked as inactive in the password list.  
  Useful for archived records or low-use secrets you'd like to keep out of sight.

- **Add Delete Button to Password Main View**  
  Enables a delete button on the password detail screen for quicker access, without entering edit mode.

- **Do Not Ask Before Deleting**  
  Disables the confirmation prompt when deleting a password. Use with caution.

- **Define Password Generator Parameters**  
  Customize how new passwords are created:
  - **Min/Max Length** - Set bounds for password length.
  - **Exclude Characters** - Enter any characters you'd like to avoid in generated passwords.  
    For example: `ABCab198!:;'”` ensures none of these appear in new passwords.
  - **Auto-Generate & Fill** - When enabled, tapping the key icon will instantly create and fill a password based on your saved preferences.  
    When disabled, the password generator dialog will open instead.

 ⚠️ *Tip: Exclude only necessary characters to maintain strong entropy in generated passwords.*

All changes are saved automatically to your encrypted configuration database.

---

<!-- tags: settings, appearance, theme, timeout, timer, add delete, do not ask, ask delete, parameters, min length, max length, exclude characters, generator, show hidden, delete button, auto generate, config -->""",
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
