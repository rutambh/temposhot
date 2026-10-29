import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Configures the WASM/IndexedDB SQLite database factory for Chrome and web previews.
/// Data is saved completely in the browser profile; zero internet I/O.
void configureDatabaseFactory() {
  databaseFactory = databaseFactoryFfiWeb;
}
