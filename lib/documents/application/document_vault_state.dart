import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:apexflow/core/storage/db_provider.dart';
import 'package:apexflow/documents/domain/motorcycle_document.dart';
import 'package:apexflow/documents/domain/tax_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocumentVaultState {
  const DocumentVaultState({
    required this.isHydrating,
    required this.documents,
    required this.taxRecords,
  });

  final bool isHydrating;
  final List<MotorcycleDocument> documents;
  final List<TaxRecord> taxRecords;

  DocumentVaultState copyWith({
    bool? isHydrating,
    List<MotorcycleDocument>? documents,
    List<TaxRecord>? taxRecords,
  }) {
    return DocumentVaultState(
      isHydrating: isHydrating ?? this.isHydrating,
      documents: documents ?? this.documents,
      taxRecords: taxRecords ?? this.taxRecords,
    );
  }
}

final documentVaultProvider =
    NotifierProvider<DocumentVaultController, DocumentVaultState>(
      DocumentVaultController.new,
    );

class DocumentVaultController extends Notifier<DocumentVaultState> {
  @override
  DocumentVaultState build() {
    unawaited(_hydrate());
    return const DocumentVaultState(
      isHydrating: true,
      documents: [],
      taxRecords: [],
    );
  }

  Future<void> _hydrate() async {
    final db = ref.read(dbServiceProvider);
    await db.init();
    final docs = await db.getDocuments();
    final taxes = await db.getTaxRecords();
    state = DocumentVaultState(
      isHydrating: false,
      documents: docs,
      taxRecords: taxes,
    );
  }

  Future<void> addDocument({
    required String bikeStableId,
    required String title,
    required String description,
    String? imagePath,
    String? expirationDateIso,
  }) async {
    String? persistentPath = imagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        final sourceFile = File(imagePath);
        if (await sourceFile.exists()) {
          final appDir = await getApplicationDocumentsDirectory();
          final vaultDir = Directory('${appDir.path}/vault_documents');
          if (!await vaultDir.exists()) {
            await vaultDir.create(recursive: true);
          }
          final fileName = 'doc_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final targetFile = await sourceFile.copy(
            '${vaultDir.path}/$fileName',
          );
          persistentPath = targetFile.path;
        }
      } catch (e) {
        debugPrint(
          '[DocumentVaultController] Error persisting document attachment: $e',
        );
      }
    }

    final doc = MotorcycleDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bikeStableId: bikeStableId,
      title: title,
      description: description,
      imagePath: persistentPath,
      expirationDateIso: expirationDateIso,
    );

    final updatedDocs = [doc, ...state.documents];
    state = state.copyWith(documents: updatedDocs);

    final db = ref.read(dbServiceProvider);
    await db.saveDocument(doc);
  }

  Future<void> deleteDocument(String id) async {
    final updatedDocs = state.documents.where((d) => d.id != id).toList();
    state = state.copyWith(documents: updatedDocs);

    final db = ref.read(dbServiceProvider);
    await db.deleteDocument(id);
  }

  Future<void> addTaxRecord({
    required String bikeStableId,
    required String type,
    required String dueDateIso,
    required double amount,
    required String currency,
  }) async {
    final record = TaxRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bikeStableId: bikeStableId,
      type: type,
      dueDateIso: dueDateIso,
      amount: amount,
      currency: currency,
      isPaid: false,
    );

    final updatedRecords = [record, ...state.taxRecords]
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    state = state.copyWith(taxRecords: updatedRecords);

    final db = ref.read(dbServiceProvider);
    await db.saveTaxRecord(record);
  }

  Future<void> toggleTaxPaid(String id) async {
    final updatedRecords = state.taxRecords.map((r) {
      if (r.id == id) {
        final updated = r.copyWith(isPaid: !r.isPaid);
        unawaited(ref.read(dbServiceProvider).saveTaxRecord(updated));
        return updated;
      }
      return r;
    }).toList();

    state = state.copyWith(taxRecords: updatedRecords);
  }

  Future<void> deleteTaxRecord(String id) async {
    final updatedRecords = state.taxRecords.where((r) => r.id != id).toList();
    state = state.copyWith(taxRecords: updatedRecords);

    final db = ref.read(dbServiceProvider);
    await db.deleteTaxRecord(id);
  }

  /// Generates default template tax/inspection records for the bike based on chosen structure
  Future<void> generateDefaultTemplates({
    required String bikeStableId,
    required bool isTurkey,
    required String currency,
  }) async {
    final now = DateTime.now();
    final db = ref.read(dbServiceProvider);

    if (isTurkey) {
      // MTV Taksit 1 (Genelde Ocak)
      final mtv1 = TaxRecord(
        id: '${DateTime.now().millisecondsSinceEpoch}_mtv1',
        bikeStableId: bikeStableId,
        type: 'mtv_1',
        dueDateIso: DateTime(now.year, 1, 31).toIso8601String(),
        amount: 350.0,
        currency: 'TRY',
        isPaid: false,
      );

      // MTV Taksit 2 (Genelde Temmuz)
      final mtv2 = TaxRecord(
        id: '${DateTime.now().millisecondsSinceEpoch}_mtv2',
        bikeStableId: bikeStableId,
        type: 'mtv_2',
        dueDateIso: DateTime(now.year, 7, 31).toIso8601String(),
        amount: 350.0,
        currency: 'TRY',
        isPaid: false,
      );

      // Zorunlu Trafik Sigortası
      final sigorta = TaxRecord(
        id: '${DateTime.now().millisecondsSinceEpoch}_insurance',
        bikeStableId: bikeStableId,
        type: 'insurance',
        dueDateIso: now.add(const Duration(days: 365)).toIso8601String(),
        amount: 2500.0,
        currency: 'TRY',
        isPaid: false,
      );

      // Muayene (TÜVTÜRK - 2 Yılda bir)
      final muayene = TaxRecord(
        id: '${DateTime.now().millisecondsSinceEpoch}_inspection',
        bikeStableId: bikeStableId,
        type: 'inspection',
        dueDateIso: now.add(const Duration(days: 730)).toIso8601String(),
        amount: 900.0,
        currency: 'TRY',
        isPaid: false,
      );

      final newRecords = [mtv1, mtv2, sigorta, muayene];
      state = state.copyWith(
        taxRecords: [...state.taxRecords, ...newRecords]
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate)),
      );

      for (final r in newRecords) {
        await db.saveTaxRecord(r);
      }
    } else {
      // Global Template
      // Road Tax (Annual)
      final roadTax = TaxRecord(
        id: '${DateTime.now().millisecondsSinceEpoch}_roadtax',
        bikeStableId: bikeStableId,
        type: 'road_tax',
        dueDateIso: now.add(const Duration(days: 365)).toIso8601String(),
        amount: 80.0,
        currency: currency,
        isPaid: false,
      );

      // Insurance Renewal
      final insurance = TaxRecord(
        id: '${DateTime.now().millisecondsSinceEpoch}_global_insurance',
        bikeStableId: bikeStableId,
        type: 'global_insurance',
        dueDateIso: now.add(const Duration(days: 365)).toIso8601String(),
        amount: 350.0,
        currency: currency,
        isPaid: false,
      );

      // Annual Inspection
      final inspection = TaxRecord(
        id: '${DateTime.now().millisecondsSinceEpoch}_global_inspection',
        bikeStableId: bikeStableId,
        type: 'global_inspection',
        dueDateIso: now.add(const Duration(days: 365)).toIso8601String(),
        amount: 60.0,
        currency: currency,
        isPaid: false,
      );

      final newRecords = [roadTax, insurance, inspection];
      state = state.copyWith(
        taxRecords: [...state.taxRecords, ...newRecords]
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate)),
      );

      for (final r in newRecords) {
        await db.saveTaxRecord(r);
      }
    }
  }
}
