// ============================================================
// core/foundation/field_popover.dart
// ------------------------------------------------------------
// The shared dropdown-popover plumbing used by the option fields (select,
// multi-select). Wraps a trigger [child] and, while [open] is true, paints
// [overlayBuilder] anchored to the trigger — dropping BELOW it, flipping ABOVE
// when there isn't room below (the same rule the date field's calendar uses).
// The follower matches the trigger's width by default so the menu lines up with
// the control. A full-screen translucent barrier calls [onDismiss] on an outside
// tap. The host (a field controller) owns the [open] flag; this widget is pure
// presentation.
// ============================================================

import 'package:flutter/widgets.dart';

/// Anchors a dropdown overlay to a trigger with smart above/below placement.
class FieldPopover extends StatefulWidget {
  const FieldPopover({
    super.key,
    required this.open,
    required this.onDismiss,
    required this.child,
    required this.overlayBuilder,
    this.estimatedHeight = 320,
    this.matchWidth = true,
    this.gap = 6,
  });

  /// Whether the overlay is showing. Driven by the host field controller.
  final bool open;

  /// Called when the user taps outside the overlay.
  final VoidCallback onDismiss;

  /// The trigger (typically a FieldBox).
  final Widget child;

  /// Builds the floating panel (typically an OptionMenu).
  final WidgetBuilder overlayBuilder;

  /// Used to decide whether the panel fits below the trigger or must flip above.
  final double estimatedHeight;

  /// Constrain the panel to the trigger's width.
  final bool matchWidth;

  /// Vertical gap between the trigger and the panel.
  final double gap;

  @override
  State<FieldPopover> createState() => _FieldPopoverState();
}

class _FieldPopoverState extends State<FieldPopover> {
  final _link = LayerLink();
  final _key = GlobalKey();
  final _overlay = OverlayPortalController();
  bool _above = false;
  double _width = 0;

  @override
  void didUpdateWidget(FieldPopover old) {
    super.didUpdateWidget(old);
    if (widget.open != old.open) {
      if (widget.open) {
        _place();
        _overlay.show();
      } else {
        _overlay.hide();
      }
    }
  }

  @override
  void dispose() {
    if (_overlay.isShowing) _overlay.hide();
    super.dispose();
  }

  void _place() {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      _above = false;
      return;
    }
    _width = box.size.width;
    final top = box.localToGlobal(Offset.zero).dy;
    final screenH = MediaQuery.of(context).size.height;
    final below = screenH - (top + box.size.height);
    _above = below < widget.estimatedHeight + 12 && top > below;
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlay,
      overlayChildBuilder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: widget.onDismiss,
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              targetAnchor: _above ? Alignment.topLeft : Alignment.bottomLeft,
              followerAnchor: _above ? Alignment.bottomLeft : Alignment.topLeft,
              offset: Offset(0, _above ? -widget.gap : widget.gap),
              child: ConstrainedBox(
                constraints: widget.matchWidth && _width > 0
                    ? BoxConstraints(minWidth: _width, maxWidth: _width)
                    : const BoxConstraints(),
                child: widget.overlayBuilder(context),
              ),
            ),
          ],
        );
      },
      child: CompositedTransformTarget(
        link: _link,
        child: KeyedSubtree(key: _key, child: widget.child),
      ),
    );
  }
}
