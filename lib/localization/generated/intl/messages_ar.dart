// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ar';

  static String m0(count) => "أرفق ${count} ملفات على الأكثر";

  static String m1(count) => "${count} ملف";

  static String m2(name) => "\"${name}\" ليس من نوع مقبول";

  static String m3(name, size) => "\"${name}\" يتجاوز ${size} م.ب";

  static String m4(count) => "يجب ألا يزيد عن ${count} أحرف";

  static String m5(value) => "يجب أن يكون في أو قبل ${value}";

  static String m6(count) => "حد أقصى ${count}";

  static String m7(value) => "يجب ألا يزيد عن ${value}";

  static String m8(count) => "يجب ألا يقل عن ${count} أحرف";

  static String m9(value) => "يجب أن يكون في أو بعد ${value}";

  static String m10(value) => "يجب ألا يقل عن ${value}";

  static String m11(count) => "أدخل الرمز الكامل المكوّن من ${count} خانات";

  static String m12(name) => "إزالة ${name}";

  static String m13(count) => "اختر ${count} خيارات على الأقل";

  static String m14(count) => "اختر ${count} خيارات على الأكثر";

  static String m15(count) => "${count} محدد";

  static String m16(size) => "حتى ${size} م.ب";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "april": MessageLookupByLibrary.simpleMessage("أبريل"),
        "atLeastOneFileRequired":
            MessageLookupByLibrary.simpleMessage("مطلوب ملف واحد على الأقل"),
        "attachAtMostFiles": m0,
        "august": MessageLookupByLibrary.simpleMessage("أغسطس"),
        "browse": MessageLookupByLibrary.simpleMessage("استعراض"),
        "browseOrDragFilesHere":
            MessageLookupByLibrary.simpleMessage("استعرض أو اسحب الملفات هنا"),
        "cannotBeNegative": MessageLookupByLibrary.simpleMessage(
            "لا يمكن أن تكون القيمة سالبة"),
        "clear": MessageLookupByLibrary.simpleMessage("مسح"),
        "close": MessageLookupByLibrary.simpleMessage("إغلاق"),
        "december": MessageLookupByLibrary.simpleMessage("ديسمبر"),
        "decrement": MessageLookupByLibrary.simpleMessage("إنقاص"),
        "demoFillExamples":
            MessageLookupByLibrary.simpleMessage("تعبئة الأمثلة"),
        "demoFormCompletionAndSavedValuesSubtitle":
            MessageLookupByLibrary.simpleMessage(
                "قيم الإكمال وFormState.save()"),
        "demoFormResultTitle":
            MessageLookupByLibrary.simpleMessage("نتيجة النموذج"),
        "demoFormSavedValuesSubtitle": MessageLookupByLibrary.simpleMessage(
            "القيم المستلمة عبر FormState.save()"),
        "demoNotSaved": MessageLookupByLibrary.simpleMessage("لم يُحفظ"),
        "demoNotSavedYet": MessageLookupByLibrary.simpleMessage("لم يُحفظ بعد"),
        "demoReset": MessageLookupByLibrary.simpleMessage("إعادة تعيين"),
        "demoValidateAndSave":
            MessageLookupByLibrary.simpleMessage("تحقق واحفظ"),
        "disabled": MessageLookupByLibrary.simpleMessage("معطّل"),
        "dragFilesHere":
            MessageLookupByLibrary.simpleMessage(" أو اسحب الملفات هنا"),
        "enabled": MessageLookupByLibrary.simpleMessage("مفعّل"),
        "february": MessageLookupByLibrary.simpleMessage("فبراير"),
        "fileCount": m1,
        "fileNotAccepted": m2,
        "fileTooLarge": m3,
        "hide": MessageLookupByLibrary.simpleMessage("إخفاء"),
        "increment": MessageLookupByLibrary.simpleMessage("زيادة"),
        "invalidFormat": MessageLookupByLibrary.simpleMessage("تنسيق غير صحيح"),
        "january": MessageLookupByLibrary.simpleMessage("يناير"),
        "july": MessageLookupByLibrary.simpleMessage("يوليو"),
        "june": MessageLookupByLibrary.simpleMessage("يونيو"),
        "march": MessageLookupByLibrary.simpleMessage("مارس"),
        "maxCharacters": m4,
        "maxDate": m5,
        "maxFiles": m6,
        "maxNumber": m7,
        "may": MessageLookupByLibrary.simpleMessage("مايو"),
        "minCharacters": m8,
        "minDate": m9,
        "minNumber": m10,
        "mustBeEnabled": MessageLookupByLibrary.simpleMessage(
            "يجب تفعيل هذا الخيار للمتابعة"),
        "noMatches": MessageLookupByLibrary.simpleMessage("لا توجد نتائج"),
        "november": MessageLookupByLibrary.simpleMessage("نوفمبر"),
        "october": MessageLookupByLibrary.simpleMessage("أكتوبر"),
        "openCalendar": MessageLookupByLibrary.simpleMessage("فتح التقويم"),
        "otpBackupCodeHelper": MessageLookupByLibrary.simpleMessage(
            "تُحوّل الأحرف إلى أحرف كبيرة."),
        "otpBackupCodeLabel":
            MessageLookupByLibrary.simpleMessage("الرمز الاحتياطي"),
        "otpBackupCodeResultLabel":
            MessageLookupByLibrary.simpleMessage("الرمز الاحتياطي"),
        "otpBackupSubtitle": MessageLookupByLibrary.simpleMessage(
            "تخصيص لوحة المفاتيح وتركيب المنسقات"),
        "otpBackupTitle":
            MessageLookupByLibrary.simpleMessage("رمز احتياطي أبجدي رقمي"),
        "otpCodesSavedSuccessfully":
            MessageLookupByLibrary.simpleMessage("تم حفظ رموز التحقق بنجاح."),
        "otpDemoCardSubtitle": MessageLookupByLibrary.simpleMessage(
            "تعبئة SMS تلقائيًا · لصق · PIN آمن · إكمال"),
        "otpDemoCardTitle":
            MessageLookupByLibrary.simpleMessage("حقل رمز التحقق"),
        "otpDemoEyebrow":
            MessageLookupByLibrary.simpleMessage("حقل OTP • رموز التحقق"),
        "otpDemoTitle": MessageLookupByLibrary.simpleMessage("أمثلة حقل OTP"),
        "otpLastCompletedLabel":
            MessageLookupByLibrary.simpleMessage("آخر رمز مكتمل"),
        "otpLength": m11,
        "otpPinResultLabel": MessageLookupByLibrary.simpleMessage("PIN"),
        "otpPinSubtitle": MessageLookupByLibrary.simpleMessage(
            "أربعة أرقام تُعرض باستخدام رمز إخفاء"),
        "otpPinTitle":
            MessageLookupByLibrary.simpleMessage("رقم PIN آمن للمعاملة"),
        "otpSmsCodeLabel": MessageLookupByLibrary.simpleMessage("رمز SMS"),
        "otpSmsSubtitle": MessageLookupByLibrary.simpleMessage(
            "اللصق والتعبئة التلقائية لرمز الاستخدام الواحد مع الإكمال"),
        "otpSmsTitle": MessageLookupByLibrary.simpleMessage("رمز تحقق عبر SMS"),
        "otpTransactionPinHelper": MessageLookupByLibrary.simpleMessage(
            "تبقى الأرقام الفعلية متاحة للحفظ."),
        "otpTransactionPinLabel":
            MessageLookupByLibrary.simpleMessage("رقم PIN للمعاملة"),
        "otpVerificationCodeHelper": MessageLookupByLibrary.simpleMessage(
            "تم إرسال رمز من ستة أرقام إلى هاتفك."),
        "otpVerificationCodeHint":
            MessageLookupByLibrary.simpleMessage("أدخل الرمز المرسل عبر SMS"),
        "otpVerificationCodeLabel":
            MessageLookupByLibrary.simpleMessage("رمز التحقق"),
        "phoneCountryRulesSubtitle": MessageLookupByLibrary.simpleMessage(
            "ادمج نوع الهاتف مع البادئة والقناع والنمط"),
        "phoneCountryRulesTitle":
            MessageLookupByLibrary.simpleMessage("قواعد خاصة بالدولة"),
        "phoneDemoCardSubtitle": MessageLookupByLibrary.simpleMessage(
            "دولي · قواعد الدولة · المنسقات · حفظ النموذج"),
        "phoneDemoCardTitle":
            MessageLookupByLibrary.simpleMessage("حقل رقم الهاتف"),
        "phoneDemoEyebrow":
            MessageLookupByLibrary.simpleMessage("حقل نصي • إدخال الهاتف"),
        "phoneDemoTitle":
            MessageLookupByLibrary.simpleMessage("أمثلة حقل الهاتف"),
        "phoneInternationalHelper": MessageLookupByLibrary.simpleMessage(
            "يقبل الأرقام والمسافات والأقواس وعلامة + والشرطات."),
        "phoneInternationalHint":
            MessageLookupByLibrary.simpleMessage("مثال: ‎+1 (415) 555-0132"),
        "phoneInternationalResultLabel":
            MessageLookupByLibrary.simpleMessage("الدولي"),
        "phoneInternationalSubtitle": MessageLookupByLibrary.simpleMessage(
            "لوحة مفاتيح الهاتف مع الرموز الدولية الشائعة"),
        "phoneInternationalTitle":
            MessageLookupByLibrary.simpleMessage("رقم دولي"),
        "phoneNumberLabel": MessageLookupByLibrary.simpleMessage("رقم الهاتف"),
        "phoneNumbersSavedSuccessfully":
            MessageLookupByLibrary.simpleMessage("تم حفظ أرقام الهاتف بنجاح."),
        "phoneYemenMobileHelper": MessageLookupByLibrary.simpleMessage(
            "البادئات الصحيحة: 70 أو 71 أو 73 أو 77 أو 78."),
        "phoneYemenMobileHint":
            MessageLookupByLibrary.simpleMessage("7X XXX XXXX"),
        "phoneYemenMobileInvalid":
            MessageLookupByLibrary.simpleMessage("أدخل رقم جوال يمني صحيح."),
        "phoneYemenMobileLabel":
            MessageLookupByLibrary.simpleMessage("رقم جوال يمني"),
        "phoneYemenResultLabel": MessageLookupByLibrary.simpleMessage("اليمن"),
        "pickDateFromCalendar":
            MessageLookupByLibrary.simpleMessage("اختر تاريخًا من التقويم"),
        "removeFile": m12,
        "requiredMessage":
            MessageLookupByLibrary.simpleMessage("هذا الحقل مطلوب"),
        "search": MessageLookupByLibrary.simpleMessage("بحث..."),
        "selectAtLeastOneOption": MessageLookupByLibrary.simpleMessage(
            "اختر خيارًا واحدًا على الأقل"),
        "selectAtLeastOptions": m13,
        "selectAtMostOptions": m14,
        "selectDate": MessageLookupByLibrary.simpleMessage("اختر التاريخ"),
        "selectOption": MessageLookupByLibrary.simpleMessage("اختر خيارًا"),
        "selectPlaceholder": MessageLookupByLibrary.simpleMessage("اختر..."),
        "selectedCount": m15,
        "september": MessageLookupByLibrary.simpleMessage("سبتمبر"),
        "show": MessageLookupByLibrary.simpleMessage("إظهار"),
        "today": MessageLookupByLibrary.simpleMessage("اليوم"),
        "upToMegabytes": m16,
        "validDate":
            MessageLookupByLibrary.simpleMessage("أدخل تاريخًا صحيحًا"),
        "validEmail": MessageLookupByLibrary.simpleMessage(
            "أدخل بريدًا إلكترونيًا صحيحًا"),
        "weekdayFridayNarrow": MessageLookupByLibrary.simpleMessage("ج"),
        "weekdayMondayNarrow": MessageLookupByLibrary.simpleMessage("ن"),
        "weekdaySaturdayNarrow": MessageLookupByLibrary.simpleMessage("س"),
        "weekdaySundayNarrow": MessageLookupByLibrary.simpleMessage("ح"),
        "weekdayThursdayNarrow": MessageLookupByLibrary.simpleMessage("خ"),
        "weekdayTuesdayNarrow": MessageLookupByLibrary.simpleMessage("ث"),
        "weekdayWednesdayNarrow": MessageLookupByLibrary.simpleMessage("ر")
      };
}
