import 'package:apexflow/core/storage/db_provider.dart';
import 'package:apexflow/core/storage/in_memory_db_service.dart';
import 'package:apexflow/documents/application/document_vault_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Document Vault State management works as expected', () async {
    final mockDb = InMemoryDbService();
    final container = ProviderContainer(
      overrides: [dbServiceProvider.overrideWithValue(mockDb)],
    );
    addTearDown(container.dispose);

    final controller = container.read(documentVaultProvider.notifier);

    // Initial state is hydrating
    expect(container.read(documentVaultProvider).isHydrating, isTrue);

    // Wait for hydration to finish
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(documentVaultProvider).isHydrating, isFalse);
    expect(container.read(documentVaultProvider).documents, isEmpty);
    expect(container.read(documentVaultProvider).taxRecords, isEmpty);

    // Add Document
    await controller.addDocument(
      bikeStableId: 'test_bike',
      title: 'License',
      description: 'Registration papers',
      imagePath: 'path/to/image.png',
      expirationDateIso: '2026-12-31T00:00:00.000Z',
    );

    var state = container.read(documentVaultProvider);
    expect(state.documents.length, 1);
    expect(state.documents.first.title, 'License');
    expect(state.documents.first.description, 'Registration papers');
    expect(state.documents.first.imagePath, 'path/to/image.png');
    expect(state.documents.first.expirationDateIso, '2026-12-31T00:00:00.000Z');

    // Add Tax Record
    await controller.addTaxRecord(
      bikeStableId: 'test_bike',
      type: 'insurance',
      dueDateIso: '2026-12-31T00:00:00.000Z',
      amount: 150.0,
      currency: 'USD',
    );

    state = container.read(documentVaultProvider);
    expect(state.taxRecords.length, 1);
    expect(state.taxRecords.first.type, 'insurance');
    expect(state.taxRecords.first.amount, 150.0);
    expect(state.taxRecords.first.isPaid, isFalse);

    // Toggle Tax Paid
    final recordId = state.taxRecords.first.id;
    await controller.toggleTaxPaid(recordId);
    state = container.read(documentVaultProvider);
    expect(state.taxRecords.first.isPaid, isTrue);

    // Generate Default Templates (Turkey)
    await controller.generateDefaultTemplates(
      bikeStableId: 'test_bike',
      isTurkey: true,
      currency: 'TRY',
    );
    state = container.read(documentVaultProvider);
    // Should add 4 records (mtv1, mtv2, insurance, inspection) + 1 existing = 5 records
    expect(state.taxRecords.length, 5);

    // Generate Default Templates (Global)
    await controller.generateDefaultTemplates(
      bikeStableId: 'test_bike',
      isTurkey: false,
      currency: 'USD',
    );
    state = container.read(documentVaultProvider);
    // Should add 3 records (road_tax, global_insurance, global_inspection) + 5 existing = 8 records
    expect(state.taxRecords.length, 8);
    expect(state.taxRecords.any((r) => r.type == 'global_insurance'), isTrue);
    expect(state.taxRecords.any((r) => r.type == 'global_inspection'), isTrue);

    // Delete Document
    final docId = state.documents.first.id;
    await controller.deleteDocument(docId);
    state = container.read(documentVaultProvider);
    expect(state.documents, isEmpty);
  });
}
