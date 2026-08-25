// ============================================================
// core/foundation/menu_search_field.dart
// ------------------------------------------------------------
// The slim search box pinned at the top of a searchable OptionMenu. A borderless
// row (leading magnifier + text input) divided from the list by a hairline. Kept
// separate from FieldBox: it is menu chrome, not a standalone control.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
import 'package:flutter/services.dart';

import '../extensions/context_extensions.dart';
import 'package:super_core/super_core.dart' hide FieldShell, FieldDensity;
import 'sff_icon.dart';

/// A compact search input for the top of an option menu.
class MenuSearchField extends StatelessWidget {
  const MenuSearchField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText = 'Search…',
    this.onChanged,
    this.arabic = false,
    this.autofocus = true,
    this.keyboardType,
    this.inputFormatters,
    this.textDirection,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.textAlignVertical = TextAlignVertical.center,
    this.onSubmitted,
    this.onEditingComplete,
    this.keyboardAppearance,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.showCursor,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.scrollPadding = const EdgeInsets.all(20),
    this.scrollPhysics,
    this.scrollController,
    this.autofillHints,
    this.mouseCursor,
    this.contextMenuBuilder,
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
    this.canRequestFocus = true,
    this.clipBehavior = Clip.hardEdge,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.cursorErrorColor,
    this.style,
    this.strutStyle,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final bool arabic;

  /// Text-input options forwarded to the search editor.
  final bool autofocus;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection? textDirection;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final Brightness? keyboardAppearance;
  final bool autocorrect;
  final bool enableSuggestions;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool? showCursor;
  final bool enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final EdgeInsets scrollPadding;
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;
  final Iterable<String>? autofillHints;
  final MouseCursor? mouseCursor;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final String? restorationId;
  final bool enableIMEPersonalizedLearning;
  final bool canRequestFocus;
  final Clip clipBehavior;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final Color? cursorErrorColor;
  final TextStyle? style;
  final StrutStyle? strutStyle;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    final effectiveTextDirection =
        textDirection ?? Directionality.maybeOf(context) ?? TextDirection.ltr;

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        SuperThemeData.of(context).spacing.space3,
        SuperThemeData.of(context).spacing.space1,
        SuperThemeData.of(context).spacing.space2,
        SuperThemeData.of(context).spacing.space1,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          Icon(SffIcons.search, size: 16, color: t.fg4),
          SizedBox(width: SuperThemeData.of(context).spacing.space2),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              textDirection: effectiveTextDirection,
              textInputAction: textInputAction,
              textCapitalization: textCapitalization,
              textAlign: textAlign,
              textAlignVertical: textAlignVertical,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              onEditingComplete: onEditingComplete,
              keyboardAppearance: keyboardAppearance,
              autocorrect: autocorrect,
              enableSuggestions: enableSuggestions,
              smartDashesType: smartDashesType,
              smartQuotesType: smartQuotesType,
              showCursor: showCursor,
              enableInteractiveSelection: enableInteractiveSelection,
              selectionControls: selectionControls,
              scrollPadding: scrollPadding,
              scrollPhysics: scrollPhysics,
              scrollController: scrollController,
              autofillHints: autofillHints,
              mouseCursor: mouseCursor,
              contextMenuBuilder: contextMenuBuilder,
              restorationId: restorationId,
              enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
              canRequestFocus: canRequestFocus,
              clipBehavior: clipBehavior,
              cursorWidth: cursorWidth,
              cursorHeight: cursorHeight,
              cursorRadius: cursorRadius,
              cursorColor: cursorColor ?? cs.primary,
              cursorErrorColor: cursorErrorColor ?? cs.error,
              style: style == null
                  ? context.sffTextTheme.body.copyWith(
                      color: t.fg1,
                      fontSize: 13.5,
                      fontFamily: arabic
                          ? SuperThemeData.of(context).tokens.arabicFont
                          : null,
                    )
                  : context.sffTextTheme.body
                        .copyWith(
                          color: t.fg1,
                          fontSize: 13.5,
                          fontFamily: arabic
                              ? SuperThemeData.of(context).tokens.arabicFont
                              : null,
                        )
                        .merge(style),
              strutStyle: strutStyle,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: context.sffTextTheme.body.copyWith(
                  color: t.fg4,
                  fontSize: 13.5,
                  fontFamily: arabic
                      ? SuperThemeData.of(context).tokens.arabicFont
                      : null,
                ),
                hintTextDirection: effectiveTextDirection,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
