# دليل اختبار تطبيق Broker

## المتطلبات

1. **Flutter SDK** (3.2+)
   ```bash
   flutter doctor
   ```

2. **مجلدات المنصات** (android, ios, web):
   ```bash
   cd /home/abd-ellah/Desktop/Broker
   flutter create .
   ```
   (سيضيف المجلدات الناقصة دون تعديل lib/ و pubspec.yaml)

3. **Firebase** (للمصادقة والحفظ):
   ```bash
   dart run flutterfire_cli:flutterfire configure
   ```

4. **Google Maps API Key** (للخريطة):
   - Android: `android/app/src/main/AndroidManifest.xml`
   - iOS: `ios/Runner/AppDelegate.swift`
   - Web: `web/index.html`

5. **Gemini API Key** (لوصف الصور بالذكاء الاصطناعي):
   ```bash
   flutter run --dart-define=GEMINI_API_KEY=your_key_here
   ```

---

## تشغيل التطبيق

```bash
cd /home/abd-ellah/Desktop/Broker
flutter pub get
flutter run -d chrome
```

أو على جهاز/محاكي أندرويد:
```bash
flutter run
```

---

## سيناريوهات الاختبار

### 1. المصادقة (Auth)

| الخطوة | الإجراء | النتيجة المتوقعة |
|--------|---------|------------------|
| 1 | افتح التطبيق | يتم توجيهك إلى شاشة تسجيل الدخول |
| 2 | أدخل رقم هاتف مصري (مثل 01234567890) واضغط "Send OTP" | يصل رمز OTP (مع تفعيل Firebase Phone Auth) |
| 3 | أدخل الرمز واضغط "Verify" | شاشة اختيار الدور (Seeker/Owner) |
| 4 | اختر "Owner" واضغط "Continue" | الشاشة الرئيسية |
| 5 | من القائمة اختر "Sign out" | العودة إلى شاشة تسجيل الدخول |
| 6 | اضغط "Continue with Google" | تسجيل دخول بحساب Google ثم الشاشة الرئيسية |

### 2. العقارات (Listings)

| الخطوة | الإجراء | النتيجة المتوقعة |
|--------|---------|------------------|
| 1 | سجل دخول كـ Owner | يظهر زر "Add Property" |
| 2 | اضغط "Add Property" | فتح نموذج إضافة عقار |
| 3 | املأ الحقول (Title, Description, Price، إلخ) واضغط "Add Property" | إضافة العقار وعودتك للرئيسية |
| 4 | ابحث عن العقار في خانة البحث | ظهور العقار في القائمة |
| 5 | اضغط على عقار | فتح صفحة التفاصيل |

### 3. الصور والذكاء الاصطناعي

| الخطوة | الإجراء | النتيجة المتوقعة |
|--------|---------|------------------|
| 1 | في نموذج إضافة عقار، اضغط "Add Photos" | فتح منتقي الصور |
| 2 | اختر صورة عقار واضغط "AI Desc" | ملء حقل الوصف تلقائياً (يتطلب GEMINI_API_KEY) |

### 4. الدردشة (Chat)

| الخطوة | الإجراء | النتيجة المتوقعة |
|--------|---------|------------------|
| 1 | سجل دخول كـ Seeker واضغط على عقار | صفحة التفاصيل |
| 2 | اضغط "Chat with Owner" | شاشة الدردشة |
| 3 | اكتب رسالة تحتوي رقم هاتف أو رابط | يتم استبدالها بـ [PHONE] و [LINK] |

### 5. الحجز (Booking)

| الخطوة | الإجراء | النتيجة المتوقعة |
|--------|---------|------------------|
| 1 | من صفحة عقار اضغط "Book a Visit" | شاشة الحجز |
| 2 | اختر تاريخ ووقت واضغط "Confirm Booking" | رسالة تأكيد الحجز |

### 6. Escrow (رسوم الجدية)

| الخطوة | الإجراء | النتيجة المتوقعة |
|--------|---------|------------------|
| 1 | من صفحة عقار اضغط "Seriousness Fee" | شاشة Escrow تعرض 1% من السعر |
| 2 | اضغط "Pay Seriousness Fee" | محاكاة الدفع ثم رسالة تأكيد |

### 7. لوحة الأدمن

| الخطوة | الإجراء | النتيجة المتوقعة |
|--------|---------|------------------|
| 1 | سجل دخول بحساب admin | يظهر خيار "Admin" في القائمة |
| 2 | اضغط "Admin" | فتح لوحة الأدمن |
| 3 | في تبويب Listings اضغط أيقونة التحقق | تغيير حالة العقار (verified/pending) |
| 4 | في تبويب Users | عرض قائمة المستخدمين |

**ملاحظة:** لجعل المستخدم admin يدوياً أضف في Firestore:
`users/{userId}` → `role: "admin"`

---

## وضع Mock (بدون Firebase)

في `lib/core/config/app_config.dart`:
```dart
const bool useFirestore = false;
```

- استخدام بيانات تجريبية محلية
- Auth و Chat و Booking تتطلب Firebase
- العقارات تعمل بالبيانات الوهمية

---

## أخطاء شائعة

| الخطأ | السبب | الحل |
|-------|-------|------|
| Firebase not configured | إعدادات Firebase غير مكتملة | تشغيل `flutterfire configure` |
| MissingPluginException | المنصة غير مضافة | تشغيل `flutter create .` |
| Google Maps blank | عدم تعيين API Key | إضافة المفتاح لملفات المنصة |
| AI error | مفتاح Gemini غير صحيح أو غير معرّف | تشغيل مع `--dart-define=GEMINI_API_KEY=...` |
