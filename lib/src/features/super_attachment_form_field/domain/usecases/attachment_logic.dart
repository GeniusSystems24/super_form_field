// ============================================================
// features/super_attachment_form_field/domain/usecases/attachment_logic.dart
// ------------------------------------------------------------
// Pure domain logic for the attachment field: type-to-glyph mapping, accept
// matching, per-file errors, and the field validator chain.
// ============================================================

import 'package:flutter/widgets.dart';

import '../../../../core/foundation/sff_icon.dart';
import 'package:super_core/super_core.dart' hide Validator, ValidityChanged;
import '../../../../core/utils/validators.dart';
import '../entities/super_file.dart';

/// The icon and color used to represent a file type in the list.
@immutable
class FileGlyph {
  const FileGlyph(this.icon, this.color);
  final IconData icon;
  final Color color;
}

/// File-type, accept, and size business rules.
abstract final class AttachmentLogic {
  static final RegExp _image = RegExp(r'(png|jpe?g|gif|webp|svg|bmp)$');
  static final RegExp _doc = RegExp(r'(docx?|rtf|txt|md)$');
  static final RegExp _sheet = RegExp(r'(xlsx?|csv)$');

  /// The glyph and color for a file, by extension then MIME.
  static FileGlyph glyphFor(BuildContext context, SuperFile f) {
    final e = f.extension;
    final type = (f.mimeType ?? '').toLowerCase();
    if (_image.hasMatch(e) || type.startsWith('image/')) {
      return FileGlyph(
        SffIcons.image,
        SuperThemeData.of(context).tokens.success,
      );
    }
    if (e == 'pdf' || type.contains('pdf')) {
      return FileGlyph(
        SffIcons.fileText,
        SuperThemeData.of(context).tokens.danger,
      );
    }
    if (_doc.hasMatch(e)) {
      return FileGlyph(
        SffIcons.fileText,
        SuperThemeData.of(context).tokens.accent,
      );
    }
    if (_sheet.hasMatch(e)) {
      return FileGlyph(
        SffIcons.sheet,
        SuperThemeData.of(context).tokens.success,
      );
    }
    return const FileGlyph(SffIcons.file, Color(0xFF8D90A0));
  }

  /// Whether a file satisfies an accept spec such as ".pdf,.docx" or "image/*".
  static bool matchesAccept(SuperFile f, String? accept) {
    if (accept == null || accept.trim().isEmpty) return true;
    final tokens = accept
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty);
    final ext = '.${f.extension}';
    final type = (f.mimeType ?? '').toLowerCase();
    for (final tok in tokens) {
      if (tok.startsWith('.')) {
        if (ext == tok) return true;
      } else if (tok.endsWith('/*')) {
        if (type.startsWith(tok.substring(0, tok.length - 1))) return true;
      } else if (type == tok) {
        return true;
      }
    }
    return false;
  }

  /// The per-file error (size then type), or null when the file is acceptable.
  static String? fileError(
    SuperFile f, {
    int? maxBytes,
    String? accept,
    double? maxSizeMB,
    String Function(String name, double? maxSizeMB)? tooLargeMessage,
    String Function(String name)? notAcceptedMessage,
  }) {
    if (maxBytes != null && f.size > maxBytes) {
      return tooLargeMessage?.call(f.name, maxSizeMB) ??
          '"${f.name}" exceeds ${maxSizeMB?.toStringAsFixed(maxSizeMB.truncateToDouble() == maxSizeMB ? 0 : 1)} MB';
    }
    if (accept != null && !matchesAccept(f, accept)) {
      return notAcceptedMessage?.call(f.name) ??
          '"${f.name}" is not an accepted type';
    }
    return null;
  }

  /// Builds the field-level validator chain (required, maxFiles, per-file).
  static List<Validator<List<SuperFile>>> buildValidators({
    bool required = false,
    int? maxFiles,
    String? accept,
    double? maxSizeMB,
    List<Validator<List<SuperFile>>> extra = const [],
    String requiredMessage = 'At least one file is required',
    String Function(int count)? maxFilesMessage,
    String Function(String name, double? maxSizeMB)? fileTooLargeMessage,
    String Function(String name)? fileNotAcceptedMessage,
  }) {
    final maxBytes = maxSizeMB != null
        ? (maxSizeMB * 1024 * 1024).round()
        : null;
    return [
      if (required) (v) => v.isEmpty ? requiredMessage : null,
      if (maxFiles != null)
        (v) => v.length > maxFiles
            ? (maxFilesMessage?.call(maxFiles) ??
                  'Attach at most $maxFiles file${maxFiles > 1 ? 's' : ''}')
            : null,
      (v) {
        for (final f in v) {
          final e = fileError(
            f,
            maxBytes: maxBytes,
            accept: accept,
            maxSizeMB: maxSizeMB,
            tooLargeMessage: fileTooLargeMessage,
            notAcceptedMessage: fileNotAcceptedMessage,
          );
          if (e != null) return e;
        }
        return null;
      },
      ...extra,
    ];
  }
}
