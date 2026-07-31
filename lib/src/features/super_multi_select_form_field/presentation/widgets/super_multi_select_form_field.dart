// ============================================================
// features/super_multi_select_form_field/presentation/widgets/super_multi_select_form_field.dart
// ------------------------------------------------------------
// The View for the GeniusLink multi-select field. A tappable FieldBox shows the
// chosen values as removable SuperChips (or the placeholder when empty) and a
// label-right count pill; tapping opens a FieldPopover → OptionMenu of checkable
// OptionTiles that stays open across toggles. Optionally searchable. Drives a
// [SuperMultiSelectFieldController] (the Model) and builds the validator chain
// from the domain usecase. Validation surfaces only through the suffix
// ErrorBadge. Light/dark + LTR/RTL.
// ============================================================

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';
import '../../../../core/foundation/field_decoration.dart';
import '../../../../../localization/super_form_localizations.dart';
import '../../domain/usecases/multi_select_logic.dart';
import '../controllers/super_multi_select_field_controller.dart';

/// A themeable, validated multi-select dropdown on the GeniusLink foundation.
class SuperMultiSelectFormField<T> extends StatefulWidget {
  const SuperMultiSelectFormField({
    super.key,
    required this.options,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onValidity,
    this.decoration = const InputDecoration(),
    this.required = false,
    this.density = FieldDensity.comfortable,
    this.disabled = false,
    this.readOnly = false,
    this.searchable = false,
    this.searchHint = 'Search…',
    this.minSelections,
    this.maxSelections,
    this.showCount = true,
    this.emptyLabel = 'No matches',
    this.validators = const [],
    this.forceError = false,
    this.arabic = false,
    this.autofocus = true,
    this.keyboardType,
    this.inputFormatters,
    this.textDirection,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.textAlignVertical = TextAlignVertical.center,
    this.onFieldSubmitted,
    this.onTap,
    this.onTapOutside,
    this.onTapUpOutside,
    this.onEditingComplete,
    this.onSaved,
    this.onSave,
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
    this.autovalidateMode = AutovalidateMode.disabled,
  }) : assert(
         onSaved == null || onSave == null,
         'Provide either onSaved or onSave, not both.',
       );

  /// The choosable options.
  final List<SuperOption<T>> options;

  final SuperMultiSelectFieldController<T>? controller;
  final List<T>? initialValue;

  final ValueChanged<List<T>>? onChanged;
  final ValidityChanged? onValidity;

  /// Canonical source for label, helper, hint, and adornment chrome.
  final InputDecoration decoration;

  // ── chrome ──
  final bool required;
  final FieldDensity density;
  final bool disabled;
  final bool readOnly;

  // ── behaviour ──
  final bool searchable;
  final String searchHint;

  /// Lower bound on the selection count (a validator).
  final int? minSelections;

  /// Hard cap on the selection count — further picks are blocked.
  final int? maxSelections;

  /// Show the `n selected` count pill in the label-right slot.
  final bool showCount;

  final String emptyLabel;

  final List<Validator<List<T>>> validators;
  final bool forceError;
  final bool arabic;

  // ── Material-compatible interaction and search input behaviour ──
  /// Applied to the menu search editor when [searchable] is true.
  final bool autofocus;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection? textDirection;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final ValueChanged<String>? onFieldSubmitted;

  /// Called when the selection trigger is tapped.
  final GestureTapCallback? onTap;

  final void Function(PointerDownEvent event)? onTapOutside;
  final void Function(PointerUpEvent event)? onTapUpOutside;

  /// Applied to the menu search editor when [searchable] is true.
  final VoidCallback? onEditingComplete;

  /// Called with the selected values by an ancestor [Form].
  final FormFieldSetter<List<T>>? onSaved;

  /// Backward-compatible alias for [onSaved].
  final FormFieldSetter<List<T>>? onSave;

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
  final AutovalidateMode autovalidateMode;

  @override
  State<SuperMultiSelectFormField<T>> createState() =>
      _SuperMultiSelectFormFieldState<T>();
}

class _SuperMultiSelectFormFieldState<T>
    extends State<SuperMultiSelectFormField<T>> {
  late SuperMultiSelectFieldController<T> _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        SuperMultiSelectFieldController<T>(initialValue: widget.initialValue);
    _ownsController = widget.controller == null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.reportInitialValidity();
    });
  }

  @override
  void didUpdateWidget(SuperMultiSelectFormField<T> old) {
    super.didUpdateWidget(old);
    if (widget.controller != old.controller) {
      if (_ownsController) _controller.dispose();
      _controller =
          widget.controller ??
          SuperMultiSelectFieldController<T>(initialValue: widget.initialValue);
      _ownsController = widget.controller == null;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  bool get _editable => !widget.disabled && !widget.readOnly;

  void _handleTap() {
    widget.onTap?.call();
    if (!widget.readOnly) _controller.toggleMenu();
  }

  Widget _menu(SuperThemeData t) {
    final l10n = SuperFormTranslation.of(context);
    final filtered = _controller.filtered;
    return OptionMenu(
      header: widget.searchable
          ? MenuSearchField(
              controller: _controller.searchText,
              focusNode: _controller.searchFocus,
              hintText: widget.searchHint == 'Search…'
                  ? l10n.search
                  : widget.searchHint,
              arabic: widget.arabic,
              autofocus: widget.autofocus,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              textDirection: widget.textDirection,
              textInputAction: widget.textInputAction,
              textCapitalization: widget.textCapitalization,
              textAlign: widget.textAlign,
              textAlignVertical: widget.textAlignVertical,
              onSubmitted: widget.onFieldSubmitted,
              onEditingComplete: widget.onEditingComplete,
              keyboardAppearance: widget.keyboardAppearance,
              autocorrect: widget.autocorrect,
              enableSuggestions: widget.enableSuggestions,
              smartDashesType: widget.smartDashesType,
              smartQuotesType: widget.smartQuotesType,
              showCursor: widget.showCursor,
              enableInteractiveSelection: widget.enableInteractiveSelection,
              selectionControls: widget.selectionControls,
              scrollPadding: widget.scrollPadding,
              scrollPhysics: widget.scrollPhysics,
              scrollController: widget.scrollController,
              autofillHints: widget.autofillHints,
              mouseCursor: widget.mouseCursor,
              contextMenuBuilder: widget.contextMenuBuilder,
              restorationId: widget.restorationId,
              enableIMEPersonalizedLearning:
                  widget.enableIMEPersonalizedLearning,
              canRequestFocus: widget.canRequestFocus,
              clipBehavior: widget.clipBehavior,
              cursorWidth: widget.cursorWidth,
              cursorHeight: widget.cursorHeight,
              cursorRadius: widget.cursorRadius,
              cursorColor: widget.cursorColor,
              cursorErrorColor: widget.cursorErrorColor,
              style: widget.style,
              strutStyle: widget.strutStyle,
            )
          : null,
      empty: Text(
        widget.emptyLabel == 'No matches' ? l10n.noMatches : widget.emptyLabel,
        textAlign: TextAlign.center,
        style: t.textTheme.caption.copyWith(color: t.fg4),
      ),
      children: [
        for (final o in filtered)
          OptionTile(
            label: o.label,
            description: o.description,
            icon: o.icon,
            checkbox: true,
            selected: _controller.isSelected(o.value),
            // Block un-selected rows once the cap is hit.
            disabled:
                o.disabled ||
                (!_controller.isSelected(o.value) && _controller.atCapacity),
            arabic: widget.arabic,
            onTap: () => _controller.toggle(o),
          ),
      ],
    );
  }

  Widget _triggerContent(SuperThemeData t) {
    final l10n = SuperFormTranslation.of(context);
    final chosen = _controller.selectedOptions;
    if (chosen.isEmpty) {
      return SffDecoration.buildHint(
        context,
        widget.decoration,
        fallback: l10n.selectPlaceholder,
        arabic: widget.arabic,
        textDirection: widget.textDirection,
        baseStyle: t.textTheme.body.copyWith(
          color: t.fg4,
          fontFamily: widget.arabic
              ? SuperThemeData.of(context).tokens.arabicFont
              : SuperThemeData.of(context).tokens.bodyFont,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Wrap(
        spacing: SuperThemeData.of(context).spacing.space1,
        runSpacing: SuperThemeData.of(context).spacing.space1,
        children: [
          for (final o in chosen)
            SuperChip(
              label: o.label,
              arabic: widget.arabic,
              onRemove: _editable
                  ? () => _controller.removeValue(o.value)
                  : null,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SuperFormTranslation.of(context);

    return FormField<List<T>>(
      key: ObjectKey(_controller),
      initialValue: _controller.values,
      enabled: !widget.disabled,
      onSaved: widget.onSaved ?? widget.onSave,
      autovalidateMode: widget.autovalidateMode,
      validator: (_) => _controller.error,
      builder: (formState) {
        _controller.configure(
          options: widget.options,
          maxSelections: widget.maxSelections,
          validators: MultiSelectLogic.buildValidators<T>(
            required: widget.required,
            minSelections: widget.minSelections,
            maxSelections: widget.maxSelections,
            extra: widget.validators,
            requiredMessage: l10n.selectAtLeastOneOption,
            minSelectionsMessage: l10n.selectAtLeastOptions,
            maxSelectionsMessage: l10n.selectAtMostOptions,
          ),
          forceError: widget.forceError || formState.hasError,
          onValidity: widget.onValidity,
          onChanged: (values) {
            formState.didChange(values);
            widget.onChanged?.call(values);
          },
        );

        return ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final t = context.sffTheme;
            final error = widget.disabled
                ? null
                : SffDecoration.resolveError(
                    widget.decoration,
                    _controller.visibleError,
                  );

            final hasDecorationCounter =
                widget.decoration.counter != null ||
                widget.decoration.counterText != null;
            final countPill =
                (!hasDecorationCounter &&
                    widget.showCount &&
                    _controller.count > 0)
                ? CountPill(label: l10n.selectedCount(_controller.count))
                : null;

            final trailing = <Widget>[
              ...SffDecoration.buildTrailing(context, widget.decoration),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  _controller.isOpen
                      ? SffIcons.chevronUp
                      : SffIcons.chevronDown,
                  size: 18,
                  color: t.fg3,
                ),
              ),
            ];

            return FieldShell(
              decoration: widget.decoration,
              required: widget.required,
              hasError: error != null,
              arabic: widget.arabic,
              labelRight: countPill,
              child: TapRegion(
                onTapOutside: widget.onTapOutside,
                onTapUpOutside: widget.onTapUpOutside,
                child: FieldPopover(
                  open: _controller.isOpen,
                  onDismiss: _controller.close,
                  overlayBuilder: (context) => _menu(t),
                  child: MouseRegion(
                    cursor: _editable
                        ? SystemMouseCursors.click
                        : SystemMouseCursors.basic,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.disabled ? null : _handleTap,
                      child: FieldBox(
                        focused: _controller.isOpen,
                        error: error,
                        disabled: widget.disabled,
                        density: widget.density,
                        leading: SffDecoration.buildLeading(
                          context,
                          widget.decoration,
                        ),
                        trailing: trailing,
                        child: _triggerContent(t),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
