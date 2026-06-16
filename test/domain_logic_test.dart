// ============================================================
// test/domain_logic_test.dart
// ------------------------------------------------------------
// Unit tests for the pure domain layer — no Flutter binding needed. Validates
// the validator chains and the numeric sanitise/clamp logic in isolation, which
// is exactly what the Clean Architecture split makes cheap to test.
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:super_form_field/super_form_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('buildTextValidators', () {
    test('required rejects blank, accepts text', () {
      final v = buildTextValidators(required: true);
      expect(runValidators('', v), isNotNull);
      expect(runValidators('   ', v), isNotNull);
      expect(runValidators('Cash', v), isNull);
    });

    test('email pattern', () {
      final v = buildTextValidators(type: SuperTextType.email);
      expect(runValidators('not-an-email', v), isNotNull);
      expect(runValidators('a@b.co', v), isNull);
    });

    test('min/max length', () {
      final v = buildTextValidators(minLength: 3, maxLength: 5);
      expect(runValidators('ab', v), isNotNull);
      expect(runValidators('abcdef', v), isNotNull);
      expect(runValidators('abcd', v), isNull);
    });
  });

  group('NumericLogic', () {
    test('sanitize strips junk, keeps one dot + leading minus', () {
      expect(NumericLogic.sanitize('1a2.3.4', allowNegative: true), '12.34');
      expect(NumericLogic.sanitize('-5-0', allowNegative: true), '-50');
      expect(NumericLogic.sanitize('-5', allowNegative: false), '5');
    });

    test('clampRound clamps and rounds', () {
      expect(NumericLogic.clampRound(12.345, min: 0, max: 100, decimals: 2),
          12.35);
      expect(NumericLogic.clampRound(-5, min: 0, max: 100, decimals: 0), 0);
      expect(NumericLogic.clampRound(150, min: 0, max: 100, decimals: 0), 100);
    });

    test('validators honor min/max and allowNegative', () {
      final v = NumericLogic.buildValidators(
          required: true, min: 0, max: 10, allowNegative: false);
      expect(runValidators<num?>(null, v), isNotNull);
      expect(runValidators<num?>(-1, v), 'Cannot be negative');
      expect(runValidators<num?>(11, v), isNotNull);
      expect(runValidators<num?>(5, v), isNull);
    });
  });

  group('AttachmentLogic', () {
    const pdf = SuperFile(
        id: '1', name: 'a.pdf', size: 1000, mimeType: 'application/pdf');
    const png =
        SuperFile(id: '2', name: 'b.png', size: 2000, mimeType: 'image/png');

    test('matchesAccept by extension and wildcard', () {
      expect(AttachmentLogic.matchesAccept(pdf, '.pdf,.docx'), isTrue);
      expect(AttachmentLogic.matchesAccept(png, '.pdf'), isFalse);
      expect(AttachmentLogic.matchesAccept(png, 'image/*'), isTrue);
    });

    test('field validators enforce required + maxFiles + per-file', () {
      final v = AttachmentLogic.buildValidators(
          required: true, maxFiles: 1, accept: '.pdf', maxSizeMB: 1);
      expect(runValidators<List<SuperFile>>(const [], v), isNotNull);
      expect(runValidators<List<SuperFile>>(const [pdf, png], v),
          isNotNull); // > maxFiles
      expect(runValidators<List<SuperFile>>(const [png], v), isNotNull);
    }); // wrong type
    group('SuperNumericFieldController stepping', () {
      test('bump uses step, bumpLarge uses largeStep, both clamp', () {
        final c = SuperNumericFieldController(initialValue: 10);
        c.configure(
          min: 0,
          max: 100,
          step: 1,
          largeStep: 25,
          validators: const [],
          forceError: false,
        );
        c.bump(1);
        expect(c.value, 11);
        c.bumpLarge(1);
        expect(c.value, 36);
        c.bumpLarge(1);
        c.bumpLarge(1);
        c.bumpLarge(1); // 36 -> 61 -> 86 -> 111 clamped to 100
        expect(c.value, 100);
        c.bump(-1);
        expect(c.value, 99);
        c.dispose();
      });

      test('largeStep defaults to step * 10', () {
        final c = SuperNumericFieldController(initialValue: 0);
        c.configure(step: 5, validators: const [], forceError: false);
        c.bumpLarge(1);
        expect(c.value, 50);
        c.dispose();
      });
    });
  });
}
