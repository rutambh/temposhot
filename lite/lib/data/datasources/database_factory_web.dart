import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// The browser has no native sqflite implementation, so the localhost preview
/// (and any future web build) uses the WASM/IndexedDB factory. The database
/// still lives entirely in the browser profile; no network I/O is involved.
void configureDatabaseFactory() {
  databaseFactory = databaseFactoryFfiWeb;
}
