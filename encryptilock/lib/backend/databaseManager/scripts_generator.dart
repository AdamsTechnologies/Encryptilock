class Scripts {
  // Check if a table exists
  static String checkTableExistsScript(String tableName) {
    return "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'";
  }

  // Create a table
  static String createTableScript(String tableName, String columns) {
    return "CREATE TABLE IF NOT EXISTS $tableName ($columns)";
  }

  // Create an insert statement
  static Map<String, dynamic> createInsertStatement(String tableName, List<Map<String, dynamic>> data) {
    if (data.isEmpty) return {'query': '', 'values': []};

    final columns = data.first.keys;
    final columnsStr = columns.join(', ');
    final placeholders = columns.map((_) => '?').join(', ');

    final query = "INSERT INTO $tableName ($columnsStr) VALUES ($placeholders)";
    final values = data.map((row) => columns.map((col) => row[col]).toList()).toList();

    return {'query': query, 'values': values};
  }

  // Create an update statement
  static Map<String, dynamic> createUpdateStatement(
    String tableName,
    Map<String, dynamic> data,
    List<String> uniqueKeys,
  ) {
    final columns = data.keys;
    final updates = columns.map((col) => '$col = ?').join(', ');
    final uniqueConditions = uniqueKeys.map((key) => '$key = ?').join(' AND ');

    final query = "UPDATE $tableName SET $updates WHERE $uniqueConditions";
    final values = [
      ...data.values,
      ...uniqueKeys.map((key) => data[key]),
    ];

    return {'query': query, 'values': values};
  }

  // Get max incrementor script
  static String getMaxIncrementorScript(String tableName, String fieldName) {
    return "SELECT COALESCE(MAX($fieldName), 0) + 1 AS max_$fieldName FROM $tableName";
  }

  // Get query
  static Map<String, dynamic> getQuery(
    String tableName,
    List<String> selectCols,
    Map<String, dynamic>? conditions,
  ) {
    final selectColsStr = selectCols.join(', ');
    if (conditions != null && conditions.isNotEmpty) {
      final placeholders = conditions.keys.map((col) => '$col = ?').join(' AND ');
      final query = "SELECT $selectColsStr FROM $tableName WHERE $placeholders";
      final values = conditions.values.toList();
      return {'query': query, 'values': values};
    }
    return {'query': "SELECT $selectColsStr FROM $tableName", 'values': []};
  }

  // Get delete record script
  static Map<String, dynamic> getDeleteRecordScript(String tableName, Map<String, dynamic> conditions) {
    final placeholders = conditions.keys.map((col) => '$col = ?').join(' AND ');
    final query = "DELETE FROM $tableName WHERE $placeholders";
    final values = conditions.values.toList();
    return {'query': query, 'values': values};
  }
}