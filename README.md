# 💸 SplitEasy — Expense Splitting App

**SplitEasy** is a modern, responsive, cross-platform expense-splitting application (Splitwise clone) built with **Flutter**, **GetX**, and **Supabase**. It allows users to track shared expenses, split bills equally or by custom amounts/percentages, attach receipts, manage groups and friends, and settle balances effortlessly across Android, iOS, and Web.

---

## ✨ Features

- 🔐 **Authentication:** Email & Password Sign Up / Login powered by Supabase Auth with automated profile synchronization.
- 👥 **Group Management:** Create groups with custom emoji icons, categories (*Trip, Home, Couple, Other*), and invite members.
- 💵 **Flexible Expense Splitting:**
  - **Equal Split:** Divide expenses equally among participants.
  - **Unequal Split:** Assign custom monetary amounts to each member.
  - **Percentage Split:** Calculate shares dynamically based on custom percentages.
- 🧾 **Receipt Photo Attachment:** Capture or pick receipt images using `image_picker` and upload them to Supabase Storage (`receipts` bucket).
- 📊 **Real-time Financial Summary:** Net balance cards (*"You owe"*, *"You are owed"*, *"Total balance"*) color-coded in green/red across groups and individual friends.
- 🤝 **Settlement Tracker:** Record payments between payers and payees with notes to settle outstanding debts.
- 📜 **Activity Feed:** Chronological timeline tracking expenses, settlements, and group activity using Supabase SQL views.
- 📱 **Responsive & Adaptive UI:** Mobile layout featuring a Bottom Navigation Bar and Desktop/Tablet layout featuring a Side Navigation Rail using `flutter_screenutil` and breakpoint containers.
- 🌓 **Material 3 Theming:** Full Light and Dark theme configurations.

---

## 🛠️ Tech Stack & Architecture

- **Framework:** [Flutter](https://flutter.dev) (latest stable)
- **State Management & Routing:** [GetX](https://pub.dev/packages/get) (`GetxController`, `Obx`, `GetPage` named routes, GetX Bindings)
- **Backend & Database:** [Supabase](https://supabase.com) (Auth, PostgreSQL DB, Row Level Security)
- **File Storage:** Supabase Storage (`avatars` and `receipts` buckets)
- **Responsive Layout:** `flutter_screenutil` + Custom Breakpoint System (`<600` Mobile, `≥600` Tablet/Desktop)
- **Formatting & Utilities:** `intl`, `image_picker`, `cupertino_icons`

---

## 📂 Folder Structure

```
lib/
 ├── main.dart                      # App entry point & Supabase initialization
 ├── app/
 │   ├── config/
 │   │   └── supabase_config.dart   # Configurable Supabase credentials
 │   ├── routes/
 │   │   ├── app_routes.dart        # Route string constants
 │   │   └── app_pages.dart         # GetPage route configurations
 │   ├── theme/
 │   │   ├── app_colors.dart        # Palette (Emerald Teal, Owe Red, Owed Green)
 │   │   ├── app_text_styles.dart   # Typography scale
 │   │   └── app_theme.dart        # Light & Dark ThemeData
 │   └── bindings/
 │       └── initial_binding.dart   # Global GetX services binding
 ├── data/
 │   ├── models/
 │   │   ├── user_model.dart        # User profile model
 │   │   ├── group_model.dart       # Group model
 │   │   ├── expense_model.dart     # Expense model
 │   │   ├── settlement_model.dart  # Payment settlement model
 │   │   └── activity_model.dart    # Activity feed model
 │   └── services/
 │       ├── supabase_service.dart  # Shared SupabaseClient instance
 │       ├── auth_service.dart      # Supabase Auth operations
 │       ├── group_service.dart     # Group CRUD operations
 │       ├── expense_service.dart   # Expense CRUD & receipt storage operations
 │       ├── friend_service.dart    # Friends management
 │       ├── settlement_service.dart# Payment settlement operations
 │       └── storage_service.dart   # Image picker & Supabase bucket uploader
 ├── modules/
 │   ├── splash/                    # Animated Splash Screen
 │   ├── auth/                      # Login & Register Screens & Controllers
 │   ├── main_navigation/           # Responsive Dashboard Container (Bottom Bar / Nav Rail)
 │   ├── home/                      # Home Overview & Summary Cards
 │   ├── groups/                    # Groups List, Create Group & Group Detail
 │   ├── expenses/                  # Add Expense & Live Split Calculator
 │   ├── balances/                  # Balances Breakdown
 │   ├── settle_up/                 # Record Payment Screen
 │   ├── friends/                   # Friends List & Search
 │   ├── activity/                  # Activity Timeline Feed
 │   └── profile/                   # View/Edit Profile & Logout
 └── widgets/
     ├── custom_button.dart         # Stylized primary/outlined button
     ├── custom_textfield.dart      # Custom input decoration textfield
     ├── custom_toast.dart          # Styled Get.snackbar alerts
     ├── balance_card.dart          # Overview financial card
     ├── responsive_layout.dart     # Breakpoint builder & content wrapper
     └── loading_indicator.dart    # Smooth circular loading indicator
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.12.2`)
- [Dart SDK](https://dart.dev/get-dart)
- An active [Supabase](https://supabase.com) Project

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/spliteasy-flutter.git
   cd spliteasy-flutter
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables (Optional):**
   You can pass custom Supabase credentials via `--dart-define`:
   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=https://your-project.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```
   *(By default, fallback values are configured in `lib/app/config/supabase_config.dart`)*.

4. **Run the application:**
   - **Android / iOS:**
     ```bash
     flutter run
     ```
   - **Web:**
     ```bash
     flutter run -d chrome
     ```

---

## 🗄️ Database Schema & Setup

For full setup, create the following tables and buckets in your Supabase Dashboard:

### Storage Buckets
- `avatars` (Public bucket)
- `receipts` (Public bucket)

### Tables & SQL View

- **`profiles`**: `id (uuid, pk)`, `name (text)`, `email (text)`, `phone (text)`, `gender (text)`, `avatar_path (text)`, `updated_at`
- **`friends`**: `id (uuid, pk)`, `user_id (uuid)`, `friend_id (uuid)`
- **`groups`**: `id (uuid, pk)`, `name (text)`, `icon (text)`, `category (text)`, `description (text)`, `created_by (uuid)`, `created_at`
- **`group_members`**: `id (uuid, pk)`, `group_id (uuid)`, `user_id (uuid)`
- **`expenses`**: `id (uuid, pk)`, `group_id (uuid, nullable)`, `description (text)`, `amount (numeric)`, `paid_by (uuid)`, `split_type (text)`, `split_details (jsonb)`, `category (text)`, `receipt_path (text)`, `participant_ids (array)`, `created_at`
- **`settlements`**: `id (uuid, pk)`, `group_id (uuid, nullable)`, `payer_id (uuid)`, `payee_id (uuid)`, `amount (numeric)`, `note (text)`, `created_at`
- **`activity_feed`** *(SQL View)*: Combines `expenses` and `settlements` ordered by `created_at DESC`.

---

## 🧪 Running Tests & Quality Check

Run static code analysis:
```bash
flutter analyze
```

Run unit & widget test suite:
```bash
flutter test
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
