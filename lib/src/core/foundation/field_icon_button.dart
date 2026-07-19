// ============================================================
// core/foundation/field_icon_button.dart
// ------------------------------------------------------------
// The small trailing icon button used inside fields — clear (×), password
// reveal (eye), stepper (+/-), file remove (trash). Square, borderless by
// default, tints to `hover` on hover; the danger variant trades neutral for
// red. `onMouseDown`-equivalent focus theft is avoided by not requesting focus.
// ============================================================

import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import 'package:super_core/super_core.dart';

/// A compact icon button for in-field affordances.
class FieldIconButton extends StatefulWidget {
  const FieldIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 26, // trailingIcon token default
    this.iconSize = 16,
    this.bordered = false,
    this.danger = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;

  /// Draw a hairline border + input fill (the numeric stepper look).
  final bool bordered;

  /// Tint the icon danger-red on hover (the file-remove look).
  final bool danger;

  @override
  State<FieldIconButton> createState() => _FieldIconButtonState();
}

class _FieldIconButtonState extends State<FieldIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    final enabled = widget.onPressed != null;
    final fg = (_hover && widget.danger)
        ? cs.error
        : (widget.bordered ? t.fg2 : t.fg4);

    Widget btn = MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: SuperThemeData.of(context).tokens.durFast,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.bordered
                ? t.inputBg
                : (_hover ? t.hover : const Color(0x00000000)),
            border: widget.bordered ? Border.all(color: t.borderStrong) : null,
            borderRadius: BorderRadius.circular(
              widget.bordered ? 5 : SuperThemeData.of(context).tokens.radiusMd,
            ),
          ),
          child: Icon(widget.icon, size: widget.iconSize, color: fg),
        ),
      ),
    );

    if (widget.tooltip != null) {
      btn = Tooltip(message: widget.tooltip!, child: btn);
    }
    return Opacity(opacity: enabled ? 1 : 0.4, child: btn);
  }
}
