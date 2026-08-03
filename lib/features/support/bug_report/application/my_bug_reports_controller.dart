import 'package:apexflow/features/support/bug_report/data/local_bug_outbox.dart';
import 'package:apexflow/features/support/bug_report/domain/bug_report.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyBugReportsState {
  const MyBugReportsState({
    this.isLoading = false,
    this.reports = const [],
    this.error,
  });

  final bool isLoading;
  final List<BugReport> reports;
  final String? error;

  MyBugReportsState copyWith({
    bool? isLoading,
    List<BugReport>? reports,
    String? error,
  }) {
    return MyBugReportsState(
      isLoading: isLoading ?? this.isLoading,
      reports: reports ?? this.reports,
      error: error,
    );
  }
}

class MyBugReportsController extends StateNotifier<MyBugReportsState> {
  MyBugReportsController() : super(const MyBugReportsState()) {
    loadReports();
  }

  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reports = await LocalBugOutbox.getQueuedReports();
      state = state.copyWith(isLoading: false, reports: reports);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadReports();
  }
}

final myBugReportsControllerProvider =
    StateNotifierProvider<MyBugReportsController, MyBugReportsState>(
      (ref) => MyBugReportsController(),
    );
