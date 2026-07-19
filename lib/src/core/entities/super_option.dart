// ============================================================
// core/entities/super_option.dart
// ------------------------------------------------------------
// The immutable choice descriptor shared by the option-driven fields
// (SuperSelectFormField, SuperMultiSelectFormField, SuperChoiceFormField). It is
// generic over the value type [T] so a field can carry domain values (enums,
// ids, records) while presenting a human [label]. Optional [description] /
// [icon] enrich the row; [disabled] makes the option un-pickable; [group] lets a
// menu render section headers. Lives in `core` so every feature can read it
// without importing another feature.
// ============================================================

import 'package:flutter/widgets.dart';

/// One selectable option: a domain [value] presented as a [label].
@immutable
class SuperOption<T> {
  const SuperOption({
    required this.value,
    required this.label,
    this.description,
    this.icon,
    this.disabled = false,
    this.group,
  });

  /// The underlying domain value carried when this option is chosen.
  final T value;

  /// The human-readable label shown in the field and the menu.
  final String label;

  /// A secondary line shown beneath [label] in the menu (e.g. a code, a hint).
  final String? description;

  /// An optional leading glyph (use `SffIcons.*`).
  final IconData? icon;

  /// When true the option renders dimmed and cannot be selected.
  final bool disabled;

  /// Optional section name — menus group consecutive options under a header.
  final String? group;

  /// Convenience to build a list of options from `value → label` pairs.
  static List<SuperOption<V>> fromMap<V>(Map<V, String> entries) => entries
      .entries
      .map((e) => SuperOption<V>(value: e.key, label: e.value))
      .toList();

  @override
  bool operator ==(Object other) =>
      other is SuperOption<T> && other.value == value && other.label == label;

  @override
  int get hashCode => Object.hash(value, label);
}
