// ============================================================
// core/foundation/option_tile.dart
// ------------------------------------------------------------
// One selectable row inside an OptionMenu: optional leading [icon], the [label]
// (+ optional [description] line), and a trailing affordance — a check glyph for
// single-select or a checkbox square for multi-select. Hover tint, an
// accent-tinted selected fill, and a disabled (dimmed, un-tappable) state. Used
// by the select / multi-select fields. A companion [OptionGroupHeader] renders
// a section label between groups.
// ============================================================

import 'package:flutter/widgets.dart';

import '../extensions/context_extensions.dart';
import 'package:super_core/super_core.dart' hide FieldShell, FieldDensity;
import 'sff_icon.dart';

/// A selectable menu row. [checkbox] true shows a multi-select square; otherwise
/// a single-select check appears when [selected].
class OptionTile extends StatefulWidget {
  const OptionTile({
    super.key,
    required this.label,
    this.description,
    this.icon,
    this.selected = false,
    this.checkbox = false,
    this.disabled = false,
    this.arabic = false,
    this.shrinkWrapWidth = false,
    this.trailing,
    this.onTap,
  });

  final String label;
  final String? description;
  final IconData? icon;
  final bool selected;

  /// Show a checkbox square (multi-select) instead of a single-select check.
  final bool checkbox;
  final bool disabled;
  final bool arabic;

  /// Whether the row uses its natural horizontal content width.
  ///
  /// Keep this false for select/dropdown menus, where rows fill the menu.
  /// Popup action menus enable it so the popup can size to its widest item.
  final bool shrinkWrapWidth;

  /// Optional trailing widget, e.g. a recursive submenu chevron.
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  State<OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<OptionTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    final fontFamily = widget.arabic
        ? SuperThemeData.of(context).tokens.arabicFont
        : null;
    final enabled = !widget.disabled && widget.onTap != null;

    final Color bg = widget.selected
        ? t.selectionFill(0.12)
        : (_hover && enabled ? t.hover : const Color(0x00000000));

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: enabled ? widget.onTap : null,
        child: Opacity(
          opacity: widget.disabled ? 0.4 : 1,
          child: AnimatedContainer(
            duration: SuperThemeData.of(context).tokens.durFast,
            padding: EdgeInsets.symmetric(
              horizontal: SuperThemeData.of(context).spacing.space2,
              vertical: SuperThemeData.of(context).spacing.space2,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(
                SuperThemeData.of(context).spacing.radiusControl,
              ),
            ),
            child: Row(
              mainAxisSize: widget.shrinkWrapWidth
                  ? MainAxisSize.min
                  : MainAxisSize.max,
              children: [
                if (widget.checkbox) ...[
                  _CheckSquare(checked: widget.selected),
                  SizedBox(width: SuperThemeData.of(context).spacing.space2),
                ],
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 16,
                    color: widget.selected ? cs.primary : t.fg3,
                  ),
                  SizedBox(width: SuperThemeData.of(context).spacing.space2),
                ],
                Flexible(
                  fit: widget.shrinkWrapWidth
                      ? FlexFit.loose
                      : FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.sffTextTheme.body.copyWith(
                          color: widget.selected ? t.fg1 : t.fg2,
                          fontFamily: fontFamily,
                          fontWeight: widget.selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          fontSize: 13.5,
                        ),
                      ),
                      if (widget.description != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          widget.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.sffTextTheme.caption.copyWith(
                            color: t.fg4,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.trailing != null) ...[
                  SizedBox(width: SuperThemeData.of(context).spacing.space2),
                  widget.trailing!,
                ] else if (!widget.checkbox && widget.selected) ...[
                  SizedBox(width: SuperThemeData.of(context).spacing.space2),
                  Icon(SffIcons.check, size: 16, color: cs.primary),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The small checkbox square drawn inside multi-select rows.
class _CheckSquare extends StatelessWidget {
  const _CheckSquare({required this.checked});
  final bool checked;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    return AnimatedContainer(
      duration: SuperThemeData.of(context).tokens.durFast,
      width: 17,
      height: 17,
      decoration: BoxDecoration(
        color: checked ? cs.primary : const Color(0x00000000),
        border: Border.all(
          color: checked ? cs.primary : t.borderStrong,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: checked
          ? const Icon(SffIcons.check, size: 12, color: Color(0xFFFFFFFF))
          : const SizedBox.shrink(),
    );
  }
}

/// A section label rendered between option groups inside the menu.
class OptionGroupHeader extends StatelessWidget {
  const OptionGroupHeader({
    super.key,
    required this.label,
    this.arabic = false,
  });
  final String label;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        SuperThemeData.of(context).spacing.space2,
        SuperThemeData.of(context).spacing.space2,
        SuperThemeData.of(context).spacing.space2,
        SuperThemeData.of(context).spacing.space1,
      ),
      child: Text(
        label.toUpperCase(),
        style: context.sffTextTheme.label.copyWith(
          color: t.fg4,
          fontFamily: arabic
              ? SuperThemeData.of(context).tokens.arabicFont
              : null,
        ),
      ),
    );
  }
}
