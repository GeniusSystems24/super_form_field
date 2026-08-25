import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
import 'package:super_form_field/super_form_field.dart';

import 'demo_scaffold.dart';

/// Gallery examples for [SuperPopupMenuButton].
class PopupMenuButtonDemo extends StatefulWidget {
  const PopupMenuButtonDemo({super.key});

  @override
  State<PopupMenuButtonDemo> createState() => _PopupMenuButtonDemoState();
}

class _PopupMenuButtonDemoState extends State<PopupMenuButtonDemo> {
  String? _selectedAction;

  static const _flatActions = <SuperOption<String>>[
    SuperOption(
      value: 'open',
      label: 'Open details',
      icon: Icons.open_in_new_rounded,
    ),
    SuperOption(
      value: 'duplicate',
      label: 'Duplicate',
      icon: Icons.copy_outlined,
    ),
    SuperOption(
      value: 'archive',
      label: 'Archive',
      icon: Icons.archive_outlined,
    ),
    SuperOption(
      value: 'delete',
      label: 'Delete permanently',
      description: 'Disabled in this example',
      icon: Icons.delete_outline_rounded,
      disabled: true,
    ),
  ];

  static const _nestedActions = <SuperOption<String>>[
    SuperOption(
      value: 'create_branch',
      label: 'Create',
      icon: Icons.add_circle_outline_rounded,
      children: [
        SuperOption(
          value: 'invoice',
          label: 'Invoice',
          icon: Icons.receipt_long_outlined,
        ),
        SuperOption(
          value: 'sales_document_branch',
          label: 'Sales document',
          icon: Icons.description_outlined,
          children: [
            SuperOption(value: 'quotation', label: 'Quotation'),
            SuperOption(value: 'sales_order', label: 'Sales order'),
            SuperOption(
              value: 'sales_return',
              label: 'Sales return',
              description: 'Temporarily unavailable',
              disabled: true,
            ),
          ],
        ),
      ],
    ),
    SuperOption(
      value: 'export_branch',
      label: 'Export',
      icon: Icons.ios_share_outlined,
      children: [
        SuperOption(
          value: 'pdf',
          label: 'PDF document',
          icon: Icons.picture_as_pdf_outlined,
        ),
        SuperOption(
          value: 'spreadsheet_branch',
          label: 'Spreadsheet',
          icon: Icons.table_chart_outlined,
          children: [
            SuperOption(value: 'xlsx', label: 'Excel workbook (.xlsx)'),
            SuperOption(value: 'csv', label: 'CSV file (.csv)'),
          ],
        ),
      ],
    ),
    SuperOption(
      value: 'management_branch',
      label: 'Management',
      icon: Icons.admin_panel_settings_outlined,
      children: [
        SuperOption(
          value: 'users_branch',
          label: 'Users',
          icon: Icons.people_outline_rounded,
          children: [
            SuperOption(value: 'invite_user', label: 'Invite user'),
            SuperOption(
              value: 'permissions_branch',
              label: 'Permissions',
              children: [
                SuperOption(value: 'roles', label: 'Roles'),
                SuperOption(value: 'policies', label: 'Policies'),
              ],
            ),
          ],
        ),
        SuperOption(value: 'teams', label: 'Teams'),
      ],
    ),
    SuperOption(
      value: 'legacy_branch',
      label: 'Legacy tools',
      description: 'Disabled branch',
      icon: Icons.history_rounded,
      disabled: true,
      children: [SuperOption(value: 'legacy_import', label: 'Legacy import')],
    ),
    SuperOption(
      value: 'settings',
      label: 'Settings',
      icon: Icons.settings_outlined,
    ),
  ];

  void _handleSelected(String value) {
    setState(() => _selectedAction = value);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = SuperThemeData.of(context).spacing;

    return DemoPage(
      eyebrow: 'Controls • Actions',
      title: 'Popup Menu Button',
      children: [
        const FixedFeatureCallout(
          title: 'Fixed-state scope',
          message:
              'allowFixed belongs to value-bearing form fields backed by a field controller. SuperPopupMenuButton is an action surface, so it intentionally has no fixed-value toggle.',
        ),
        SuperSectionCard1(
          title: 'Icon trigger',
          subtitle: 'Simple typed action menu with disabled options',
          accentColor: SuperMarker.identity.resolve(context.superTheme.tokens),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SuperPopupMenuButton<String>(
                tooltip: 'More actions',
                options: _flatActions,
                initialValue: _selectedAction,
                onSelected: _handleSelected,
              ),
              SizedBox(width: spacing.space3),
              Expanded(child: _SelectionPreview(value: _selectedAction)),
            ],
          ),
        ),
        SuperSectionCard1(
          title: 'Custom trigger',
          subtitle: 'Any widget can act as the popup trigger',
          accentColor: SuperMarker.ledger.resolve(context.superTheme.tokens),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: SuperPopupMenuButton<String>(
              tooltip: 'Record actions',
              options: _flatActions,
              initialValue: _selectedAction,
              onSelected: _handleSelected,
              child: const _ActionTrigger(
                icon: Icons.more_horiz_rounded,
                label: 'Record actions',
              ),
            ),
          ),
        ),
        SuperSectionCard1(
          title: 'Nested tree',
          subtitle:
              'Branch options open real cascading submenus; only leaves select',
          accentColor: SuperMarker.notes.resolve(context.superTheme.tokens),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SuperPopupMenuButton<String>(
                tooltip: 'Open nested actions',
                options: _nestedActions,
                initialValue: _selectedAction,
                onSelected: _handleSelected,
                child: const _ActionTrigger(
                  icon: Icons.account_tree_outlined,
                  label: 'Nested actions',
                ),
              ),
              SizedBox(height: spacing.space3),
              const _FeatureHints(
                items: [
                  'Create → Sales document → Quotation',
                  'Export → Spreadsheet → Excel workbook (.xlsx)',
                  'Management → Users → Permissions → Roles',
                  'Hover or click/tap a branch to open its submenu.',
                  'Disabled branches stay visible but cannot expand.',
                ],
              ),
            ],
          ),
        ),
        SuperSectionCard1(
          title: 'Selected path',
          subtitle: 'Selected leaves tint every parent branch in their path',
          accentColor: SuperMarker.notes.resolve(context.superTheme.tokens),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SuperPopupMenuButton<String>(
                tooltip: 'Selected path example',
                options: _nestedActions,
                initialValue: _selectedAction,
                onSelected: _handleSelected,
                child: const _ActionTrigger(
                  icon: Icons.fork_right_rounded,
                  label: 'Open deep tree',
                ),
              ),
              SizedBox(height: spacing.space3),
              _SelectionPreview(value: _selectedAction),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionTrigger extends StatelessWidget {
  const _ActionTrigger({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final spacing = SuperThemeData.of(context).spacing;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: spacing.space3,
          vertical: spacing.space2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            SizedBox(width: spacing.space2),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _SelectionPreview extends StatelessWidget {
  const _SelectionPreview({required this.value});

  final String? value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selected leaf', style: textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(value ?? 'None', style: textTheme.bodyMedium),
      ],
    );
  }
}

class _FeatureHints extends StatelessWidget {
  const _FeatureHints({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final spacing = SuperThemeData.of(context).spacing;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: EdgeInsets.only(bottom: spacing.space1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(Icons.circle, size: 5),
                ),
                SizedBox(width: spacing.space2),
                Expanded(child: Text(item, style: textTheme.bodySmall)),
              ],
            ),
          ),
      ],
    );
  }
}
