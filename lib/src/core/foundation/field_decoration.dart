// ============================================================
// core/foundation/field_decoration.dart
// ------------------------------------------------------------
// Shared InputDecoration resolution for Super form fields. The public fields
// accept one InputDecoration; this adapter maps its Material slots onto the
// GeniusLink external label/helper shell and custom FieldBox composition.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart' hide FieldDensity, FieldShell;

/// Internal helpers that apply [InputDecoration] consistently to custom fields.
abstract final class SffDecoration {
  /// Merges caller styling over the package design-system default.
  static TextStyle mergeStyle(TextStyle base, TextStyle? customStyle) =>
      customStyle == null ? base : base.merge(customStyle);

  /// Builds the external uppercase label used by `FieldShell`.
  static Widget? buildLabel(
    BuildContext context,
    InputDecoration decoration, {
    required bool required,
    required bool arabic,
    String? legacyLabel,
  }) {
    final customLabel = decoration.label;
    final text = decoration.labelText ?? legacyLabel;
    if (customLabel == null && text == null) return null;

    final tokens = SuperThemeData.of(context).tokens;
    final theme = SuperThemeData.of(context);
    final style = mergeStyle(
      SuperText.label.copyWith(
        color: theme.fg2,
        fontFamily: arabic ? tokens.arabicFont : tokens.bodyFont,
      ),
      decoration.labelStyle,
    );

    if (customLabel != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: DefaultTextStyle.merge(style: style, child: customLabel),
          ),
          if (required)
            Text(
              ' *',
              style: style.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
        ],
      );
    }

    if (!required) {
      return Text(text!.toUpperCase(), style: style);
    }

    return Text.rich(
      TextSpan(
        text: text!.toUpperCase(),
        style: style,
        children: [
          TextSpan(
            text: ' *',
            style: style.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds helper content under the control. Validation errors suppress it.
  static Widget? buildHelper(
    BuildContext context,
    InputDecoration decoration, {
    required bool arabic,
    String? legacyHint,
  }) {
    final customHelper = decoration.helper;
    final text = decoration.helperText ?? legacyHint;
    if (customHelper == null && text == null) return null;

    final tokens = SuperThemeData.of(context).tokens;
    final theme = SuperThemeData.of(context);
    final style = mergeStyle(
      SuperText.caption.copyWith(
        color: theme.fg4,
        fontFamily: arabic ? tokens.arabicFont : tokens.bodyFont,
      ),
      decoration.helperStyle,
    );

    if (customHelper != null) {
      return DefaultTextStyle.merge(style: style, child: customHelper);
    }

    return Text(
      text!,
      maxLines: decoration.helperMaxLines,
      overflow: decoration.helperMaxLines == null
          ? null
          : TextOverflow.ellipsis,
      style: style,
    );
  }

  /// Builds a caller-supplied counter for the label-right slot.
  static Widget? buildCounter(
    BuildContext context,
    InputDecoration decoration, {
    required bool arabic,
  }) {
    final customCounter = decoration.counter;
    final text = decoration.counterText;
    if (customCounter == null && (text == null || text.isEmpty)) return null;

    final tokens = SuperThemeData.of(context).tokens;
    final theme = SuperThemeData.of(context);
    final style = mergeStyle(
      SuperText.mono.copyWith(
        color: theme.fg4,
        fontSize: 11,
        fontFamily: arabic ? tokens.arabicFont : tokens.monoFont,
      ),
      decoration.counterStyle,
    );

    if (customCounter != null) {
      return DefaultTextStyle.merge(style: style, child: customCounter);
    }
    return Text(text!, style: style);
  }

  /// Builds the hint for custom, non-TextField controls.
  static Widget buildHint(
    BuildContext context,
    InputDecoration decoration, {
    required String fallback,
    required bool arabic,
    TextStyle? baseStyle,
    int maxLines = 1,
  }) {
    final theme = SuperThemeData.of(context);
    final tokens = theme.tokens;
    final style = mergeStyle(
      baseStyle ??
          SuperText.body.copyWith(
            color: theme.fg4,
            fontFamily: arabic ? tokens.arabicFont : tokens.bodyFont,
          ),
      decoration.hintStyle,
    );

    if (decoration.hint != null) {
      return DefaultTextStyle.merge(style: style, child: decoration.hint!);
    }

    return Text(
      decoration.hintText ?? fallback,
      maxLines: maxLines,
      overflow: maxLines == 1 ? TextOverflow.ellipsis : null,
      textAlign: arabic ? TextAlign.right : TextAlign.left,
      style: style,
    );
  }

  /// Resolves `icon`, `prefixIcon`, `prefix`, and `prefixText` into one slot.
  static Widget? buildLeading(
    BuildContext context,
    InputDecoration decoration, {
    Widget? fallback,
    TextStyle? textStyle,
  }) {
    final theme = SuperThemeData.of(context);
    final baseStyle = textStyle ?? SuperText.body.copyWith(color: theme.fg3);
    final hasExplicitLeading =
        decoration.icon != null ||
        decoration.prefixIcon != null ||
        decoration.prefix != null ||
        decoration.prefixText != null;
    final widgets = <Widget>[
      if (decoration.icon != null && !_suppressesSlot(decoration.icon!))
        _iconSlot(
          decoration.icon!,
          color: decoration.iconColor ?? theme.fg4,
        ),
      if (decoration.prefixIcon != null &&
          !_suppressesSlot(decoration.prefixIcon!))
        _iconSlot(
          decoration.prefixIcon!,
          color: decoration.prefixIconColor ?? theme.fg4,
          constraints: decoration.prefixIconConstraints,
        ),
      if (decoration.prefix != null && !_suppressesSlot(decoration.prefix!))
        DefaultTextStyle.merge(
          style: mergeStyle(baseStyle, decoration.prefixStyle),
          child: decoration.prefix!,
        ),
      if (decoration.prefixText != null)
        Text(
          decoration.prefixText!,
          style: mergeStyle(baseStyle, decoration.prefixStyle),
        ),
    ];
    if (widgets.isEmpty && fallback != null && !hasExplicitLeading) {
      widgets.add(_iconSlot(fallback, color: theme.fg4));
    }
    return _pack(context, widgets);
  }

  /// Resolves `suffix`, `suffixText`, and `suffixIcon` for a FieldBox.
  static List<Widget> buildTrailing(
    BuildContext context,
    InputDecoration decoration, {
    TextStyle? textStyle,
  }) {
    final theme = SuperThemeData.of(context);
    final baseStyle = textStyle ?? SuperText.body.copyWith(color: theme.fg3);
    return <Widget>[
      if (decoration.suffix != null)
        DefaultTextStyle.merge(
          style: mergeStyle(baseStyle, decoration.suffixStyle),
          child: decoration.suffix!,
        ),
      if (decoration.suffixText != null)
        Text(
          decoration.suffixText!,
          style: mergeStyle(baseStyle, decoration.suffixStyle),
        ),
      if (decoration.suffixIcon != null)
        _iconSlot(
          decoration.suffixIcon!,
          color: decoration.suffixIconColor ?? theme.fg4,
          constraints: decoration.suffixIconConstraints,
        ),
    ];
  }

  /// External error text participates in the package badge-based error UX.
  static String? resolveError(
    InputDecoration decoration,
    String? validationError,
  ) => decoration.errorText ?? validationError;

  static bool _suppressesSlot(Widget widget) =>
      widget is SizedBox &&
      widget.child == null &&
      widget.width == 0 &&
      widget.height == 0;

  static Widget _iconSlot(
    Widget child, {
    required Color color,
    BoxConstraints? constraints,
  }) {
    Widget result = IconTheme.merge(
      data: IconThemeData(size: 16, color: color),
      child: child,
    );
    if (constraints != null) {
      result = ConstrainedBox(constraints: constraints, child: result);
    }
    return result;
  }

  static Widget? _pack(BuildContext context, List<Widget> widgets) {
    if (widgets.isEmpty) return null;
    if (widgets.length == 1) return widgets.single;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widgets.length; i++) ...[
          if (i > 0) SizedBox(width: SuperThemeData.of(context).tokens.space1),
          widgets[i],
        ],
      ],
    );
  }
}
