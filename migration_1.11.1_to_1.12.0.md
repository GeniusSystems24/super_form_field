# Migration: super_form_field 1.11.1 → 1.12.0

Version 1.12.0 changes `SuperSelectFormField<T>` to a source-driven API
modeled after the source + builder split used by `super_auto_suggestion_box`.

## What changed

`SuperSelectFormField<T>.options` has been removed.

`SuperSelectFormField<T>` now requires:

- `sources` — one or more `SuperSelectSource<T>` instances that return raw
  `T` values.
- `optionBuilder` — converts each raw value into `SuperOption<T>` metadata.

The builder signature is:

```dart
typedef SuperSelectOptionBuilder<T> =
    SuperOption<T> Function(List<T> items, int index, T element);
```

Source types:

- `SuperSelectListSource<T>(items: ...)` — local in-memory raw values.
- `SuperSelectRemoteSource<T>(loader: ...)` — asynchronously loaded raw values.

## Migrate a direct options list

Before 1.12.0:

```dart
SuperSelectFormField<String>(
  decoration: const InputDecoration(labelText: 'Status'),
  options: const [
    SuperOption(value: 'open', label: 'Open'),
    SuperOption(value: 'closed', label: 'Closed'),
  ],
);
```

After 1.12.0:

```dart
SuperSelectFormField<String>(
  decoration: const InputDecoration(labelText: 'Status'),
  sources: const [
    SuperSelectListSource<String>(items: ['open', 'closed']),
  ],
  optionBuilder: (items, index, item) => SuperOption(
    value: item,
    label: item == 'open' ? 'Open' : 'Closed',
  ),
);
```

## Load remote domain objects

Sources should return domain objects directly. Do not map them to
`SuperOption<T>` inside the repository or source loader.

```dart
SuperSelectFormField<Warehouse>(
  decoration: const InputDecoration(
    labelText: 'Warehouse',
    hintText: 'Choose a warehouse',
  ),
  searchable: true,
  sources: [
    SuperSelectRemoteSource<Warehouse>(
      loader: repository.fetchWarehouses,
    ),
  ],
  optionBuilder: (items, index, warehouse) => SuperOption(
    value: warehouse,
    label: warehouse.name,
    description: warehouse.code,
  ),
);
```

## Multiple sources

Results from successful sources are merged in the same order as `sources`.
`optionBuilder` receives the complete merged raw list, the global index, and
the corresponding element.

```dart
SuperSelectFormField<String>(
  sources: [
    const SuperSelectListSource<String>(items: ['all']),
    SuperSelectRemoteSource<String>(loader: repository.loadWarehouseIds),
  ],
  optionBuilder: (items, index, item) => SuperOption(
    value: item,
    label: item == 'all' ? 'All warehouses' : repository.labelFor(item),
  ),
);
```

## Loading and errors

Sources load when the field is mounted. If the `sources` list instance changes,
the field reloads them.

While the menu has no resolved items and sources are still loading, it shows a
compact progress indicator. A source failure is reported through
`FlutterError.reportError`; successful source results remain available.

## Controller behavior

`SuperSelectFieldController<T>` still owns selection, search filtering,
validation, fixed-state behavior, and menu state. Its value remains `T?`.

## Checklist

- Update `super_form_field` to `^1.12.0`.
- Replace every `SuperSelectFormField.options` usage with `sources`.
- Use `SuperSelectListSource<T>(items: ...)` for local values.
- Use `SuperSelectRemoteSource<T>(loader: ...)` for asynchronous values.
- Return raw `List<T>` values from source loaders.
- Add `optionBuilder` to map each raw value to `SuperOption<T>`.
- Keep networking in the repository/application data layer.
