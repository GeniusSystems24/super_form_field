import 'entities/validation_position.dart';

/// Package-wide defaults for Super form fields.
abstract final class SuperFormField {
  /// Global default validation feedback position.
  ///
  /// Individual field `validationPosition` values take precedence. When this is
  /// null, fields use the responsive default: [ValidationPosition.underBox] on
  /// mobile and [ValidationPosition.labelTrailing] on tablet/desktop.
  static ValidationPosition? validationPosition;
}
