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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';
import '../../../../core/foundation/field_decoration.dart';
import '../../../../../localization/super_form_localizations.dart';
import '../../data/datasources/multi_select_sources.dart';
import '../../domain/usecases/multi_select_logic.dart';
import '../controllers/super_multi_select_field_controller.dart';

/// Builds option metadata for a raw multi-select source item.
typedef SuperMultiSelectOptionBuilder<T> =
    SuperOption<T> Function(List<T> items, int index, T element);

/// A themeable, validated multi-select dropdown on the GeniusLink foundation.
class SuperMultiSelectFormField<T> extends StatefulWidget {
  const SuperMultiSelectFormField({
    super.key,
    this.source,
    this.optionBuilder,
    @Deprecated('Use source and optionBuilder instead.') this.options,
    this.debounce = const Duration(milliseconds: 300),
    this.minChars = 0,
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
    this.minSelections,
    this.maxSelections,
    this.showCount = true,
    this.emptyLabel = 'No matches',
    this.validators = const [],
    this.forceError = false,
    this.validationPosition,
    this.helpIcon,
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
    this.autovalidateMode,
  }) : assert(
         source != null || options != null,
         'Provide source. The deprecated options list is accepted for compatibility.',
       ),
       assert(minChars >= 0, 'minChars must be >= 0.'),
       assert(
         onSaved == null || onSave == null,
         'Provide either onSaved or onSave, not both.',
       );

  /// Preferred singular raw-value source.
  final SuperMultiSelectSource<T>? source;

  /// Maps raw source values to display/search metadata.
  ///
  /// When omitted, the field falls back to `element.toString()` labels.
  final SuperMultiSelectOptionBuilder<T>? optionBuilder;

  /// Legacy pre-1.15.0 metadata list retained for compatibility.
  @Deprecated('Use source and optionBuilder instead.')
  final List<SuperOption<T>>? options;

  /// Delay applied only before asynchronous/external source queries.
  final Duration debounce;

  /// Minimum trimmed search length required before an async source query.
  final int minChars;

  final SuperMultiSelectFieldController<T>? controller;

  /// Shows a compact lock/unlock action on the label row.
  ///
  /// The action toggles the controller's `isFixed` notifier. Fixed fields keep
  /// normal contrast while blocking user and controller-driven mutations.
  final bool allowFixed;
  final List<T>? initialValue;

  final ValueChanged<List<T>>? onChanged;
  final FormValidityChanged? onValidity;

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

  /// Controls where validation feedback is rendered.
  ///
  /// When null, the field uses [ValidationPosition.underBox] on mobile and
  /// [ValidationPosition.labelTrailing] on tablet/desktop.
  final ValidationPosition? validationPosition;

  /// Optional widget displayed at the end of the label row.
  final Widget? helpIcon;

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
  final AutovalidateMode? autovalidateMode;

  @override
  State<SuperMultiSelectFormField<T>> createState() =>
      _SuperMultiSelectFormFieldState<T>();
}

class _SuperMultiSelectFormFieldState<T>
    extends State<SuperMultiSelectFormField<T>> {
  late SuperMultiSelectFieldController<T> _controller;
  bool _ownsController = false;
  List<T> _sourceItems = const [];
  bool _loadingSource = false;
  int _sourceQueryGeneration = 0;
  Timer? _sourceDebounce;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        SuperMultiSelectFieldController<T>(initialValue: widget.initialValue);
    _ownsController = widget.controller == null;
    _attachSourceListener();
    _resetSource();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.reportInitialValidity();
    });
  }

  @override
  void didUpdateWidget(SuperMultiSelectFormField<T> old) {
    super.didUpdateWidget(old);
    if (widget.controller != old.controller) {
      _detachSourceListener();
      if (_ownsController) _controller.dispose();
      _controller =
          widget.controller ??
          SuperMultiSelectFieldController<T>(initialValue: widget.initialValue);
      _ownsController = widget.controller == null;
      _attachSourceListener();
    }
    if (!identical(widget.source, old.source) ||
        !identical(widget.options, old.options)) {
      _resetSource();
    }
  }

  @override
  void dispose() {
    _sourceQueryGeneration++;
    _sourceDebounce?.cancel();
    _detachSourceListener();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  List<SuperOption<T>> get _effectiveOptions {
    final legacy = widget.options;
    if (widget.source == null && legacy != null) return legacy;

    final items = _sourceItems;
    final builder = widget.optionBuilder;
    return List<SuperOption<T>>.generate(
      items.length,
      (index) => builder?.call(items, index, items[index]) ??
          SuperOption<T>(value: items[index], label: items[index].toString()),
      growable: false,
    );
  }

  void _attachSourceListener() {
    _controller.searchText.addListener(_handleSourceQueryChanged);
  }

  void _detachSourceListener() {
    _controller.searchText.removeListener(_handleSourceQueryChanged);
  }

  void _resetSource() {
    _sourceDebounce?.cancel();
    final generation = ++_sourceQueryGeneration;
    _sourceItems = List<T>.unmodifiable(widget.source?.initialItems ?? const []);
    _loadingSource = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _sourceQueryGeneration) return;
      _scheduleSourceQuery(_controller.searchText.text, immediate: true);
    });
  }

  void _handleSourceQueryChanged() {
    _scheduleSourceQuery(_controller.searchText.text);
  }

  void _scheduleSourceQuery(String query, {bool immediate = false}) {
    final source = widget.source;
    if (source == null || !source.isAsync) return;

    _sourceDebounce?.cancel();
    final generation = ++_sourceQueryGeneration;
    if (query.trim().length < widget.minChars) {
      if (_loadingSource && mounted) setState(() => _loadingSource = false);
      return;
    }

    void run() => _resolveSourceQuery(source, query, generation);
    if (immediate || widget.debounce <= Duration.zero) {
      run();
    } else {
      _sourceDebounce = Timer(widget.debounce, run);
    }
  }

  Future<void> _resolveSourceQuery(
    SuperMultiSelectSource<T> source,
    String query,
    int generation,
  ) async {
    if (!mounted || generation != _sourceQueryGeneration) return;
    setState(() => _loadingSource = true);

    try {
      final values = await Future<List<T>>.value(source.query(context, query));
      if (!mounted || generation != _sourceQueryGeneration) return;
      setState(() {
        _sourceItems = List<T>.unmodifiable(values);
        _loadingSource = false;
      });
    } catch (error, stackTrace) {
      if (!mounted || generation != _sourceQueryGeneration) return;
      setState(() {
        _sourceItems = List<T>.unmodifiable(source.initialItems);
        _loadingSource = false;
      });
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'super_form_field',
          context: ErrorDescription(
            'while querying a SuperMultiSelectFormField source',
          ),
        ),
      );
    }
  }

  bool get _editable =>
      !widget.disabled && !widget.readOnly && !_controller.isFixed.value;

  void _handleTap() {
    widget.onTap?.call();
    if (!widget.readOnly) _controller.toggleMenu();
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
      empty: _loadingSource && filtered.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          : Text(
              widget.emptyLabel == 'No matches'
                  ? l10n.noMatches
                  : widget.emptyLabel,
              textAlign: TextAlign.center,
              style: context.sffTextTheme.caption.copyWith(color: t.fg4),
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
        baseStyle: context.sffTextTheme.body.copyWith(
          color: t.fg4,
          fontFamily: widget.arabic
              ? SuperThemeData.of(context).tokens.arabicFont
              : null,
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
      key: _controller.formFieldKey ?? ObjectKey(_controller),
      initialValue: _controller.values,
      enabled: !widget.disabled,
      onSaved: widget.onSaved ?? widget.onSave,
      autovalidateMode: SffDecoration.effectiveAutovalidateMode(
        context,
        widget.autovalidateMode,
      ),
      validator: (_) => _controller.error,
      builder: (formState) {
        _controller.configure(
          options: _effectiveOptions,
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
            final validationPosition =
                SffDecoration.effectiveValidationPosition(
                  context,
                  widget.validationPosition,
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
            final labelRight = SffDecoration.buildLabelRight(
              context,
              widget.decoration,
              arabic: widget.arabic,
              baseRight: countPill,
              error: error,
              validationPosition: validationPosition,
              helpIcon: widget.helpIcon,
            );
            final underBoxError =
                validationPosition == ValidationPosition.underBox
                ? error
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

            return FormFieldShell(
              allowFixed: widget.allowFixed,
              isFixed: _controller.isFixed,
              decoration: widget.decoration,
              required: widget.required,
              hasError: error != null,
              errorText: underBoxError,
              arabic: widget.arabic,
              labelRight: labelRight,
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
                        showErrorBadge:
                            validationPosition == ValidationPosition.suffixIcon,
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
