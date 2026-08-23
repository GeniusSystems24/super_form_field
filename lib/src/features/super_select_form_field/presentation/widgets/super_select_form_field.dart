// ============================================================
// features/super_select_form_field/presentation/widgets/super_select_form_field.dart
// ------------------------------------------------------------
// The View for the GeniusLink single-select field. A thin Flutter wrapper that
// builds the validator chain (domain usecase), drives a
// [SuperSelectFieldController] (the Model), and renders the FieldShell + a
// tappable FieldBox trigger that opens a FieldPopover → OptionMenu of
// OptionTiles. Optionally searchable (a MenuSearchField filters the list).
// Validation surfaces only through the suffix ErrorBadge. Light/dark + LTR/RTL.
// ============================================================

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';
import '../../../../core/foundation/field_decoration.dart';
import '../../../../../localization/super_form_localizations.dart';
import '../../domain/usecases/select_logic.dart';
import '../controllers/super_select_field_controller.dart';

/// A themeable, validated single-select dropdown on the GeniusLink foundation.
class SuperSelectFormField<T> extends StatefulWidget {
  const SuperSelectFormField({
    super.key,
    required this.options,
    this.controller,
    this.allowFixed = false,
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
    this.clearable = false,
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

  /// External controller — when null, the field manages its own.
  final SuperSelectFieldController<T>? controller;

  /// Shows a compact lock/unlock action on the label row.
  ///
  /// The action toggles the controller's `isFixed` notifier. Fixed fields keep
  /// normal contrast while blocking user and controller-driven mutations.
  final bool allowFixed;

  /// Seed value, used only when [controller] is null.
  final T? initialValue;

  final ValueChanged<T?>? onChanged;
  final ValidityChanged? onValidity;

  /// Canonical source for label, helper, hint, and adornment chrome.
  final InputDecoration decoration;

  // ── chrome ──
  final bool required;
  final FieldDensity density;
  final bool disabled;
  final bool readOnly;

  // ── behaviour ──
  /// Show a search box at the top of the menu that filters the options.
  final bool searchable;
  final String searchHint;

  /// Show a × to clear the selection while non-empty, enabled & editable.
  final bool clearable;

  /// Shown in the menu when the search filters everything out.
  final String emptyLabel;

  /// Extra custom validators, appended to the built-in chain.
  final List<Validator<T?>> validators;

  /// Force the error to display even before the field is touched.
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

  /// Called with the selected value by an ancestor [Form].
  final FormFieldSetter<T?>? onSaved;

  /// Backward-compatible alias for [onSaved].
  final FormFieldSetter<T?>? onSave;

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
  State<SuperSelectFormField<T>> createState() =>
      _SuperSelectFormFieldState<T>();
}

class _SuperSelectFormFieldState<T> extends State<SuperSelectFormField<T>> {
  late SuperSelectFieldController<T> _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        SuperSelectFieldController<T>(initialValue: widget.initialValue);
    _ownsController = widget.controller == null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.reportInitialValidity();
    });
  }

  @override
  void didUpdateWidget(SuperSelectFormField<T> old) {
    super.didUpdateWidget(old);
    if (widget.controller != old.controller) {
      if (_ownsController) _controller.dispose();
      _controller =
          widget.controller ??
          SuperSelectFieldController<T>(initialValue: widget.initialValue);
      _ownsController = widget.controller == null;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  bool get _editable =>
      !widget.disabled && !widget.readOnly && !_controller.isFixed.value;

  void _handleTap() {
    widget.onTap?.call();
    if (!widget.readOnly) _controller.toggle();
  }

  Widget _menu(SuperThemeData t) {
    if (_controller.isHiden) return const SizedBox.shrink();
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
        style: context.sffTextTheme.caption.copyWith(color: t.fg4),
      ),
      children: [
        for (final o in filtered)
          OptionTile(
            label: o.label,
            description: o.description,
            icon: o.icon,
            selected: o.value == _controller.value,
            disabled: o.disabled,
            arabic: widget.arabic,
            onTap: () => _controller.select(o),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SuperFormTranslation.of(context);

    return FormField<T?>(
      key: _controller.formFieldKey ?? ObjectKey(_controller),
      initialValue: _controller.value,
      enabled: !widget.disabled,
      onSaved: widget.onSaved ?? widget.onSave,
      autovalidateMode: widget.autovalidateMode,
      validator: (_) => _controller.error,
      builder: (formState) {
        _controller.configure(
          options: widget.options,
          validators: SelectLogic.buildValidators<T>(
            required: widget.required,
            extra: widget.validators,
            requiredMessage: l10n.selectOption,
          ),
          forceError: widget.forceError || formState.hasError,
          onValidity: widget.onValidity,
          onChanged: (value) {
            formState.didChange(value);
            widget.onChanged?.call(value);
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
            final selected = _controller.selectedOption;

            final trailing = <Widget>[
              ...SffDecoration.buildTrailing(context, widget.decoration),
              if (widget.clearable && selected != null && _editable)
                FieldIconButton(
                  icon: SffIcons.clear,
                  tooltip: l10n.clear,
                  onPressed: _controller.clear,
                ),
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
              allowFixed: widget.allowFixed,
              isFixed: _controller.isFixed,
              decoration: widget.decoration,
              required: widget.required,
              hasError: error != null,
              arabic: widget.arabic,
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
                          fallback: selected?.icon != null
                              ? Icon(selected!.icon)
                              : null,
                        ),
                        trailing: trailing,
                        child: selected != null
                            ? Text(
                                selected.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.sffTextTheme.body.copyWith(
                                  color: t.fg1,
                                  fontFamily: widget.arabic
                                      ? SuperThemeData.of(
                                          context,
                                        ).tokens.arabicFont
                                      : null,
                                ),
                                textAlign: TextAlign.start,
                                textDirection:
                                    widget.textDirection ??
                                    Directionality.of(context),
                              )
                            : SffDecoration.buildHint(
                                context,
                                widget.decoration,
                                fallback: l10n.selectPlaceholder,
                                arabic: widget.arabic,
                                textDirection: widget.textDirection,
                                baseStyle: context.sffTextTheme.body.copyWith(
                                  color: t.fg4,
                                  fontFamily: widget.arabic
                                      ? SuperThemeData.of(
                                          context,
                                        ).tokens.arabicFont
                                      : null,
                                ),
                              ),
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
