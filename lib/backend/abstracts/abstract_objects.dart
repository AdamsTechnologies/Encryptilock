
abstract class EncryptionInterface {
  String decode(Object obj); // Equivalent of _decode
  String encode(Object obj); // Equivalent of _encode
  String encrypt(String obj); // Encryption function
  String decrypt(String obj); // Decryption function
  dynamic decrypto(dynamic obj); // Handles both String and bytes
  String encrypto(dynamic obj); // Handles both String and bytes
}

final Map<String, String> typeMapping = {
    'nvarchar': 'TEXT',
    'varchar': 'TEXT',
    'char': 'TEXT',
    'bit': 'INTEGER',
    'datetime': 'TEXT',
    'int': 'INTEGER',
    'bigint': 'INTEGER',
    'float': 'REAL',
    'decimal': 'REAL',
    'money': 'REAL',
    'uniqueidentifier': 'TEXT',
    'binary': 'BLOB',
    'varbinary': 'BLOB',
  };

Map<String, String> passwordStorageSchema = {
            'id': 'TEXT PRIMARY KEY',
            'username': 'TEXT NULL',
            'password': 'TEXT NOT NULL',
            'service': 'TEXT NULL',
            'servicetype': 'TEXT NULL',
            'isactive': 'INTEGER',
            'url': 'TEXT NULL',
            'notes':'TEXT NULL',
            'created_at': 'TEXT NOT NULL',
            'updated_at': 'TEXT NULL',
          };
List<String> passwordStoragePKs = ['id'];