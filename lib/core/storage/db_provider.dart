import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apexflow/core/storage/db_service.dart';
import 'package:apexflow/core/storage/isar_db_service_stub.dart'
    if (dart.library.io) 'package:apexflow/core/storage/isar_db_service.dart';
import 'package:apexflow/core/storage/in_memory_db_service.dart';

final dbServiceProvider = Provider<DbService>((ref) {
  bool isTest = false;
  if (!kIsWeb) {
    try {
      isTest = Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      isTest = false;
    }
  }
  if (kIsWeb || isTest) {
    return InMemoryDbService();
  }
  return IsarDbService();
});
