// ============================================================
// features/super_select_form_field/data/datasources/select_sources.dart
// ------------------------------------------------------------
// Raw data-source abstractions for SuperSelectFormField.
//
// The API intentionally follows the source style used by
// SuperAutoSuggestionsBox: the widget consumes one source abstraction, factory
// helpers create common source strategies, sources expose raw T values, and the
// widget-owned optionBuilder creates SuperOption<T> presentation metadata.
// ============================================================

import 'dart:async';

import 'package:flutter/widgets.dart';

/// Produces raw values for [SuperSelectFormField].
///
/// Sources own data acquisition only. Display/search metadata stays in the
/// field's `optionBuilder`.
abstract class SuperSelectSource<T> {
  const SuperSelectSource();

  /// Values that can be shown and searched immediately before any async query.
  List<T> get initialItems => const [];

  /// Whether [query] may perform asynchronous/external work.
  bool get isAsync => false;

  /// Returns raw values for [query].
  ///
  /// Async sources receive the active field [BuildContext], matching the
  /// contextual fetch style used by `SuperAutoSuggestionsBox`.
  FutureOr<List<T>> query(BuildContext context, String query);
}

/// Factory facade for the built-in select source strategies.
abstract final class SuperSelectSources {
  /// Creates a synchronous in-memory source.
  static SuperSelectSource<T> list<T>(List<T> items) =>
      SuperSelectListSource<T>(items: items);

  /// Convenience source for raw String values.
  static SuperSelectSource<String> strings(List<String> items) =>
      SuperSelectListSource<String>(items: items);

  /// Creates a query-aware asynchronous source.
  ///
  /// [fetch] receives the active field context and current search query.
  /// Successful values are merged into an internal cache so previously loaded
  /// items remain available for immediate local filtering on later queries.
  static SuperSelectSource<T> async<T>(
    Future<List<T>> Function(BuildContext context, String query) fetch, {
    List<T> initialItems = const [],
  }) => SuperSelectAsyncSource<T>(fetch, initialItems: initialItems);
}

/// A source backed by an in-memory list of raw values.
class SuperSelectListSource<T> extends SuperSelectSource<T> {
  const SuperSelectListSource({required this.items});

  final List<T> items;

  @override
  List<T> get initialItems => items;

  @override
  List<T> query(BuildContext context, String query) => items;
}

/// Callback used by [SuperSelectAsyncSource].
typedef SuperSelectFetch<T> =
    Future<List<T>> Function(BuildContext context, String query);

/// Query-aware asynchronous raw-value source.
class SuperSelectAsyncSource<T> extends SuperSelectSource<T> {
  SuperSelectAsyncSource(
    this.fetch, {
    List<T> initialItems = const [],
  }) : _cache = <T>[...initialItems];

  final SuperSelectFetch<T> fetch;
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

/// Legacy zero-argument loader retained for source compatibility.
typedef SuperSelectRemoteLoader<T> = Future<List<T>> Function();

/// Legacy remote source retained for compatibility with 1.12.x-1.14.x code.
@Deprecated(
  'Use SuperSelectSources.async((context, query) => ...) instead.',
)
class SuperSelectRemoteSource<T> extends SuperSelectSource<T> {
  SuperSelectRemoteSource({required this.loader});

  final SuperSelectRemoteLoader<T> loader;
  final List<T> _cache = <T>[];

  @override
  bool get isAsync => true;

  @override
  List<T> get initialItems => List<T>.unmodifiable(_cache);

  @override
  Future<List<T>> query(BuildContext context, String query) async {
    final fetched = await loader();
    for (final item in fetched) {
      if (!_cache.contains(item)) _cache.add(item);
    }
    return List<T>.unmodifiable(_cache);
  }
}
