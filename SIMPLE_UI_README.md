# Netru App - النسخة البسيطة للمواطن المصري

## التحديثات الجديدة

تم تبسيط التطبيق بشكل كامل ليكون مناسباً للمواطن المصري البسيط:

### الميزات الجديدة

#### 1. صفحة تسجيل الدخول البسيطة
- **الملف**: `lib/features/auth/presentation/pages/simple_login_page.dart`
- **الميزات**:
  - تصميم بسيط وواضح
  - إمكانية تسجيل الدخول بالبريد الإلكتروني أو الرقم القومي
  - رسائل خطأ واضحة باللغة العربية
  - بدون تعقيدات أو أنيميشن مفرطة

#### 2. صفحة إنشاء حساب جديد بسيطة
- **الملف**: `lib/features/auth/presentation/pages/simple_signup_page.dart`
- **الميزات**:
  - نموذج واحد بسيط
  - اختيار نوع المستخدم (مواطن مصري / مقيم أجنبي)
  - حقول أساسية فقط
  - تحقق بسيط من البيانات

#### 3. مكونات واجهة بسيطة (Simple Widgets)
- **الملف**: `lib/features/auth/presentation/widgets/simple_auth_widgets.dart`
- **المكونات**:
  - `SimpleTextField`: حقل نص بسيط وواضح
  - `SimpleButton`: زر بسيط مع تحميل
  - `SimpleSelectionCard`: بطاقة اختيار بسيطة
  - `SimpleHeader`: عنوان بسيط
  - `SimpleMessageBox`: مربع رسالة بسيط

### التحسينات

#### 1. إزالة تسجيل الدخول بـ Google
- تم حذف جميع ملفات ومراجع Google Sign In
- تم تبسيط عملية التسجيل لتعتمد على البيانات الأساسية فقط

#### 2. حذف الملفات المعقدة
تم حذف الملفات التالية لتبسيط التطبيق:
- `enhanced_login_page.dart`
- `enhanced_signup_page.dart`
- `enhanced_signup_page_v2.dart`
- `document_camera_screen.dart`
- `document_scanner_widget.dart`
- `modern_document_scanner_widget.dart`
- `enhanced_location_selector.dart`
- `location_selection_sheet.dart`
- `signin_with_google.dart`

#### 3. تحسين Core Widgets
- **CustomButton**: زر بسيط مع ظلال وألوان واضحة
- **CustomTextField**: حقل نص مع focus states بسيطة
- **CustomLoading**: شاشة تحميل بسيطة وواضحة

### كيفية الاستخدام

#### استخدام الصفحات الجديدة:

```dart
// استخدام صفحة تسجيل الدخول البسيطة
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SimpleLoginPage()),
);

// استخدام صفحة إنشاء حساب جديد بسيطة
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SimpleSignupPage()),
);
```

#### استخدام المكونات البسيطة:

```dart
// حقل نص بسيط
SimpleTextField(
  label: "البريد الإلكتروني",
  hint: "أدخل بريدك الإلكتروني",
  controller: emailController,
  icon: Icons.email,
  validator: (value) => value?.isEmpty == true ? "مطلوب" : null,
)

// زر بسيط
SimpleButton(
  text: "تسجيل الدخول",
  onPressed: () => _login(),
  icon: Icons.login,
  isLoading: isLoading,
)

// بطاقة اختيار
SimpleSelectionCard(
  title: "مواطن مصري",
  subtitle: "بطاقة الرقم القومي",
  icon: Icons.location_on,
  isSelected: isEgyptian,
  onTap: () => setState(() => isEgyptian = true),
)
```

### المبادئ التوجيهية للتصميم

1. **البساطة**: تجنب التعقيدات والتأثيرات المفرطة
2. **الوضوح**: نصوص واضحة وأيقونات مفهومة
3. **اللغة العربية**: جميع النصوص والرسائل بالعربية
4. **الألوان البسيطة**: استخدام ألوان هادئة وواضحة
5. **التنظيم**: ترتيب منطقي للعناصر
6. **سهولة الوصول**: أزرار كبيرة وحقول واضحة

### ملاحظات مهمة

- التطبيق الآن يركز على المواطن المصري البسيط
- تم إزالة جميع الميزات المعقدة غير الضرورية
- الكود أصبح أكثر تنظيماً وقابلية للصيانة
- المكونات قابلة لإعادة الاستخدام في أجزاء أخرى من التطبيق
