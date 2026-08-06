import 'dart:convert';

import 'package:apexflow/core/storage/apex_kv_store.dart';
import 'package:apexflow/insights/application/insights_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ApexKvStore.init(useFallback: true);
  });

  test('manual cost entries are persisted', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(insightsStateProvider.notifier)
        .addCostEntry(
          label: 'Chain service',
          category: 'Service',
          amountTry: 750,
        );

    final savedState = container.read(insightsStateProvider);
    expect(savedState.costLedger.first.label, 'Chain service');
    expect(savedState.costLedger.first.amountTry, 750);

    final raw = await ApexKvStore.getString('insights.state.v1');
    final json = jsonDecode(raw!) as Map<String, dynamic>;
    expect(json['manualCostLedger'], hasLength(1));
  });

  test('invalid manual cost entries are rejected', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container
          .read(insightsStateProvider.notifier)
          .addCostEntry(label: '', category: 'Other', amountTry: 0),
      throwsArgumentError,
    );
  });
}
