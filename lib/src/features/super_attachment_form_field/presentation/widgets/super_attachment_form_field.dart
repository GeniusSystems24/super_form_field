// ============================================================
// features/super_attachment_form_field/presentation/widgets/super_attachment_form_field.dart
// ------------------------------------------------------------
// The View for the GeniusLink attachment field. A drop zone (dashed, glows on
// drag-over) + a typed file list with size, type glyph, per-file error and a
// remove button. Field-level errors surface through an ErrorBadge in the
// label-right slot (a count pill shows there otherwise) — never inline.
//
// File ACQUISITION is delegated to the host via [onBrowse] (wire file_picker /
// image_picker there) so the package stays independent of picker plugins. Use
// the controller hooks for OS drag-and-drop integrations.
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/foundation/field_decoration.dart';
import '../../domain/entities/super_file.dart';
import '../../domain/usecases/attachment_logic.dart';
import '../controllers/super_attachment_field_controller.dart';

/// A themeable, validated file-attachment field on the GeniusLink foundation.
class SuperAttachmentFormField extends StatefulWidget {
  const SuperAttachmentFormField({
    super.key,
    this.controller,
    this.initialFiles = const [],
    this.onChanged,
    this.onValidity,
    this.decoration = const InputDecoration(),
    this.onBrowse,
    this.required = false,
    this.density = FieldDensity.comfortable,
    this.disabled = false,
    this.accept,
    this.maxSizeMB,
    this.maxFiles,
    this.multiple = true,
    this.validators = const [],
    this.forceError = false,
    this.arabic = false,
  });

  final SuperAttachmentFieldController? controller;
  final List<SuperFile> initialFiles;
  final ValueChanged<List<SuperFile>>? onChanged;
  final ValidityChanged? onValidity;

  /// Canonical source for label, helper, hint, and adornment chrome.
  final InputDecoration decoration;

  /// Invoked when the drop zone is activated (tap / Enter). Return the picked
  /// files — wire your picker here (file_picker, image_picker, …). The package
  /// ships no picker dependency, so a null callback makes the zone inert.
  final Future<List<SuperFile>> Function()? onBrowse;

  // ── chrome ──
  final bool required;
  final FieldDensity density;
  final bool disabled;

  // ── constraints ──
  final String? accept;
  final double? maxSizeMB;
  final int? maxFiles;
  final bool multiple;

  final List<Validator<List<SuperFile>>> validators;
  final bool forceError;
  final bool arabic;

  @override
  State<SuperAttachmentFormField> createState() =>
      _SuperAttachmentFormFieldState();
}

class _SuperAttachmentFormFieldState extends State<SuperAttachmentFormField> {
  late SuperAttachmentFieldController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        SuperAttachmentFieldController(initial: widget.initialFiles);
    _ownsController = widget.controller == null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.reportInitialValidity();
    });
  }

  @override
  void didUpdateWidget(SuperAttachmentFormField old) {
    super.didUpdateWidget(old);
    if (widget.controller != old.controller) {
      if (_ownsController) _controller.dispose();
      _controller =
          widget.controller ??
          SuperAttachmentFieldController(initial: widget.initialFiles);
      _ownsController = widget.controller == null;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  Future<void> _browse() async {
    if (widget.disabled || widget.onBrowse == null) return;
    final picked = await widget.onBrowse!();
    if (picked.isNotEmpty) _controller.add(picked);
  }

  String? get _acceptHint {
    final parts = <String>[
      if (widget.accept != null) widget.accept!.replaceAll(',', ', '),
      if (widget.maxSizeMB != null) 'up to ${widget.maxSizeMB} MB',
      if (widget.maxFiles != null) 'max ${widget.maxFiles}',
    ];
    return parts.isEmpty ? null : parts.join('  ·  ');
  }

  @override
  Widget build(BuildContext context) {
    _controller.configure(
      multiple: widget.multiple,
      accept: widget.accept,
      maxSizeMB: widget.maxSizeMB,
      validators: AttachmentLogic.buildValidators(
        required: widget.required,
        maxFiles: widget.maxFiles,
        accept: widget.accept,
        maxSizeMB: widget.maxSizeMB,
        extra: widget.validators,
      ),
      forceError: widget.forceError,
      onValidity: widget.onValidity,
      onChanged: widget.onChanged,
    );

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final error = widget.disabled
            ? null
            : SffDecoration.resolveError(
                widget.decoration,
                _controller.visibleError,
              );
        final n = _controller.files.length;
        final hasDecorationCounter =
            widget.decoration.counter != null ||
            widget.decoration.counterText != null;
        final Widget? labelRight = error != null
            ? ErrorBadge(error: error)
            : (!hasDecorationCounter && n > 0
                  ? CountPill(label: '$n file${n > 1 ? 's' : ''}')
                  : null);

        return FieldShell(
          decoration: widget.decoration,
          required: widget.required,
          hasError: error != null,
          arabic: widget.arabic,
          labelRight: labelRight,
          child: Opacity(
            opacity: widget.disabled ? 0.55 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DropZone(
                  controller: _controller,
                  density: widget.density,
                  disabled: widget.disabled,
                  hasError: error != null,
                  acceptHint: _acceptHint,
                  decoration: widget.decoration,
                  arabic: widget.arabic,
                  onTap: _browse,
                ),
                if (_controller.files.isNotEmpty) ...[
                  SizedBox(height: SuperThemeData.of(context).tokens.space2),
                  for (final f in _controller.files) ...[
                    _FileCard(
                      file: f,
                      error: _controller.errorForFile(f),
                      disabled: widget.disabled,
                      onRemove: () => _controller.remove(f.id),
                    ),
                    SizedBox(height: SuperThemeData.of(context).tokens.space2),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── the dashed drop zone ──
class _DropZone extends StatelessWidget {
  const _DropZone({
    required this.controller,
    required this.density,
    required this.disabled,
    required this.hasError,
    required this.acceptHint,
    required this.decoration,
    required this.arabic,
    required this.onTap,
  });

  final SuperAttachmentFieldController controller;
  final FieldDensity density;
  final bool disabled;
  final bool hasError;
  final String? acceptHint;
  final InputDecoration decoration;
  final bool arabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    final over = controller.dragOver;
    final border = over
        ? cs.primary
        : hasError
        ? cs.error
        : t.borderStrong;
    final bg = over ? t.tintOnBg(cs.primary) : t.inputBg;
    final pad = density == FieldDensity.compact
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 24);

    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: CustomPaint(
          painter: _DashedRRectPainter(
            color: border,
            radius: SuperThemeData.of(context).tokens.radiusMd,
          ),
          child: AnimatedContainer(
            duration: SuperThemeData.of(context).tokens.durBase,
            curve: SuperThemeData.of(context).tokens.curveStandard,
            padding: pad,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(
                SuperThemeData.of(context).tokens.radiusMd,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(cs.primary.withOpacity(0.13), bg),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconTheme.merge(
                    data: IconThemeData(size: 21, color: cs.primary),
                    child: decoration.prefixIcon ??
                        decoration.icon ??
                        const Icon(SffIcons.uploadCloud),
                  ),
                ),
                SizedBox(height: SuperThemeData.of(context).tokens.space2),
                if (decoration.hint == null && decoration.hintText == null)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Browse',
                          style: SuperText.body.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        TextSpan(
                          text: ' or drag files here',
                          style: SuperText.body.copyWith(
                            color: t.fg2,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SffDecoration.buildHint(
                    context,
                    decoration,
                    fallback: 'Browse or drag files here',
                    arabic: arabic,
                    baseStyle: SuperText.body.copyWith(
                      color: t.fg2,
                      fontSize: 13.5,
                    ),
                  ),
                if (acceptHint != null) ...[
                  SizedBox(height: SuperThemeData.of(context).tokens.space1),
                  Text(
                    acceptHint!,
                    style: SuperText.mono.copyWith(color: t.fg4, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── one attached-file card ──
class _FileCard extends StatelessWidget {
  const _FileCard({
    required this.file,
    required this.error,
    required this.disabled,
    required this.onRemove,
  });

  final SuperFile file;
  final String? error;
  final bool disabled;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    final g = AttachmentLogic.glyphFor(context, file);
    final bad = error != null;
    final meta = bad
        ? '${SuperFormat.bytes(file.size)}  ·  ${file.extension.toUpperCase()}'
        : SuperFormat.bytes(file.size);

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(11, 8, 6, 8),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: bad ? cs.error : t.border),
        borderRadius: BorderRadius.circular(
          SuperThemeData.of(context).tokens.radiusControl,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Color.alphaBlend(g.color.withOpacity(0.14), t.surface),
              borderRadius: BorderRadius.circular(
                SuperThemeData.of(context).tokens.radiusMd,
              ),
            ),
            child: Icon(g.icon, size: 16, color: g.color),
          ),
          SizedBox(width: SuperThemeData.of(context).tokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SuperText.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: bad ? cs.error : t.fg1,
                  ),
                ),
                Text(
                  meta,
                  style: SuperText.mono.copyWith(fontSize: 11, color: t.fg4),
                ),
              ],
            ),
          ),
          if (bad)
            Tooltip(
              message: error!,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(SffIcons.alertCircle, size: 16, color: cs.error),
              ),
            ),
          if (!disabled)
            FieldIconButton(
              icon: SffIcons.trash,
              iconSize: 15,
              size: 28,
              danger: true,
              tooltip: 'Remove ${file.name}',
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}

/// Paints a 1.5px dashed rounded-rectangle border over the drop zone.
class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final next = (dist + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}
