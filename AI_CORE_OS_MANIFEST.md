# AI CORE OS - MANIFEST - دستور المشروع

## رؤية المشروع
> "Everything disappears except the conversation."

AI CORE OS هو نظام تشغيل ذكاء اصطناعي شخصي، قابل للتوسع، سريع، وهوية بصرية مميزة. ليس مجرد تطبيق شات.

## قواعد التصميم

1. **لا يوجد زر بدون وظيفة** - كل زر يعمل وله Feedback
2. **لا يوجد صفحة فارغة** - كل صفحة لها محتوى حقيقي أو رسالة واضحة
3. **لا يوجد انتقال مفاجئ** - كل انتقال Fade + Slide 300-500ms
4. **كل شيء يعمل بالسحب أو بضغطة واحدة** - Swipe Left/Right أو Tap
5. **أقل عدد ممكن من الأزرار** - المستخدم يرى البساطة، الذكاء يعمل في الخلفية
6. **Glassmorphism + Neon** - #050507 + Cyan #00D9FF + Purple #7C3AED + Blur 20-28px

## قواعد البرمجة

1. **Modular** - كل مكون في ملف مستقل <400 سطر
2. **Reusable** - أي Widget قابل لإعادة الاستخدام <250 سطر
3. **Clean Architecture** - Presentation / Logic / Engine / Data منفصلة
4. **No Business Logic in UI** - المنطق في Controllers/Services
5. **Features Only** - لا يوجد lib/pages/ - فقط features/ هو الرسمي
6. **Single Responsibility** - كل ملف مسؤول عن شيء واحد

## هيكل المجلدات V13 - 10/10

```
lib/
├── main.dart - نقطة دخول بسيطة جداً - runApp(AICoreApp())
│
├── core/ - الأساس
│   ├── app.dart - MaterialApp + Providers + home: BootPage
│   ├── app_theme.dart - #050507 + Neon + Glass
│   ├── app_router.dart - Router واحد - كل التنقل من هنا
│   ├── animations.dart - حركات موحدة 200/300/500ms
│   └── constants.dart - ثوابت
│
├── shared/ - مشترك
│   ├── widgets/
│   │   ├── glass_card.dart - Glass موحدة - رسمية
│   │   ├── glass_button.dart
│   │   └── glass_dialog.dart
│   ├── models/
│   │   ├── chat.dart
│   │   ├── message.dart
│   │   └── user_profile.dart
│   ├── services/
│   └── utils/
│
├── engines/ - محركات مستقلة
│   ├── memory/
│   ├── knowledge/
│   ├── decision/
│   ├── search/
│   ├── voice/
│   └── analytics/
│
└── features/ - الهيكل الرسمي الوحيد
    ├── boot/
    │   ├── pages/boot_page.dart - شاشة واحدة رسمية
    │   ├── controllers/boot_controller.dart
    │   ├── services/loading_service.dart + boot_state.dart
    │   └── widgets/boot_animation.dart
    │
    ├── chat/
    │   ├── pages/chat_home_page.dart - قلب التطبيق - <400 سطر
    │   ├── controllers/chat_controller.dart
    │   ├── models/message.dart
    │   ├── services/chat_service.dart
    │   └── widgets/
    │       ├── ai_header.dart - 67 سطر
    │       ├── chat_list.dart - 35 سطر
    │       ├── message_bubble.dart - 30 سطر
    │       ├── message_input.dart - 73 سطر
    │       ├── typing_indicator.dart - 25 سطر
    │       └── welcome_screen.dart - 42 سطر
    │
    ├── history/ - Feature مستقلة
    │   ├── pages/history_page.dart
    │   └── controllers/history_controller.dart
    │
    ├── memory/
    ├── knowledge/
    ├── decision/
    ├── control_center/ - مركز القيادة مستقل
    ├── settings/ - مستقلة
    └── about/
```

## خارطة الطريق

### V12.0 Foundation ✅
- [x] Boot Screen - شاشة سمرا + كورة حية
- [x] Chat Home - شات فقط - لا Dashboard
- [x] History Drawer - New Chat, Search, Favorites, Archive
- [x] Control Center - Memory, Knowledge, Decision, Analytics, Graph, Settings, About
- [x] Language Switch - Fade + لا يختفي

### V12.1 Clean Architecture ✅
- [x] حذف lib/pages/ - فقط features/
- [x] توحيد الأسماء - الملف = الكلاس
- [x] Widgets مستقلة <250 سطر
- [x] Glass Components موحدة
- [x] Router واحد

### V13 Professional - 10/10 🔥 (حالياً)
- [x] حذف كل التكرار - main_4, main_5, glass_widgets duplicate
- [x] Boot: Controller + Animation + Loading Service + Boot State منفصلة
- [x] Chat: controllers/ + models/ + services/ + widgets/ + pages/
- [x] History Feature مستقلة
- [x] Settings Feature مستقلة
- [x] Control Center Feature مستقلة
- [x] AI_CORE_OS_MANIFEST.md - دستور المشروع
- [x] كل ملف <400 سطر - كل Widget <250 سطر

### V13.1 Next
- [ ] History Drawer احترافي بمستوى ChatGPT - بحث فوري + تثبيت + سحب للحذف
- [ ] Control Center احترافي - Profile + Synced + Glow للنشط
- [ ] Language Switch شفاف 20%
- [ ] Mini AI Chat Overlay فوق كل الصفحات
- [ ] ربط Memory Engine بالواجهة - Pinterest Masonry + Scores

### V14 Intelligence
- [ ] Memory Graph تفاعلي - Zoom, Drag, Search
- [ ] Universal Search - يبحث في كل شيء
- [ ] Analytics حقيقية
- [ ] Voice Assistant

### V15 OS
- [ ] Workspaces
- [ ] Goals
- [ ] Plugins Store
- [ ] Cloud Sync
- [ ] Multi AI Models

## معايير الجودة - Definition of Done

لن نعتبر أي Sprint منتهياً إلا إذا:
- ✅ يعمل بالكامل بدون أخطاء
- ✅ واجهة موحدة في جميع الصفحات
- ✅ انتقالات سلسة Fade/Slide
- ✅ دعم العربية والإنجليزية
- ✅ هيكل نظيف قابل للتوسع
- ✅ أداء سريع حتى مع آلاف الرسائل
- ✅ كل ملف <400 سطر - كل Widget <250 سطر
- ✅ لا يوجد زر بدون وظيفة - لا يوجد صفحة فارغة

## الأفكار المؤجلة - Backlog
- Command Palette (⌘K)
- AI Orb - كرة مضيئة تمثل حالة الذكاء
- Dynamic Background - Particles + Neural Lines
- Workspaces + Goals + Timeline
- Plugin Store

## هوية التصميم - AI CORE OS
- **لن ننسخ ChatGPT, Gemini, Claude**
- **هنبني هوية خاصة**
- الخلفية: #050507 أسود مائل للرمادي
- النص: أبيض
- الرئيسي: Cyan #00D9FF
- الثانوي: Purple #7C3AED
- النجاح: Emerald #10B981
- Glass: blur 20-28px + border 1px + radius 20-28px

---
**AI CORE OS V13 - Foundation for Millions of Users** 🚀
