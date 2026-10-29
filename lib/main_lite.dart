import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_flavor.dart';
import 'core/database/database_factory.dart';
import 'main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDatabaseFactory();
  AppFlavorConfig.current = AppFlavorConfig.lite;

  runApp(
    ProviderScope(
      overrides: [
        flavorConfigProvider.overrideWithValue(AppFlavorConfig.lite),
      ],
      child: const TempoShotApp(),
    ),
  );
}
