
abstract class EncryptionInterface {
  String decode(Object obj); // Equivalent of _decode
  String encode(Object obj); // Equivalent of _encode
  String encrypt(String obj); // Encryption function
  String decrypt(String obj); // Decryption function
  dynamic decrypto(dynamic obj); // Handles both String and bytes
  String encrypto(dynamic obj, {String encodeErrorsMethod = 'strict'});
}

abstract class DatabaseInterface {
  void connectionManager(); // Abstract connection manager
  dynamic query(); // Abstract query method
  void executeCommands(); // Abstract execution method
  void warmUp(); // Initialization or warm-up method
}

abstract class BaseInterface {
  final dynamic controller;
  final Map<String, String> schema;
  final List<String> upsertKeys;

  BaseInterface(this.controller, this.schema, this.upsertKeys);

  void setItem();
  dynamic getItem();
  dynamic getRecord();
  List<dynamic> getAllItems();
  Map<String, dynamic> createIfNotExists();
  void executeOperation();
}

class KeyStorageInterface extends BaseInterface {
  final String keySection;
  final String keyField;

  KeyStorageInterface(dynamic controller)
      : keySection = 'section',
        keyField = 'field',
        super(
          controller,
          {'section': 'nvarchar(1000)', 'field': 'nvarchar(MAX)'},
          ['section'],
        );

  @override
  void setItem() => controller.setItem();

  @override
  dynamic getItem() => controller.getItem();

  @override
  dynamic getRecord() => controller.getRecord();

  @override
  List<dynamic> getAllItems() => controller.getAllItems();

  void remove() => controller.remove();

  @override
  Map<String, dynamic> createIfNotExists() => controller.createIfNotExists();

  @override
  void executeOperation() => controller.executeOperation();
}

class PasswordStorageInterface extends BaseInterface {
  PasswordStorageInterface(dynamic controller)
      : super(
          controller,
          {
            'id': 'nvarchar(50) PRIMARY KEY',
            'username': 'nvarchar(256)',
            'password': 'nvarchar(256)',
            'service': 'nvarchar(1000)',
            'servicetype': 'nvarchar(1000)',
            'isactive': 'bit',
            'url': 'nvarchar(MAX) NULL',
            'dt': 'datetime',
          },
          ['id'],
        );

  @override
  void setItem() => controller.setItem();

  @override
  dynamic getItem() => controller.getItem();

  @override
  List<dynamic> getAllItems() => controller.getAllItems();

  @override
  dynamic getRecord() => controller.getRecord();

  void remove() => controller.remove();

  @override
  Map<String, dynamic> createIfNotExists() => controller.createIfNotExists();

  @override
  void executeOperation() => controller.executeOperation();
}
