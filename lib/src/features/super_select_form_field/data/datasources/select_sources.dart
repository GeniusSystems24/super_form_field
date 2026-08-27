// ============================================================
// features/super_select_form_field/data/datasources/select_sources.dart
// ------------------------------------------------------------
// Raw data-source abstractions for SuperSelectFormField.
//
// Sources only acquire domain values. SuperSelectFormField.optionBuilder
// maps each raw T value to SuperOption<T> presentation/search metadata.
// This mirrors the source + suggestionBuilder split used by
// super_auto_suggestion_box.
// ============================================================

/// Loads raw typed values for a `SuperSelectFormField`.
///
/// Implement this abstraction when an application needs a custom source.
/// Most callers should use [SuperSelectListSource] for local data or
/// [SuperSelectRemoteSource] for asynchronously fetched data.
abstract class SuperSelectSource<T> {
  const SuperSelectSource();

  /// Resolves the raw values exposed by this source.
  Future<List<T>> load();
}

/// A source backed by an in-memory list of raw values.
class SuperSelectListSource<T> extends SuperSelectSource<T> {
  const SuperSelectListSource({required this.items});

  /// The local raw values returned by [load].
  final List<T> items;

  @override
  Future<List<T>> load() async => items;
}

/// Signature used by [SuperSelectRemoteSource] to fetch raw values.
typedef SuperSelectRemoteLoader<T> = Future<List<T>> Function();

/// A source that asynchronously resolves raw values from a remote source.
///
/// The loader is intentionally transport-agnostic. It can call REST,
/// GraphQL, gRPC, a repository, or any other application data layer.
/// Convert each returned value to `SuperOption<T>` with the field's
/// `optionBuilder`, not inside the data source.
class SuperSelectRemoteSource<T> extends SuperSelectSource<T> {
  const SuperSelectRemoteSource({required this.loader});

  /// Callback invoked whenever this source is loaded.
  final SuperSelectRemoteLoader<T> loader;

  @override
  Future<List<T>> load() => loader();
}
