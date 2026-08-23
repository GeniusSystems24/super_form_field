// ============================================================
// features/super_dropdown_button/presentation/widgets/
// super_dropdown_button_form_field.dart
// ------------------------------------------------------------
// Form-integrated wrapper around SuperDropdownButton.
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/foundation/field_decoration.dart';
import '../controllers/super_dropdown_editing_controller.dart';
import 'super_dropdown_button.dart';

/// A [FormField] version of [SuperDropdownButton].
///
/// The field participates in [FormState.validate], [FormState.save], and
/// [FormState.reset]. Use [required] for the package's common null-value rule,
/// and [validator] for domain-specific validation.
///
/// Supply either [initialValue] or [controller], but not both. Programmatic
/// controller changes are synchronized into the underlying [FormFieldState], so
/// validation and saving always see the current controller value.
class SuperDropdownButtonFormField<T> extends FormField<T> {
  SuperDropdownButtonFormField({
    Key? key,
    required List<SuperOption<T>> options,
    this.controller,
    this.allowFixed = false,
    T? initialValue,
    ValueChanged<T?>? onChanged,
    super.onSaved,
    FormFieldValidator<T>? validator,
    AutovalidateMode super.autovalidateMode = AutovalidateMode.disabled,
    InputDecoration decoration = const InputDecoration(),
    bool required = false,
    String requiredMessage = 'This field is required.',
    FieldDensity density = FieldDensity.comfortable,
    bool disabled = false,
    FocusNode? focusNode,
    bool autofocus = false,
    double menuMaxHeight = 280,
    double? menuWidth,
    Widget? icon,
    TextStyle? style,
    bool arabic = false,
    VoidCallback? onTap,
  }) : assert(
         !allowFixed || controller != null,
         'allowFixed requires a SuperDropdownEditingController.',
       ),
       assert(
         controller == null || initialValue == null,
         'initialValue must be null when a controller is provided.',
       ),
       super(
         key: controller?.formFieldKey ?? key,
         initialValue: controller?.value ?? initialValue,
         enabled: !disabled && onChanged != null,
         validator: (value) {
           if (required && value == null) return requiredMessage;
           return validator?.call(value);
         },
         builder: (field) {
           if (controller?.isHiden ?? false) return const SizedBox.shrink();
           final effectiveError = SffDecoration.resolveError(
             decoration,
             field.errorText,
           );
           return FieldShell(
             allowFixed: allowFixed,
             isFixed: controller?.isFixed,
             decoration: decoration,
             required: required,
             hasError: effectiveError != null,
             arabic: arabic,
             child: SuperDropdownButton<T>(
               options: options,
               controller: controller,
               value: controller == null ? field.value : null,
               onChanged: disabled || onChanged == null
                   ? null
                   : (value) {
                       field.didChange(value);
                       onChanged(value);
                     },
               decoration: decoration.copyWith(errorText: effectiveError),
               density: density,
               disabled: disabled,
               focusNode: focusNode,
               autofocus: autofocus,
               menuMaxHeight: menuMaxHeight,
               menuWidth: menuWidth,
               icon: icon,
               style: style,
               arabic: arabic,
               onTap: onTap,
             ),
           );
         },
       );

  /// Controls the selected value programmatically.
  ///
  /// When non-null, [initialValue] must be null. Changes made through the
  /// controller are synchronized with this field's value so `validate()`,
  /// `save()`, and `reset()` continue to behave as expected.
  final SuperDropdownEditingController<T>? controller;

  /// Shows a compact lock/unlock action on the label row.
  ///
  /// Because this FormField does not create a dropdown controller internally,
  /// [controller] is required when [allowFixed] is true.
  final bool allowFixed;

  @override
  FormFieldState<T> createState() => _SuperDropdownButtonFormFieldState<T>();
}

class _SuperDropdownButtonFormFieldState<T> extends FormFieldState<T> {
  @override
  SuperDropdownButtonFormField<T> get widget =>
      super.widget as SuperDropdownButtonFormField<T>;

  SuperDropdownEditingController<T>? get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller?.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant SuperDropdownButtonFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      _controller?.addListener(_handleControllerChanged);

      final controller = _controller;
      if (controller != null && controller.value != value) {
        setValue(controller.value);
      }
    }
  }

  void _handleControllerChanged() {
    final controller = _controller;
    if (controller == null || controller.value == value) return;

    // setValue is the FormField API for programmatic changes. Rebuild the
    // FormField so error/decoration state stays in sync without marking the
    // field as changed by the user.
    setState(() {
      setValue(controller.value);
    });
  }

  @override
  void reset() {
    super.reset();

    final controller = _controller;
    if (controller != null && controller.value != value) {
      controller.value = value;
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }
}
