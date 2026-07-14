// ============================================================
// core/foundation/menu_search_field.dart
// ------------------------------------------------------------
// The slim search box pinned at the top of a searchable OptionMenu. A borderless
// row (leading magnifier + text input) divided from the list by a hairline. Kept
// separate from FieldBox: it is menu chrome, not a standalone control.
// ============================================================

import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import 'package:super_core/super_core.dart' hide FieldShell, FieldDensity;
import 'sff_icon.dart';

/// A compact search input for the top of an option menu.
class MenuSearchField extends StatelessWidget {
  const MenuSearchField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText = 'Search…',
    this.onChanged,
    this.arabic = false,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        SuperTokens.space3,
        SuperTokens.space1,
        SuperTokens.space2,
        SuperTokens.space1,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          Icon(SffIcons.search, size: 16, color: t.fg4),
          const SizedBox(width: SuperTokens.space2),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              onChanged: onChanged,
              cursorColor: cs.primary,
              style: SuperText.body.copyWith(
                color: t.fg1,
                fontSize: 13.5,
                fontFamily: arabic ? SuperTokens.arabicFont : SuperTokens.bodyFont,
              ),
              textAlign: arabic ? TextAlign.right : TextAlign.left,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: SuperText.body.copyWith(
                  color: t.fg4,
                  fontSize: 13.5,
                  fontFamily: arabic ? SuperTokens.arabicFont : SuperTokens.bodyFont,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
