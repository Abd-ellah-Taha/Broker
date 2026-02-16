# إعداد Firebase وربط قاعدة البيانات

## الخطوة 1: إنشاء Firestore Database

1. افتح: **https://console.firebase.google.com/project/broker-9abf6**
2. من القائمة الجانبية اختر **Firestore Database**
3. اضغط **Create database**
4. اختر **Start in test mode** (للاختبار) أو **Production mode** ثم اضغط **Next**
5. اختر الموقع (مثلاً `eur3` لأوروبا) واضغط **Enable**

---

## الخطوة 2: تطبيق قواعد الأمان (Security Rules)

1. في صفحة Firestore، اذهب إلى تبويب **Rules**
2. استبدل المحتوى بـ:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && request.auth.uid == userId;
    }
    match /properties/{propertyId} {
      allow read: if true;
      allow create, update, delete: if request.auth != null;
    }
    match /chats/{chatId}/messages/{messageId} {
      allow read, write: if request.auth != null;
    }
    match /bookings/{bookingId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. اضغط **Publish**

---

## الخطوة 3: تفعيل Authentication

1. من القائمة اختر **Authentication** → **Get started**
2. في تبويب **Sign-in method** فعّل:
   - **Phone** (لتسجيل الدخول برقم الموبايل)
   - **Google** (لتسجيل الدخول بحساب Google)

---

## الخطوة 4: تفعيل Storage (لرفع الصور)

1. من القائمة اختر **Storage** → **Get started**
2. اختر **Start in test mode** واضغط **Next** → **Done**

---

## الخطوة 5: تفعيل Firestore في التطبيق

في ملف `lib/core/config/app_config.dart` غيّر:

```dart
const bool useFirestore = true;
```

---

## الخطوة 6: إعادة تشغيل التطبيق

```bash
flutter run -d chrome
```

---

## التحقق من الربط

- افتح **لوحة الأدمن** من القائمة
- تبويب **المستخدمين**: سيكون فارغاً حتى تسجّل دخولاً
- تبويب **العقارات**: سيكون فارغاً حتى تضيف عقاراً (بعد تسجيل الدخول كـ Owner)
- سجّل الدخول من التطبيق وسيظهر المستخدم في تبويب المستخدمين
