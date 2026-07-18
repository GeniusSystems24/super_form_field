// ============================================================
// core/foundation/super_chip.dart
// ------------------------------------------------------------
// A removable tag used to show a chosen value inside a multi-select field: an
// accent-tinted pill with a label and a trailing × that calls [onRemove]. Sized
// to sit on one line inside the FieldBox; the × is hidden when [onRemove] is
// null (read-only / disabled).
// ============================================================

import 'package:flutter/widgets.dart';

import '../extensions/context_extensions.dart';
import 'package:super_core/super_core.dart' hide FieldShell, FieldDensity;
import 'sff_icon.dart';

/// A compact, removable value chip (the multi-select token).
class SuperChip extends StatefulWidget {
  const SuperChip({
    super.key,
    required this.label,
    this.onRemove,
    this.arabic = false,
  });

  final String label;

  /// Called when the × is tapped. Null hides the × (read-only).
  final VoidCallback? onRemove;
  final bool arabic;

  @override
  State<SuperChip> createState() => _SuperChipState();
}

class _SuperChipState extends State<SuperChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    return Container(
      padding: EdgeInsetsDirectional.only(
        start: SuperTokensData.defaultSpace2,
        end: widget.onRemove != null ? 2 : SuperTokensData.defaultSpace2,
        top: 2,
        bottom: 2,
      ),
      decoration: BoxDecoration(
        color: t.selectionFill(0.14),
        borderRadius: BorderRadius.circular(SuperTokensData.defaultRadiusMd),
        border: Border.all(color: t.selectionFill(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SuperText.caption.copyWith(
                color: t.fg1,
                fontWeight: FontWeight.w500,
                fontSize: 12.5,
                fontFamily: widget.arabic ? SuperTokensData.defaultArabicFont : SuperTokensData.defaultBodyFont,
              ),
            ),
          ),
          if (widget.onRemove != null) ...[
            const SizedBox(width: 2),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _hover = true),
              onExit: (_) => setState(() => _hover = false),
              child: GestureDetector(
                onTap: widget.onRemove,
                child: Icon(
                  SffIcons.clear,
                  size: 14,
                  color: _hover ? cs.error : t.fg3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
