// ============================================================
// features/super_attachment_form_field/presentation/controllers/super_attachment_field_controller.dart
// ------------------------------------------------------------
// The MVC controller (Model) for the attachment field. Holds the attached file
// list and interaction state (touched / drag-over), enforces dedupe + the
// single-file constraint when `multiple` is off, and derives the field error.
// File ACQUISITION (picker / OS drag-drop) is the host's job — it calls [add];
// the controller stays platform- and dependency-free.
// ============================================================

import 'package:flutter/foundation.dart';

import '../../../../core/utils/validators.dart';
import '../../domain/entities/super_file.dart';
import '../../domain/usecases/attachment_logic.dart';

class SuperAttachmentFieldController extends ChangeNotifier {
  SuperAttachmentFieldController({List<SuperFile>? initial})
      : _files = List<SuperFile>.from(initial ?? const []);

  List<SuperFile> _files;
  bool _touched = false;
  bool _dragOver = false;
  int _seq = 0;

  // ── config ──
  bool _multiple = true;
  String? _accept;
  double? _maxSizeMB;
  List<Validator<List<SuperFile>>> _validators = const [];
  bool _forceError = false;
  ValidityChanged? _onValidity;
  ValueChanged<List<SuperFile>>? _onChanged;
  String? _lastReported;

  // ── reads ──
  List<SuperFile> get files => List.unmodifiable(_files);
  bool get touched => _touched;
  bool get dragOver => _dragOver;
  int? get maxBytes => _maxSizeMB != null ? (_maxSizeMB! * 1024 * 1024).round() : null;
  String? get accept => _accept;
  double? get maxSizeMB => _maxSizeMB;

  String? get error => runValidators(_files, _validators);
  String? get visibleError => (_touched || _forceError) && error != null ? error : null;

  /// Per-file error for the card-level red state.
  String? errorForFile(SuperFile f) =>
      AttachmentLogic.fileError(f, maxBytes: maxBytes, accept: _accept, maxSizeMB: _maxSizeMB);

  // ── View → controller config ──
  void configure({
    bool multiple = true,
    String? accept,
    double? maxSizeMB,
    required List<Validator<List<SuperFile>>> validators,
    required bool forceError,
    ValidityChanged? onValidity,
    ValueChanged<List<SuperFile>>? onChanged,
  }) {
    _multiple = multiple;
    _accept = accept;
    _maxSizeMB = maxSizeMB;
    _validators = validators;
    _forceError = forceError;
    _onValidity = onValidity;
    _onChanged = onChanged;
  }

  /// Reports the current validity once — call after the first frame so a host
  /// `onValidity` that calls setState never runs during build.
  void reportInitialValidity() => _reportValidity();

  void setDragOver(bool v) {
    if (_dragOver == v) return;
    _dragOver = v;
    notifyListeners();
  }

  /// Add files (from a host picker or OS drop). Assigns stable ids, dedupes by
  /// (name,size), and honors the single-file constraint when `multiple` is off.
  void add(Iterable<SuperFile> incoming) {
    final stamped = incoming.map((f) => f.copyWith(id: 'sff-${_seq++}')).toList();
    if (!_multiple) {
      _files = stamped.isEmpty ? _files : [stamped.last];
    } else {
      final merged = [..._files];
      for (final f in stamped) {
        final dup = merged.any((e) => e.name == f.name && e.size == f.size);
        if (!dup) merged.add(f);
      }
      _files = merged;
    }
    _touched = true;
    _emit();
    notifyListeners();
  }

  /// Remove one file by id.
  void remove(String id) {
    _files = _files.where((f) => f.id != id).toList();
    _touched = true;
    _emit();
    notifyListeners();
  }

  /// Clear every attachment.
  void clear() {
    if (_files.isEmpty) return;
    _files = const [];
    _touched = true;
    _emit();
    notifyListeners();
  }

  void _emit() {
    _onChanged?.call(files);
    _reportValidity();
  }

  void _reportValidity() {
    final e = error;
    if (e != _lastReported) {
      _lastReported = e;
      _onValidity?.call(e);
    }
  }
}
