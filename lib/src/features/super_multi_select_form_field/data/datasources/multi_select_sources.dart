// ============================================================
// features/super_multi_select_form_field/data/datasources/multi_select_sources.dart
// ------------------------------------------------------------
// Raw data-source abstractions for SuperMultiSelectFormField.
//
// The contract mirrors SuperSelectSources and the source style used by
// SuperAutoSuggestionsBox: sources return raw T values and the widget maps them
// to SuperOption<T> metadata with optionBuilder.
// ============================================================

import 'dart:async';

import 'package:flutter/widgets.dart';

/// Produces raw values for [SuperMultiSelectFormField].
abstract class SuperMultiSelectSource<T> {
  const SuperMultiSelectSource();

  /// Values available immediately before an async query completes.
  List<T> get initialItems => const [];

  /// Whether [query] may perform asynchronous/external work.
  bool get isAsync => false;

  /// Returns raw values for the current menu search [query].
  FutureOr<List<T>> query(BuildContext context, String query);
}

/// Factory facade for built-in multi-select source strategies.
abstract final class SuperMultiSelectSources {
  /// Creates a synchronous in-memory source.
  static SuperMultiSelectSource<T> list<T>(List<T> items) =>
      SuperMultiSelectListSource<T>(items: items);

  /// Convenience source for String values.
  static SuperMultiSelectSource<String> strings(List<String> items) =>
      SuperMultiSelectListSource<String>(items: items);

  /// Creates a query-aware asynchronous source.
  ///
  /// Successful results are cached so earlier values stay available for local
  /// filtering and selected-chip resolution.
  static SuperMultiSelectSource<T> async<T>(
    Future<List<T>> Function(BuildContext context, String query) fetch, {
    List<T> initialItems = const [],
  }) => SuperMultiSelectAsyncSource<T>(fetch, initialItems: initialItems);
}

/// In-memory raw-value source.
class SuperMultiSelectListSource<T> extends SuperMultiSelectSource<T> {
  const SuperMultiSelectListSource({required this.items});

  final List<T> items;

  @override
  List<T> get initialItems => items;

  @override
  List<T> query(BuildContext context, String query) => items;
}

/// Callback used by [SuperMultiSelectAsyncSource].
typedef SuperMultiSelectFetch<T> =
    Future<List<T>> Function(BuildContext context, String query);

/// Query-aware asynchronous raw-value source with a retained cache.
class SuperMultiSelectAsyncSource<T> extends SuperMultiSelectSource<T> {
  SuperMultiSelectAsyncSource(
    this.fetch, {
    List<T> initialItems = const [],
  }) : _cache = <T>[...initialItems];

  final SuperMultiSelectFetch<T> fetch;
  final List<T> _cache;

  @override
  bool get isAsync => true;

  @override
  List<T> get initialItems => List<T>.unmodifiable(_cache);

  @override
  Future<List<T>> query(BuildContext context, String query) async {
    final fetched = await fetch(context, query);
    for (final item in fetched) {
      if (!_cache.contains(item)) _cache.add(item);
    }
    return List<T>.unmodifiable(_cache);
  }
}
