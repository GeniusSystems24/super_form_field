// ============================================================
// features/super_popup_menu_button/presentation/widgets/super_popup_menu_button.dart
// ------------------------------------------------------------
// Anchored action menu built from FieldPopover + OptionMenu + OptionTile.
// Recursive branches use OverlayEntry so every submenu is painted above the
// root FieldPopover barrier and can cascade to arbitrary depth.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';

/// A compact button that opens a typed Super design-system popup menu.
///
/// Provide either [child] or [icon]. When both are omitted, the trigger uses
/// [Icons.more_vert_rounded].
///
/// Add [SuperOption.children] to any option to turn it into a submenu branch.
/// Branches may contain more branches recursively. Only enabled leaf options
/// invoke [onSelected].
class SuperPopupMenuButton<T> extends StatefulWidget {
  const SuperPopupMenuButton({
    super.key,
    required this.options,
    this.onSelected,
    this.child,
    this.icon,
    this.tooltip,
    this.enabled = true,
    this.initialValue,
    this.menuMaxHeight = 280,
    this.menuMinWidth = 0,
    this.arabic = false,
    this.autofocus = false,
    this.focusNode,
    this.onOpened,
    this.onCanceled,
  });

  /// Root options displayed by the popup menu.
  ///
  /// Each option may contain [SuperOption.children], forming a recursive tree.
  final List<SuperOption<T>> options;

  /// Called when an enabled leaf option is selected.
  ///
  /// Branch options only expand/collapse their submenu.
  final ValueChanged<T>? onSelected;

  /// Custom trigger. If null, an icon button is rendered.
  final Widget? child;

  /// Icon used by the default trigger.
  final IconData? icon;

  /// Tooltip for the trigger.
  final String? tooltip;

  /// Whether the menu trigger is interactive.
  final bool enabled;

  /// Optional selected leaf value.
  ///
  /// Ancestor branches of the selected leaf receive the selected tint while
  /// keeping the submenu chevron instead of a check glyph.
  final T? initialValue;

  /// Maximum height of every menu level.
  final double menuMaxHeight;

  /// Optional minimum width of every menu level.
  ///
  /// Defaults to zero, so each level wraps its widest direct item.
  final double menuMinWidth;

  /// Uses the package Arabic font fallback for generated labels.
  final bool arabic;

  /// Whether the trigger requests focus when first built.
  final bool autofocus;

  /// Optional trigger focus node.
  final FocusNode? focusNode;

  /// Called immediately after the root menu opens.
  final VoidCallback? onOpened;

  /// Called when the root menu is dismissed without selecting a leaf.
  final VoidCallback? onCanceled;

  @override
  State<SuperPopupMenuButton<T>> createState() =>
      _SuperPopupMenuButtonState<T>();
}

class _SuperPopupMenuButtonState<T> extends State<SuperPopupMenuButton<T>> {
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;
  bool _open = false;
  bool _selectedDuringOpen = false;

  @override
  void initState() {
    super.initState();
    _attachFocusNode();
  }

  @override
  void didUpdateWidget(covariant SuperPopupMenuButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.focusNode != widget.focusNode) {
      if (_ownsFocusNode) _focusNode.dispose();
      _attachFocusNode();
    }

    if (!widget.enabled && _open) {
      _open = false;
    }
  }

  void _attachFocusNode() {
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!widget.enabled) return;

    _focusNode.requestFocus();

    if (_open) {
      _dismiss();
      return;
    }

    _selectedDuringOpen = false;
    setState(() => _open = true);
    widget.onOpened?.call();
  }

  void _dismiss() {
    if (!_open) return;

    setState(() => _open = false);
    if (!_selectedDuringOpen) widget.onCanceled?.call();
  }

  void _select(SuperOption<T> option) {
    if (!widget.enabled || option.disabled || option.hasChildren) return;

    _selectedDuringOpen = true;
    widget.onSelected?.call(option.value);
    setState(() => _open = false);
    _focusNode.requestFocus();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || !widget.enabled) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape && _open) {
      _dismiss();
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _toggle();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  Widget _buildTrigger(BuildContext context) {
    if (widget.child != null) {
      Widget result = MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.enabled ? _toggle : null,
          child: Opacity(
            opacity: widget.enabled ? 1 : 0.55,
            child: widget.child!,
          ),
        ),
      );

      if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
        result = Tooltip(message: widget.tooltip!, child: result);
      }

      return result;
    }

    return IconButton(
      tooltip: widget.tooltip,
      onPressed: widget.enabled ? _toggle : null,
      icon: Icon(widget.icon ?? Icons.more_vert_rounded),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      canRequestFocus: widget.enabled,
      onKeyEvent: _handleKey,
      child: FieldPopover(
        open: _open,
        onDismiss: _dismiss,
        estimatedHeight: widget.menuMaxHeight,
        matchWidth: false,
        overlayBuilder: (context) => _PopupTreeSurface<T>(
          options: widget.options,
          selectedValue: widget.initialValue,
          menuMaxHeight: widget.menuMaxHeight,
          menuMinWidth: widget.menuMinWidth,
          arabic: widget.arabic,
          onSelected: _select,
        ),
        child: _buildTrigger(context),
      ),
    );
  }
}

/// One menu level in the recursive popup tree.
///
/// A level owns at most one open branch. Nested levels own their own branch
/// state, so there is no practical depth limit imposed by this widget.
class _PopupTreeMenu<T> extends StatefulWidget {
  const _PopupTreeMenu({
    required this.options,
    required this.selectedValue,
    required this.menuMaxHeight,
    required this.menuMinWidth,
    required this.arabic,
    required this.onSelected,
  });

  final List<SuperOption<T>> options;
  final T? selectedValue;
  final double menuMaxHeight;
  final double menuMinWidth;
  final bool arabic;
  final ValueChanged<SuperOption<T>> onSelected;

  @override
  State<_PopupTreeMenu<T>> createState() => _PopupTreeMenuState<T>();
}

class _PopupTreeMenuState<T> extends State<_PopupTreeMenu<T>> {
  int? _openBranchIndex;

  @override
  void didUpdateWidget(covariant _PopupTreeMenu<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.options, widget.options)) {
      _openBranchIndex = null;
    }

    final index = _openBranchIndex;
    if (index != null &&
        (index >= widget.options.length ||
            !widget.options[index].hasChildren ||
            widget.options[index].disabled)) {
      _openBranchIndex = null;
    }
  }

  void _openBranch(int index) {
    final option = widget.options[index];
    if (option.disabled || !option.hasChildren || _openBranchIndex == index) {
      return;
    }

    setState(() => _openBranchIndex = index);
  }

  void _toggleBranch(int index) {
    final option = widget.options[index];
    if (option.disabled || !option.hasChildren) return;

    setState(() {
      _openBranchIndex = _openBranchIndex == index ? null : index;
    });
  }

  void _closeBranch() {
    if (_openBranchIndex == null) return;
    setState(() => _openBranchIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    return OptionMenu(
      maxHeight: widget.menuMaxHeight,
      children: [
        for (var index = 0; index < widget.options.length; index++)
          _buildOption(index, widget.options[index]),
      ],
    );
  }

  Widget _buildOption(int index, SuperOption<T> option) {
    if (!option.hasChildren) {
      return MouseRegion(
        onEnter: (_) => _closeBranch(),
        child: OptionTile(
          label: option.label,
          description: option.description,
          icon: option.icon,
          selected: option.value == widget.selectedValue,
          disabled: option.disabled,
          arabic: widget.arabic,
          shrinkWrapWidth: true,
          onTap: option.disabled ? null : () => widget.onSelected(option),
        ),
      );
    }

    final branchSelected = _containsSelectedLeaf(
      option.children,
      widget.selectedValue,
    );

    return _PopupTreeBranch<T>(
      option: option,
      open: _openBranchIndex == index,
      selected: branchSelected,
      selectedValue: widget.selectedValue,
      menuMaxHeight: widget.menuMaxHeight,
      menuMinWidth: widget.menuMinWidth,
      arabic: widget.arabic,
      onHoverOpen: () => _openBranch(index),
      onToggle: () => _toggleBranch(index),
      onSelected: widget.onSelected,
    );
  }
}

/// One branch row and its cascading submenu.
///
/// The submenu is an [OverlayEntry] inserted into the root overlay. This is
/// intentional: the root [FieldPopover] already owns a full-screen dismiss
/// barrier, and a nested OverlayPortal can otherwise paint under that parent
/// overlay depending on the surrounding overlay hierarchy. A later OverlayEntry
/// is guaranteed to sit above the root menu/barrier and remains interactive.
class _PopupTreeBranch<T> extends StatefulWidget {
  const _PopupTreeBranch({
    required this.option,
    required this.open,
    required this.selected,
    required this.selectedValue,
    required this.menuMaxHeight,
    required this.menuMinWidth,
    required this.arabic,
    required this.onHoverOpen,
    required this.onToggle,
    required this.onSelected,
  });

  final SuperOption<T> option;
  final bool open;
  final bool selected;
  final T? selectedValue;
  final double menuMaxHeight;
  final double menuMinWidth;
  final bool arabic;
  final VoidCallback onHoverOpen;
  final VoidCallback onToggle;
  final ValueChanged<SuperOption<T>> onSelected;

  @override
  State<_PopupTreeBranch<T>> createState() => _PopupTreeBranchState<T>();
}

class _PopupTreeBranchState<T> extends State<_PopupTreeBranch<T>> {
  static const double _gap = 4;
  static const double _edgePadding = 8;
  static const double _fallbackWidthEstimate = 280;
  static const double _rowHeightEstimate = 44;
  static const double _rowWithDescriptionHeightEstimate = 58;

  final LayerLink _link = LayerLink();
  final GlobalKey _anchorKey = GlobalKey();

  OverlayEntry? _submenuEntry;
  bool _openToStart = false;
  double _verticalOffset = 0;
  late TextDirection _textDirection;

  @override
  void initState() {
    super.initState();
    if (widget.open) _scheduleSubmenuSync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _textDirection = Directionality.of(context);
    if (widget.open) _scheduleSubmenuSync();
  }

  @override
  void didUpdateWidget(covariant _PopupTreeBranch<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.open != oldWidget.open ||
        widget.menuMaxHeight != oldWidget.menuMaxHeight ||
        widget.menuMinWidth != oldWidget.menuMinWidth ||
        widget.selectedValue != oldWidget.selectedValue ||
        !identical(widget.option.children, oldWidget.option.children)) {
      _scheduleSubmenuSync();
    }
  }

  @override
  void dispose() {
    _removeSubmenu();
    super.dispose();
  }

  void _scheduleSubmenuSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncSubmenu();
    });
  }

  void _syncSubmenu() {
    if (!widget.open || widget.option.disabled || !widget.option.hasChildren) {
      _removeSubmenu();
      return;
    }

    _placeSubmenu();

    final existing = _submenuEntry;
    if (existing != null) {
      existing.markNeedsBuild();
      return;
    }

    final overlay = Overlay.of(context, rootOverlay: true);
    final entry = OverlayEntry(
      builder: (overlayContext) {
        final submenu = Directionality(
          textDirection: _textDirection,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: _openToStart ? Alignment.topLeft : Alignment.topRight,
            followerAnchor: _openToStart
                ? Alignment.topRight
                : Alignment.topLeft,
            offset: Offset(_openToStart ? -_gap : _gap, _verticalOffset),
            child: _PopupTreeSurface<T>(
              options: widget.option.children,
              selectedValue: widget.selectedValue,
              menuMaxHeight: widget.menuMaxHeight,
              menuMinWidth: widget.menuMinWidth,
              arabic: widget.arabic,
              onSelected: widget.onSelected,
            ),
          ),
        );

        // Preserve Material/Cupertino inherited themes from the menu branch.
        // The root overlay already supplies MediaQuery/Navigator ancestry.
        return InheritedTheme.captureAll(context, submenu);
      },
    );

    _submenuEntry = entry;
    overlay.insert(entry);
  }

  void _removeSubmenu() {
    final entry = _submenuEntry;
    if (entry == null) return;

    _submenuEntry = null;
    entry.remove();
    entry.dispose();
  }

  double get _estimatedSubmenuHeight {
    var height = 8.0;
    for (final option in widget.option.children) {
      height += option.description == null
          ? _rowHeightEstimate
          : _rowWithDescriptionHeightEstimate;
    }
    return height.clamp(0.0, widget.menuMaxHeight).toDouble();
  }

  void _placeSubmenu() {
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final origin = box.localToGlobal(Offset.zero);
    final screen = MediaQuery.sizeOf(context);

    final startSpace = origin.dx;
    final endSpace = screen.width - (origin.dx + box.size.width);
    final estimatedWidth = widget.menuMinWidth > _fallbackWidthEstimate
        ? widget.menuMinWidth
        : _fallbackWidthEstimate;

    var openToStart = _textDirection == TextDirection.rtl;

    if (openToStart) {
      if (startSpace < estimatedWidth && endSpace > startSpace) {
        openToStart = false;
      }
    } else if (endSpace < estimatedWidth && startSpace > endSpace) {
      openToStart = true;
    }

    final desiredTop = origin.dy;
    final submenuHeight = _estimatedSubmenuHeight;
    final maxTop = screen.height - submenuHeight - _edgePadding;

    var verticalOffset = 0.0;
    if (desiredTop > maxTop) {
      verticalOffset = maxTop - desiredTop;
    }
    if (desiredTop + verticalOffset < _edgePadding) {
      verticalOffset = _edgePadding - desiredTop;
    }

    _openToStart = openToStart;
    _verticalOffset = verticalOffset;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final direction = Directionality.of(context);

    final chevron = Icon(
      direction == TextDirection.rtl
          ? Icons.chevron_left_rounded
          : Icons.chevron_right_rounded,
      size: 18,
      color: widget.option.disabled ? t.fg4 : t.fg3,
    );

    return CompositedTransformTarget(
      link: _link,
      child: KeyedSubtree(
        key: _anchorKey,
        child: MouseRegion(
          onEnter: (_) {
            if (!widget.option.disabled) widget.onHoverOpen();
          },
          child: Semantics(
            button: true,
            enabled: !widget.option.disabled,
            child: OptionTile(
              label: widget.option.label,
              description: widget.option.description,
              icon: widget.option.icon,
              selected: widget.selected,
              disabled: widget.option.disabled,
              arabic: widget.arabic,
              shrinkWrapWidth: true,
              trailing: chevron,
              onTap: widget.option.disabled ? null : widget.onToggle,
            ),
          ),
        ),
      ),
    );
  }
}

/// Natural-width surface used by both the root popup and every nested level.
class _PopupTreeSurface<T> extends StatelessWidget {
  const _PopupTreeSurface({
    required this.options,
    required this.selectedValue,
    required this.menuMaxHeight,
    required this.menuMinWidth,
    required this.arabic,
    required this.onSelected,
  });

  final List<SuperOption<T>> options;
  final T? selectedValue;
  final double menuMaxHeight;
  final double menuMinWidth;
  final bool arabic;
  final ValueChanged<SuperOption<T>> onSelected;

  @override
  Widget build(BuildContext context) {
    // Nested levels live in root OverlayEntry objects, whose incoming
    // constraints can be the full overlay size. Release both axes here so the
    // menu surface follows its content instead of inheriting the overlay
    // height. The explicit maxHeight below remains the scrolling threshold.
    return UnconstrainedBox(
      alignment: AlignmentDirectional.topStart,
      child: IntrinsicWidth(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: menuMinWidth,
            maxHeight: menuMaxHeight,
          ),
          child: _PopupTreeMenu<T>(
            options: options,
            selectedValue: selectedValue,
            menuMaxHeight: menuMaxHeight,
            menuMinWidth: menuMinWidth,
            arabic: arabic,
            onSelected: onSelected,
          ),
        ),
      ),
    );
  }
}

bool _containsSelectedLeaf<T>(List<SuperOption<T>> options, T? selectedValue) {
  for (final option in options) {
    if (option.hasChildren) {
      if (_containsSelectedLeaf(option.children, selectedValue)) {
        return true;
      }
    } else if (option.value == selectedValue) {
      return true;
    }
  }

  return false;
}
