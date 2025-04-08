import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> getLocalPath(String filename) async {
  final dir = await getApplicationSupportDirectory(); // works on all platforms
  print("${dir.path}/$filename");
  return '${dir.path}/$filename';
}
