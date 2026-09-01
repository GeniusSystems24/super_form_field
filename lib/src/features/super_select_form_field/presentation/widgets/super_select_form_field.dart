// ============================================================
// features/super_select_form_field/presentation/widgets/super_select_form_field.dart
// ------------------------------------------------------------
// The View for the GeniusLink single-select field. A thin Flutter wrapper that
// builds the validator chain (domain usecase), drives a
// [SuperSelectFieldController] (the Model), and renders the return FormFieldShell( + a
// tappable FieldBox trigger that opens a FieldPopover → OptionMenu of
// OptionTiles. Optionally searchable (a MenuSearchField filters the list).
// Validation surfaces only through the suffix ErrorBadge. Light/dark + LTR/RTL.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';
import '../../../../core/foundation/field_decoration.dart';
import '../../../../../localization/super_form_localizations.dart';
import '../../data/datasources/select_sources.dart';
import '../../domain/usecases/select_logic.dart';
import '../controllers/super_select_field_controller.dart';

/// Builds the option metadata for [element] at [index] inside [items].
///
/// Sources expose raw `T` values. The field calls this builder to map
/// each raw value to the [SuperOption] used for display, search, grouping,
/// disabled state, and selection metadata.
typedef SuperSelectOptionBuilder<T> =
    SuperOption<T> Function(List<T> items, int index, T element);

/// A themeable, validated single-select dropdown on the GeniusLink foundation.
class SuperSelectFormField<T> extends StatefulWidget {
  const SuperSelectFormField({
    super.key,
    required this.sources,
    required this.optionBuilder,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
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
    this.validationPosition,
    this.helpIcon,
    this.arabic = false,
    this.searchAutofocus = true,
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

  /// Local and/or remote sources used to resolve raw selectable values.
  ///
  /// Sources are loaded when the field is mounted and reloaded when the
  /// [sources] list instance changes. Their results are merged in source
  /// order before [optionBuilder] is evaluated.
  final List<SuperSelectSource<T>> sources;

  /// Converts each raw source value into `SuperOption<T>` metadata.
  ///
  /// The callback receives the merged raw item list, the item's global
  /// index in that list, and the raw item itself.
  final SuperSelectOptionBuilder<T> optionBuilder;

  /// External controller — when null, the field manages its own.
  final SuperSelectFieldController<T>? controller;

  /// Optional focus node for the select trigger.
  ///
  /// When omitted, the field reuses [SuperSelectFieldController.focusNode] when
  /// available, otherwise it owns an internal [FocusNode].
  final FocusNode? focusNode;

  /// Whether the select trigger requests focus when first built.
  ///
  /// This follows Flutter's standard focus semantics: when `true`, the field
  /// requests focus as soon as it is inserted into the focus tree.
  final bool autofocus;

  /// Called whenever keyboard focus enters or leaves the select trigger.
  final ValueChanged<bool>? onFocusChange;

  /// Shows a compact lock/unlock action on the label row.
  ///
  /// The action toggles the controller's `isFixed` notifier. Fixed fields keep
  /// normal contrast while blocking user and controller-driven mutations.
  final bool allowFixed;

  /// Seed value, used only when [controller] is null.
  final T? initialValue;

  final ValueChanged<T?>? onChanged;
  final FormValidityChanged? onValidity;

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

  /// Controls where validation feedback is rendered.
  ///
  /// When null, the field uses [ValidationPosition.underBox] on mobile and
  /// [ValidationPosition.labelTrailing] on tablet/desktop.
  final ValidationPosition? validationPosition;

  /// Optional widget displayed at the end of the label row.
  final Widget? helpIcon;

  final bool arabic;

  // ── Material-compatible interaction and search input behaviour ──
  /// Whether the menu search editor requests focus when [searchable] is true.
  ///
  /// This preserves the search-input behavior that was previously exposed by
  /// [autofocus] before the select trigger itself became focusable.
  final bool searchAutofocus;
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

class _SuperSelectSourceLoadResult<T> {
  const _SuperSelectSourceLoadResult({
    required this.items,
    this.error,
    this.stackTrace,
  });

  final List<T> items;
  final Object? error;
  final StackTrace? stackTrace;
}

class _SuperSelectFormFieldState<T> extends State<SuperSelectFormField<T>> {
  late SuperSelectFieldController<T> _controller;
  bool _ownsController = false;
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;
  List<T> _sourceItems = const [];
  bool _loadingSources = false;
  int _sourceLoadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        SuperSelectFieldController<T>(initialValue: widget.initialValue);
    _ownsController = widget.controller == null;
    _attachFocusNode();
    _startLoadingSources();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.reportInitialValidity();
    });
  }

  @override
  void didUpdateWidget(SuperSelectFormField<T> old) {
    super.didUpdateWidget(old);
    final controllerChanged = widget.controller != old.controller;
    if (controllerChanged) {
      if (_ownsController) _controller.dispose();
      _controller =
          widget.controller ??
          SuperSelectFieldController<T>(initialValue: widget.initialValue);
      _ownsController = widget.controller == null;
    }
    if (controllerChanged || widget.focusNode != old.focusNode) {
      _detachFocusNode();
      _attachFocusNode();
    }
    if (!identical(widget.sources, old.sources)) {
      _startLoadingSources();
    }
  }

  @override
  void dispose() {
    _sourceLoadGeneration++;
    _detachFocusNode();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _attachFocusNode() {
    final controllerFocusNode = _controller.focusNode;
    _ownsFocusNode = widget.focusNode == null && controllerFocusNode == null;
    _focusNode =
        widget.focusNode ??
        controllerFocusNode ??
        FocusNode(debugLabel: 'SuperSelectFormField');
    _focusNode.addListener(_handleFocusChanged);
  }

  void _detachFocusNode() {
    _focusNode.removeListener(_handleFocusChanged);
    if (_ownsFocusNode) _focusNode.dispose();
    _ownsFocusNode = false;
  }

  void _handleFocusChanged() {
    widget.onFocusChange?.call(_focusNode.hasFocus);
    if (mounted) setState(() {});
  }

  List<SuperOption<T>> get _effectiveOptions {
    final items = _sourceItems;
    return List<SuperOption<T>>.generate(
      items.length,
      (index) => widget.optionBuilder(items, index, items[index]),
      growable: false,
    );
  }

  void _startLoadingSources() {
    final generation = ++_sourceLoadGeneration;
    final sources = List<SuperSelectSource<T>>.of(widget.sources);

    _sourceItems = const [];
    _loadingSources = sources.isNotEmpty;
    if (sources.isEmpty) return;

    _resolveSources(sources, generation);
  }

  Future<void> _resolveSources(
    List<SuperSelectSource<T>> sources,
    int generation,
  ) async {
    final results = await Future.wait(
      sources.map((source) async {
        try {
          return _SuperSelectSourceLoadResult<T>(items: await source.load());
        } catch (error, stackTrace) {
          return _SuperSelectSourceLoadResult<T>(
            items: const [],
            error: error,
            stackTrace: stackTrace,
          );
        }
      }),
    );

    if (!mounted || generation != _sourceLoadGeneration) return;

    final loaded = <T>[];
    for (final result in results) {
      loaded.addAll(result.items);
      final error = result.error;
      if (error != null) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: result.stackTrace,
            library: 'super_form_field',
            context: ErrorDescription(
              'while loading a SuperSelectFormField source',
            ),
          ),
        );
      }
    }

    setState(() {
      _sourceItems = List<T>.unmodifiable(loaded);
      _loadingSources = false;
    });
  }

  bool get _editable =>
      !widget.disabled && !widget.readOnly && !_controller.isFixed.value;

  bool get _canRequestTriggerFocus =>
      !widget.disabled && widget.canRequestFocus;

  void _handleTap() {
    widget.onTap?.call();
    if (_canRequestTriggerFocus) _focusNode.requestFocus();
    if (_editable) _controller.toggle();
  }

  void _selectOption(SuperOption<T> option) {
    _controller.select(option);
    if (_canRequestTriggerFocus) _focusNode.requestFocus();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || widget.disabled) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (_controller.isOpen) {
        _controller.close();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    if (!_editable) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (!_controller.isOpen) _controller.open();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
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
              autofocus: widget.searchAutofocus,
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
      empty: _loadingSources && filtered.isEmpty
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
            selected: o.value == _controller.value,
            disabled: o.disabled,
            arabic: widget.arabic,
            onTap: () => _selectOption(o),
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
          options: _effectiveOptions,
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
            final validationPosition =
                SffDecoration.effectiveValidationPosition(
                  context,
                  widget.validationPosition,
                );
            final labelRight = SffDecoration.buildLabelRight(
              context,
              widget.decoration,
              arabic: widget.arabic,
              error: error,
              validationPosition: validationPosition,
              helpIcon: widget.helpIcon,
            );
            final underBoxError =
                validationPosition == ValidationPosition.underBox
                ? error
                : null;
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

            return FormFieldShell(
              allowFixed: widget.allowFixed,
              isFixed: _controller.isFixed,
              decoration: widget.decoration,
              required: widget.required,
              hasError: error != null,
              errorText: underBoxError,
              arabic: widget.arabic,
              labelRight: labelRight,
              child: Focus(
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                canRequestFocus: _canRequestTriggerFocus,
                onKeyEvent: _handleKeyEvent,
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
                          focused: _controller.isOpen || _focusNode.hasFocus,
                          error: error,
                          disabled: widget.disabled,
                          density: widget.density,
                          showErrorBadge:
                              validationPosition ==
                              ValidationPosition.suffixIcon,
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
              ),
            );
          },
        );
      },
    );
  }
}
