// ============================================================
// features/super_attachment_form_field/domain/entities/super_file.dart
// ------------------------------------------------------------
// The immutable descriptor for one attached file. Deliberately platform-neutral
// so the kit stays independent of picker plugins: it carries metadata
// (name / size / MIME) plus optional [path] / [bytes] the host can populate from
// whatever picker it
// wires (file_picker, image_picker, drag-and-drop, a server record…).
// ============================================================

import 'package:flutter/foundation.dart';

@immutable
class SuperFile {
  const SuperFile({
    required this.id,
    required this.name,
    required this.size,
    this.mimeType,
    this.path,
    this.bytes,
  });

  /// Stable identity within a field (used as the list key + remove target).
  final String id;

  /// Display file name including extension (`invoice-q4.pdf`).
  final String name;

  /// Size in bytes.
  final int size;

  /// MIME type, when known (`application/pdf`, `image/png`).
  final String? mimeType;

  /// Local path, when the host picker provides one.
  final String? path;

  /// In-memory bytes, when the host picker provides them.
  final Uint8List? bytes;

  /// Lowercased file extension without the dot (`pdf`, `xlsx`), or '' if none.
  String get extension {
    final i = name.lastIndexOf('.');
    return i < 0 ? '' : name.substring(i + 1).toLowerCase();
  }

  SuperFile copyWith({String? id}) => SuperFile(
    id: id ?? this.id,
    name: name,
    size: size,
    mimeType: mimeType,
    path: path,
    bytes: bytes,
  );

  @override
  bool operator ==(Object other) =>
      other is SuperFile &&
      other.id == id &&
      other.name == name &&
      other.size == size;

  @override
  int get hashCode => Object.hash(id, name, size);
}
