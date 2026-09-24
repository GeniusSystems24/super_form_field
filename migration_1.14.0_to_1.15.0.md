# Migration: 1.14.0 to 1.15.0

Version `1.15.0` introduces a source-oriented API for
`SuperSelectFormField<T>` and `SuperMultiSelectFormField<T>`, following the same
general separation used by `SuperAutoSuggestionsBox`:

- the field receives one `source`;
- the source returns raw `T` values;
- `optionBuilder` converts raw values into `SuperOption<T>`;
- local values remain available immediately;
- debounce applies only to asynchronous/external loading.

The existing single-select `sources` API and multi-select `options` API remain
available temporarily as deprecated compatibility APIs, but new code should use
the new source model.

## SuperSelectFormField

### Replace `sources` with `source`

Before:

```dart
SuperSelectFormField<String>(
  searchable: true,
  sources: const [
    SuperSelectListSource<String>(
      items: ['Cash', 'Bank', 'Inventory'],
    ),
  ],
  optionBuilder: (items, index, value) => SuperOption(
    value: value,
    label: value,
  ),
);
```

After:

```dart
SuperSelectFormField<String>(
  searchable: true,
  source: SuperSelectSources.list(
    ['Cash', 'Bank', 'Inventory'],
  ),
  optionBuilder: (items, index, value) => SuperOption(
    value: value,
    label: value,
  ),
);
```

`SuperSelectFormField<T>` now expects one source instead of a list of sources.

## SuperSelectSources

Use the new factory API for common source strategies.

### Local list

```dart
final source = SuperSelectSources.list<Customer>(
  customers,
);
```

Usage:

```dart
SuperSelectFormField<Customer>(
  source: source,
  optionBuilder: (items, index, customer) => SuperOption(
    value: customer,
    label: customer.name,
  ),
);
```

### String list

For simple string values:

```dart
final source = SuperSelectSources.strings(
  ['Cash', 'Bank', 'Inventory'],
);
```

```dart
SuperSelectFormField<String>(
  source: source,
  optionBuilder: (items, index, value) => SuperOption(
    value: value,
    label: value,
  ),
);
```

### Async source

Remote callbacks now use the active field `BuildContext` and current query.

```dart
final source = SuperSelectSources.async<Warehouse>(
  (context, query) => repository.searchWarehouses(query),
);
```

Usage:

```dart
SuperSelectFormField<Warehouse>(
  searchable: true,
  source: source,
  debounce: const Duration(milliseconds: 300),
  minChars: 2,
  optionBuilder: (items, index, warehouse) => SuperOption(
    value: warehouse,
    label: warehouse.name,
  ),
);
```

## Async callback signature

If you previously used a custom async select source with a callback shaped like:

```dart
(query) => repository.search(query)
```

update it to:

```dart
(context, query) => repository.search(query)
```

The `BuildContext` is the active field context and may be used when an inherited
value is genuinely required, such as localization or an application provider.

Prefer keeping repositories independent from UI context when possible.

## initialItems

Async sources may be seeded with values already available locally:

```dart
final source = SuperSelectSources.async<Customer>(
  (context, query) => repository.searchCustomers(query),
  initialItems: cachedCustomers,
);
```

These values are available immediately before another external request is
started.

## debounce behavior

`debounce` now applies to asynchronous source work rather than delaying locally
available values.

```dart
SuperSelectFormField<Customer>(
  searchable: true,
  source: SuperSelectSources.async<Customer>(
    (context, query) => repository.searchCustomers(query),
    initialItems: cachedCustomers,
  ),
  debounce: const Duration(milliseconds: 400),
  optionBuilder: (items, index, customer) => SuperOption(
    value: customer,
    label: customer.name,
  ),
);
```

The intended flow is:

```text
query changes
    |
    v
use/filter locally available values
    |
    v
check minChars
    |
    v
wait for debounce
    |
    v
run external source query
```

## minChars

Use `minChars` to prevent external source queries until the trimmed search query
reaches a minimum length.

```dart
SuperSelectFormField<Customer>(
  searchable: true,
  source: source,
  minChars: 2,
  debounce: const Duration(milliseconds: 300),
  optionBuilder: customerOptionBuilder,
);
```

With `minChars: 2`, an external fetch does not run for an empty query or a
single-character query.

## SuperMultiSelectFormField

`SuperMultiSelectFormField<T>` now supports the same source pattern.

### Replace `options` with `source` and `optionBuilder`

Before:

```dart
SuperMultiSelectFormField<String>(
  options: const [
    SuperOption(value: 'read', label: 'Read'),
    SuperOption(value: 'create', label: 'Create'),
    SuperOption(value: 'update', label: 'Update'),
  ],
);
```

After:

```dart
SuperMultiSelectFormField<String>(
  source: SuperMultiSelectSources.list(
    ['read', 'create', 'update'],
  ),
  optionBuilder: (items, index, value) => SuperOption(
    value: value,
    label: value,
  ),
);
```

The source now owns raw data while `optionBuilder` owns presentation metadata.

## SuperMultiSelectSources

### Local list

```dart
final source = SuperMultiSelectSources.list<User>(
  users,
);
```

```dart
SuperMultiSelectFormField<User>(
  source: source,
  optionBuilder: (items, index, user) => SuperOption(
    value: user,
    label: user.name,
  ),
);
```

### String list

```dart
final source = SuperMultiSelectSources.strings(
  ['read', 'create', 'update', 'delete'],
);
```

### Async source

```dart
final source = SuperMultiSelectSources.async<User>(
  (context, query) => repository.searchUsers(query),
  initialItems: cachedUsers,
);
```

```dart
SuperMultiSelectFormField<User>(
  searchable: true,
  source: source,
  debounce: const Duration(milliseconds: 300),
  minChars: 2,
  optionBuilder: (items, index, user) => SuperOption(
    value: user,
    label: user.name,
    description: user.email,
  ),
);
```

## Raw values vs SuperOption

In `1.14.0`, multi-select code commonly supplied prebuilt
`SuperOption<T>` objects directly.

In `1.15.0`, prefer supplying raw values to the source:

```dart
SuperMultiSelectSources.list(users)
```

and construct `SuperOption<T>` only in `optionBuilder`:

```dart
optionBuilder: (items, index, user) => SuperOption(
  value: user,
  label: user.name,
)
```

This keeps data acquisition independent from presentation.

## SuperChoiceFormField is unchanged

`SuperChoiceFormField<T>` does **not** use the new select-source API.

Continue using `options`:

```dart
SuperChoiceFormField<String>(
  options: const [
    SuperOption(value: 'draft', label: 'Draft'),
    SuperOption(value: 'posted', label: 'Posted'),
  ],
);
```

Do not replace its `options` parameter with `source` or `optionBuilder`.

## Compatibility APIs

The old APIs remain temporarily available for compatibility:

```dart
SuperSelectFormField<T>(
  sources: [...],
)
```

and:

```dart
SuperMultiSelectFormField<T>(
  options: [...],
)
```

They are deprecated in `1.15.0`.

Prefer migrating now so future removal of those compatibility APIs does not
require another application-wide update.

## Complete single-select migration example

Before:

```dart
SuperSelectFormField<Account>(
  searchable: true,
  sources: [
    SuperSelectListSource<Account>(
      items: cachedAccounts,
    ),
  ],
  optionBuilder: (items, index, account) => SuperOption(
    value: account,
    label: account.name,
  ),
);
```

After:

```dart
SuperSelectFormField<Account>(
  searchable: true,
  source: SuperSelectSources.list(
    cachedAccounts,
  ),
  optionBuilder: (items, index, account) => SuperOption(
    value: account,
    label: account.name,
  ),
);
```

For server-backed search:

```dart
SuperSelectFormField<Account>(
  searchable: true,
  source: SuperSelectSources.async<Account>(
    (context, query) => repository.searchAccounts(query),
    initialItems: cachedAccounts,
  ),
  debounce: const Duration(milliseconds: 300),
  minChars: 2,
  optionBuilder: (items, index, account) => SuperOption(
    value: account,
    label: account.name,
  ),
);
```

## Complete multi-select migration example

Before:

```dart
SuperMultiSelectFormField<Permission>(
  searchable: true,
  options: permissions
      .map(
        (permission) => SuperOption(
          value: permission,
          label: permission.name,
        ),
      )
      .toList(),
);
```

After:

```dart
SuperMultiSelectFormField<Permission>(
  searchable: true,
  source: SuperMultiSelectSources.list(
    permissions,
  ),
  optionBuilder: (items, index, permission) => SuperOption(
    value: permission,
    label: permission.name,
  ),
);
```

For remote search:

```dart
SuperMultiSelectFormField<User>(
  searchable: true,
  source: SuperMultiSelectSources.async<User>(
    (context, query) => repository.searchUsers(query),
    initialItems: cachedUsers,
  ),
  debounce: const Duration(milliseconds: 300),
  minChars: 2,
  optionBuilder: (items, index, user) => SuperOption(
    value: user,
    label: user.name,
    description: user.email,
  ),
);
```

## Migration checklist

1. Replace `SuperSelectFormField.sources` with `source`.
2. Replace lists of `SuperSelectSource<T>` with one
   `SuperSelectSource<T>`.
3. Prefer `SuperSelectSources.list`, `strings`, or `async`.
4. Update async callbacks to `(context, query)`.
5. Review `debounce` knowing it applies to external async work.
6. Configure `minChars` for server-backed searchable fields where appropriate.
7. Replace `SuperMultiSelectFormField.options` with `source`.
8. Add `optionBuilder` to migrated multi-select fields.
9. Prefer `SuperMultiSelectSources.list`, `strings`, or `async`.
10. Keep `SuperChoiceFormField.options` unchanged.
11. Update examples and tests that still use deprecated `sources` or `options`.
12. Remove deprecated compatibility usage once the application has migrated.
