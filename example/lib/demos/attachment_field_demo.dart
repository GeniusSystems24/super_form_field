// ============================================================
// example/lib/demos/attachment_field_demo.dart
// ------------------------------------------------------------
// SuperAttachmentFormField in a supporting-documents context. Since the package
// ships no picker dependency, the demo wires a SIMULATED browse callback that
// returns sample files (rotating types + sizes) so the list, glyphs, count
// pill and per-file errors can be exercised. In a real app, return files from
// file_picker / image_picker / OS drag-and-drop here.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart' hide SectionCard;

import 'demo_scaffold.dart';

class AttachmentFieldDemo extends StatefulWidget {
  const AttachmentFieldDemo({super.key});

  @override
  State<AttachmentFieldDemo> createState() => _AttachmentFieldDemoState();
}

class _AttachmentFieldDemoState extends State<AttachmentFieldDemo> {
  bool _force = false;
  int _i = 0;

  // A rotating set of sample files — including one oversized .exe to trip the
  // per-file size + accept errors.
  static const _samples = [
    SuperFile(id: '', name: 'invoice-q4-2024.pdf', size: 482318, mimeType: 'application/pdf'),
    SuperFile(id: '', name: 'bank-statement.xlsx', size: 96204, mimeType: 'application/vnd.ms-excel'),
    SuperFile(id: '', name: 'receipt-scan.png', size: 1284882, mimeType: 'image/png'),
    SuperFile(id: '', name: 'vendor-contract.docx', size: 245010, mimeType: 'application/msword'),
    SuperFile(id: '', name: 'archive.exe', size: 28400000, mimeType: 'application/octet-stream'),
  ];

  Future<List<SuperFile>> _pick() async {
    final f = _samples[_i % _samples.length];
    _i++;
    return [f];
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return DemoPage(
      eyebrow: 'Documents • Supporting Files',
      title: 'Super Attachment Field',
      children: [
        SectionCard(
          title: 'Supporting Documents',
          subtitle: 'Attach invoices, statements, or contracts (PDF, DOCX, XLSX, images)',
          marker: Marker.notes,
          child: SuperAttachmentFormField(
            label: 'Attachments',
            required: true,
            accept: '.pdf,.docx,.xlsx,.png,.jpg',
            maxSizeMB: 5,
            maxFiles: 4,
            hint: 'Tap Browse to add a sample file. Try adding the 5th to trip the limit.',
            onBrowse: _pick,
            forceError: _force,
          ),
        ),
        SectionCard(
          title: 'Single Receipt',
          subtitle: 'Single-file mode replaces the previous attachment',
          marker: Marker.notes,
          child: SuperAttachmentFormField(
            label: 'Receipt',
            multiple: false,
            accept: 'image/*,.pdf',
            maxSizeMB: 2,
            onBrowse: _pick,
          ),
        ),
        Row(
          children: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SuperTokens.radiusControl)),
              ),
              onPressed: () => setState(() => _force = true),
              child: const Text('Validate'),
            ),
            const SizedBox(width: SuperTokens.space3),
            TextButton(
              onPressed: () => setState(() => _force = false),
              child: Text('Reset', style: TextStyle(color: t.fg2)),
            ),
          ],
        ),
      ],
    );
  }
}
