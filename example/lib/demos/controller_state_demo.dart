import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart'
    hide SuperMarker, SuperSectionCard;

import 'demo_scaffold.dart';

/// Demonstrates controller-level field state introduced in 1.10.0.
class ControllerStateDemo extends StatefulWidget {
  const ControllerStateDemo({super.key});

  @override
  State<ControllerStateDemo> createState() => _ControllerStateDemoState();
}

class _ControllerStateDemoState extends State<ControllerStateDemo> {
  final _textFormKey = GlobalKey<FormFieldState<String>>();
  final _textFocus = FocusNode(debugLabel: 'controller-state-text');
  late final SuperTextFieldController _textController;

  final _selectFormKey = GlobalKey<FormFieldState<String?>>();
  late final SuperSelectFieldController<String> _selectController;

  final _dropdownFormKey = GlobalKey<FormFieldState<String>>();
  late final SuperDropdownEditingController<String> _dropdownController;

  static const _options = [
    SuperOption(value: 'draft', label: 'Draft'),
    SuperOption(value: 'posted', label: 'Posted'),
    SuperOption(value: 'void', label: 'Void'),
  ];

  @override
  void initState() {
    super.initState();
    _textController = SuperTextFieldController(
      initialValue: 'INV-1042',
      focusNode: _textFocus,
      formFieldKey: _textFormKey,
    );
    _selectController = SuperSelectFieldController<String>(
      initialValue: 'draft',
      formFieldKey: _selectFormKey,
    );
    _dropdownController = SuperDropdownEditingController<String>(
      initialValue: 'draft',
      formFieldKey: _dropdownFormKey,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _selectController.dispose();
    _dropdownController.dispose();
    _textFocus.dispose();
    super.dispose();
  }

  void _toggleFixed(ValueNotifier<bool> fixed) {
    fixed.value = !fixed.value;
  }

  void _toggleHidden(dynamic controller) {
    setState(() {
      controller.isHiden = !controller.isHiden;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = SuperThemeData.of(context).spacing;

    return DemoPage(
      eyebrow: 'Controllers • Field state',
      title: 'Controller metadata',
      children: [
        SuperSectionCard(
          title: 'Text controller',
          subtitle:
              'isFixed, focusNode, formFieldKey, and compatibility isHiden',
          marker: SuperMarker.identity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SuperTextFormField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Document reference',
                  helperText: 'Fixed keeps normal contrast but blocks editing.',
                ),
              ),
              SizedBox(height: spacing.space3),
              Wrap(
                spacing: spacing.space2,
                runSpacing: spacing.space2,
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: _textController.isFixed,
                    builder: (context, fixed, _) => OutlinedButton.icon(
                      onPressed: () => _toggleFixed(_textController.isFixed),
                      icon: Icon(
                        fixed
                            ? Icons.lock_rounded
                            : Icons.lock_open_rounded,
                      ),
                      label: Text(fixed ? 'Unfix' : 'Fix'),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => _textController.focusNode?.requestFocus(),
                    child: const Text('Focus'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      _textController.formFieldKey?.currentState?.validate();
                    },
                    child: const Text('Validate by key'),
                  ),
                  OutlinedButton(
                    onPressed: () => _toggleHidden(_textController),
                    child: Text(
                      _textController.isHiden ? 'Show field' : 'Hide field',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SuperSectionCard(
          title: 'Select controller',
          subtitle: 'Fixing closes the menu and guards selection mutations',
          marker: SuperMarker.ledger,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SuperSelectFormField<String>(
                controller: _selectController,
                options: _options,
                decoration: const InputDecoration(labelText: 'State'),
                onChanged: (_) {},
              ),
              SizedBox(height: spacing.space3),
              Wrap(
                spacing: spacing.space2,
                runSpacing: spacing.space2,
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: _selectController.isFixed,
                    builder: (context, fixed, _) => OutlinedButton(
                      onPressed: () => _toggleFixed(_selectController.isFixed),
                      child: Text(fixed ? 'Unfix select' : 'Fix select'),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => _toggleHidden(_selectController),
                    child: Text(
                      _selectController.isHiden ? 'Show select' : 'Hide select',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SuperSectionCard(
          title: 'Dropdown editing controller',
          subtitle: 'Direct value assignments are guarded while fixed',
          marker: SuperMarker.notes,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SuperDropdownButtonFormField<String>(
                controller: _dropdownController,
                options: _options,
                decoration: const InputDecoration(labelText: 'Workflow state'),
                onChanged: (_) {},
              ),
              SizedBox(height: spacing.space3),
              Wrap(
                spacing: spacing.space2,
                runSpacing: spacing.space2,
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: _dropdownController.isFixed,
                    builder: (context, fixed, _) => OutlinedButton(
                      onPressed: () =>
                          _toggleFixed(_dropdownController.isFixed),
                      child: Text(fixed ? 'Unfix dropdown' : 'Fix dropdown'),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => _dropdownController.value = 'posted',
                    child: const Text('Set Posted'),
                  ),
                  OutlinedButton(
                    onPressed: () => _toggleHidden(_dropdownController),
                    child: Text(
                      _dropdownController.isHiden
                          ? 'Show dropdown'
                          : 'Hide dropdown',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
