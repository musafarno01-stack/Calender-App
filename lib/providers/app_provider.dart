import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/local_store.dart';
import '../data/models.dart';

final localStoreProvider = Provider<LocalStore>(
  (ref) => LocalStore(),
);

final organizerProvider =
    StateNotifierProvider<OrganizerController, OrganizerState>(
  (ref) => OrganizerController(ref.read(localStoreProvider)),
);

class OrganizerState {
  const OrganizerState({
    this.items = const [],
    this.loading = true,
    this.error,
  });

  final List<OrganizerItem> items;
  final bool loading;
  final String? error;

  OrganizerState copyWith({
    List<OrganizerItem>? items,
    bool? loading,
    String? error,
    bool clearError = false,
  }) {
    return OrganizerState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class OrganizerController extends StateNotifier<OrganizerState> {
  OrganizerController(this._store) : super(const OrganizerState()) {
    load();
  }

  final LocalStore _store;
  final Uuid _uuid = const Uuid();

  Future<void> load() async {
    try {
      final items = await _store.loadItems();
      state = state.copyWith(items: items, loading: false, clearError: true);
    } catch (_) {
      state = state.copyWith(
        loading: false,
        error: 'Could not load saved data.',
      );
    }
  }

  Future<void> add({
    required ItemType type,
    required String title,
    String description = '',
    DateTime? dueAt,
    Priority priority = Priority.medium,
    String category = 'Personal',
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      throw ArgumentError('A title is required.');
    }

    final item = OrganizerItem(
      id: _uuid.v4(),
      type: type,
      title: cleanTitle,
      description: description.trim(),
      createdAt: DateTime.now(),
      dueAt: dueAt,
      priority: priority,
      category: category,
    );

    await _commit([...state.items, item]);
  }

  Future<void> toggle(String id) async {
    final updated = state.items.map((item) {
      return item.id == id
          ? item.copyWith(completed: !item.completed)
          : item;
    }).toList();

    await _commit(updated);
  }

  Future<void> delete(String id) async {
    await _commit(
      state.items.where((item) => item.id != id).toList(),
    );
  }

  Future<void> update(OrganizerItem replacement) async {
    final exists = state.items.any(
      (item) => item.id == replacement.id,
    );
    if (!exists) {
      throw StateError('The item no longer exists.');
    }

    await _commit(
      state.items.map(
        (item) => item.id == replacement.id ? replacement : item,
      ).toList(),
    );
  }

  Future<void> _commit(List<OrganizerItem> next) async {
    final previous = state;
    state = state.copyWith(items: next, clearError: true);

    try {
      await _store.saveItems(next);
    } catch (_) {
      state = previous.copyWith(
        error: 'Could not save changes. Please try again.',
      );
      rethrow;
    }
  }
}

final themeModeProvider = StateProvider<String>((ref) => 'system');
