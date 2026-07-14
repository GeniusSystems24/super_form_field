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
      expect(NumericLogic.clampRound(12.345, min: 0, max: 100, decimals: 2), 12.35);
      expect(NumericLogic.clampRound(-5, min: 0, max: 100, decimals: 0), 0);
      expect(NumericLogic.clampRound(150, min: 0, max: 100, decimals: 0), 100);
    });

    test('validators honor min/max and allowNegative', () {
      final v = NumericLogic.buildValidators(required: true, min: 0, max: 10, allowNegative: false);
      expect(runValidators<num?>(null, v), isNotNull);
      expect(runValidators<num?>(-1, v), 'Cannot be negative');
      expect(runValidators<num?>(11, v), isNotNull);
      expect(runValidators<num?>(5, v), isNull);
    });
  });

  group('AttachmentLogic', () {
    const pdf = SuperFile(id: '1', name: 'a.pdf', size: 1000, mimeType: 'application/pdf');
    const png = SuperFile(id: '2', name: 'b.png', size: 2000, mimeType: 'image/png');

    test('matchesAccept by extension and wildcard', () {
      expect(AttachmentLogic.matchesAccept(pdf, '.pdf,.docx'), isTrue);
      expect(AttachmentLogic.matchesAccept(png, '.pdf'), isFalse);
      expect(AttachmentLogic.matchesAccept(png, 'image/*'), isTrue);
    });

    test('field validators enforce required + maxFiles + per-file', () {
      final v = AttachmentLogic.buildValidators(required: true, maxFiles: 1, accept: '.pdf', maxSizeMB: 1);
      expect(runValidators<List<SuperFile>>(const [], v), isNotNull);
      expect(runValidators<List<SuperFile>>(const [pdf, png], v),
          isNotNull); // > maxFiles
      expect(runValidators<List<SuperFile>>(const [png], v),
          isNotNull); // wrong type
    });
  });

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

  group('DateLogic', () {
    test('mask inserts dashes after year and month', () {
      expect(DateLogic.mask('20240131'), '2024-01-31');
      expect(DateLogic.mask('2024'), '2024');
      expect(DateLogic.mask('202401'), '2024-01');
      expect(DateLogic.mask('a2024/01-31xx'), '2024-01-31'); // strips junk + caps at 8
    });

    test('parse accepts valid ISO, rejects incomplete + impossible dates', () {
      expect(DateLogic.parse('2024-01-31'), DateTime(2024, 1, 31));
      expect(DateLogic.parse('2024-01'), isNull); // incomplete
      expect(DateLogic.parse('2024-13-01'), isNull); // month out of range
      expect(DateLogic.parse('2024-02-31'), isNull); // overflow
      expect(DateLogic.parse(''), isNull);
    });

    test('format round-trips and pads', () {
      expect(DateLogic.format(DateTime(2024, 1, 5)), '2024-01-05');
      expect(DateLogic.format(null), '');
    });

    test('validators honor required + min/max bounds', () {
      final v = DateLogic.buildValidators(
        required: true,
        minDate: DateTime(2024, 1, 1),
        maxDate: DateTime(2024, 12, 31),
      );
      expect(runValidators<DateTime?>(null, v), isNotNull);
      expect(runValidators<DateTime?>(DateTime(2023, 12, 31), v), isNotNull); // before min
      expect(runValidators<DateTime?>(DateTime(2025, 1, 1), v), isNotNull); // after max
      expect(runValidators<DateTime?>(DateTime(2024, 6, 15), v), isNull);
    });
  });

  group('DateLogic.compose + formats', () {
    test('compose fills absent parts with defaults', () {
      expect(DateLogic.compose(year: 2024, month: 3, day: 9), DateTime(2024, 3, 9));
      // absent day → 1, absent month → 1
      expect(DateLogic.compose(year: 2024, month: 6), DateTime(2024, 6, 1));
      expect(DateLogic.compose(year: 2024), DateTime(2024, 1, 1));
      // impossible date → null
      expect(DateLogic.compose(year: 2024, month: 2, day: 31), isNull);
    });

    test('format segment maps + placeholders', () {
      expect(SuperDateFormat.yearMonthDay.segments, const [0, 1, 2]);
      expect(SuperDateFormat.yearMonth.segments, const [0, 1]);
      expect(SuperDateFormat.monthDay.segments, const [1, 2]);
      expect(SuperDateFormat.day.segments, const [2]);
      expect(SuperDateFormat.yearMonthDay.placeholder, 'YYYY-MM-DD');
      expect(SuperDateFormat.monthDay.placeholder, 'MM-DD');
      expect(SuperDateFormat.year.placeholder, 'YYYY');
    });
  });

  group('SuperDateFieldController stepping', () {
    test('segmentForOffset maps cursor to year/month/day', () {
      expect(SuperDateFieldController.segmentForOffset(0), 0); // YYYY
      expect(SuperDateFieldController.segmentForOffset(4), 0);
      expect(SuperDateFieldController.segmentForOffset(5), 1); // MM
      expect(SuperDateFieldController.segmentForOffset(7), 1);
      expect(SuperDateFieldController.segmentForOffset(8), 2); // DD
      expect(SuperDateFieldController.segmentForOffset(10), 2);
    });

    test('stepSegment changes the right unit and clamps day to month length', () {
      final c = SuperDateFieldController(initialValue: DateTime(2024, 1, 31));
      c.stepSegment(0, 1); // year +1
      expect(c.value, DateTime(2025, 1, 31));
      c.stepSegment(1, 1); // month +1 → Feb, day clamps 31 → 28 (2025 not leap)
      expect(c.value, DateTime(2025, 2, 28));
      c.dispose();
    });

    test('stepSegment wraps within the segment (no cross-segment roll)', () {
      final c = SuperDateFieldController(initialValue: DateTime(2025, 12, 28));
      c.stepSegment(1, 1); // Dec → Jan, stays in same year (segment wrap)
      expect(c.value!.month, 1);
      expect(c.value!.year, 2025);
      c.stepSegment(2, 1); // day 28 → 29 (Jan has 31)
      expect(c.value!.day, 29);
      c.dispose();
    });
  });

  group('SelectLogic', () {
    const opts = [
      SuperOption(value: 'asset', label: 'Asset', description: 'CC-100'),
      SuperOption(value: 'liability', label: 'Liability'),
      SuperOption(value: 'equity', label: 'Equity'),
    ];

    test('filter matches label and description, blank returns all', () {
      expect(SelectLogic.filter(opts, '').length, 3);
      expect(SelectLogic.filter(opts, 'lia').single.value, 'liability');
      expect(SelectLogic.filter(opts, 'cc-1').single.value, 'asset'); // description
      expect(SelectLogic.filter(opts, 'zzz'), isEmpty);
    });

    test('required validator', () {
      final v = SelectLogic.buildValidators<String>(required: true);
      expect(runValidators<String?>(null, v), isNotNull);
      expect(runValidators<String?>('asset', v), isNull);
    });
  });

  group('MultiSelectLogic', () {
    test('validators honor required + min + max', () {
      final v = MultiSelectLogic.buildValidators<String>(
          required: true, minSelections: 2, maxSelections: 3);
      expect(runValidators<List<String>>(const [], v), isNotNull); // required
      expect(runValidators<List<String>>(const ['a'], v), isNotNull); // < min
      expect(runValidators<List<String>>(const ['a', 'b', 'c', 'd'], v), isNotNull); // > max
      expect(runValidators<List<String>>(const ['a', 'b'], v), isNull);
    });
  });

  group('ChoiceLogic', () {
    test('validators honor required + min + max', () {
      final v = ChoiceLogic.buildValidators<String>(required: true, maxSelections: 2);
      expect(runValidators<List<String>>(const [], v), isNotNull);
      expect(runValidators<List<String>>(const ['a', 'b', 'c'], v), isNotNull);
      expect(runValidators<List<String>>(const ['a'], v), isNull);
    });
  });

  group('buildBoolValidators', () {
    test('mustBeTrue rejects false, accepts true', () {
      final v = buildBoolValidators(mustBeTrue: true);
      expect(runValidators<bool>(false, v), isNotNull);
      expect(runValidators<bool>(true, v), isNull);
    });
  });

  group('SuperSelectFieldController', () {
    const opts = [
      SuperOption(value: 'a', label: 'A'),
      SuperOption(value: 'b', label: 'B', disabled: true),
    ];

    test('select sets value + closes, disabled is ignored, clear resets', () {
      final c = SuperSelectFieldController<String>();
      c.configure(
        options: opts,
        validators: SelectLogic.buildValidators<String>(required: true),
        forceError: false,
      );
      c.open();
      expect(c.isOpen, isTrue);
      c.select(opts[0]);
      expect(c.value, 'a');
      expect(c.isOpen, isFalse);
      c.select(opts[1]); // disabled → no change
      expect(c.value, 'a');
      c.clear();
      expect(c.value, isNull);
      c.dispose();
    });
  });

  group('SuperMultiSelectFieldController', () {
    const opts = [
      SuperOption(value: 'a', label: 'A'),
      SuperOption(value: 'b', label: 'B'),
      SuperOption(value: 'c', label: 'C'),
    ];

    test('toggle adds/removes and honors the maxSelections cap', () {
      final c = SuperMultiSelectFieldController<String>();
      c.configure(
        options: opts,
        maxSelections: 2,
        validators: const [],
        forceError: false,
      );
      c.toggle(opts[0]);
      c.toggle(opts[1]);
      expect(c.values, ['a', 'b']);
      expect(c.atCapacity, isTrue);
      c.toggle(opts[2]); // blocked by cap
      expect(c.values, ['a', 'b']);
      c.toggle(opts[0]); // remove
      expect(c.values, ['b']);
      c.removeValue('b');
      expect(c.isEmpty, isTrue);
      c.dispose();
    });
  });

  group('SuperChoiceFieldController', () {
    test('single mode replaces, multiple mode toggles', () {
      final single = SuperChoiceFieldController<String>();
      single.configure(multiple: false, validators: const [], forceError: false);
      single.pick('a');
      single.pick('b');
      expect(single.values, ['b']); // replaced
      expect(single.single, 'b');

      final multi = SuperChoiceFieldController<String>();
      multi.configure(multiple: true, validators: const [], forceError: false);
      multi.pick('a');
      multi.pick('b');
      multi.pick('a'); // toggle off
      expect(multi.values, ['b']);
    });
  });

  group('SuperBoolFieldController', () {
    test('toggle flips value and marks touched; visibleError gates on touched', () {
      final c = SuperBoolFieldController(initialValue: false);
      c.configure(
        validators: buildBoolValidators(mustBeTrue: true),
        forceError: false,
      );
      expect(c.visibleError, isNull); // untouched
      c.toggle();
      expect(c.value, isTrue);
      expect(c.visibleError, isNull); // true → valid
      c.toggle();
      expect(c.value, isFalse);
      expect(c.visibleError, isNotNull); // touched + invalid
      c.dispose();
    });
  });
}
