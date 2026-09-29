# ✈️ SplitEasy — Single-Admin Trip Expense Manager

**SplitEasy** is a modern, responsive, cross-platform trip expense-splitting application built with **Flutter**, **GetX**, and **Supabase**. It is architected specifically as a **Single-Admin Trip Expense Manager**: one app owner/admin securely logs in, creates trips, manages trip participants, and records shared expenses with accurate Splitwise-style expense splitting (*Equal, Unequal/Exact Amount, and Percentage splits*) and automated debt simplification settlements.

---

## ✨ Core Features & Capabilities

- 🔑 **Single-Admin Authentication:** Secure Admin Sign-In using Supabase Auth (Email + Password). No registration flow, social logins, or multi-user authentication required.
- 🧳 **Trip Management:** Full CRUD operations for trips (*Name, Destination, Start & End Dates, Description*).
- 👥 **Participant Management:** Admin can add and manage trip participants (*Name, optional Phone Number*) per trip without requiring them to create user accounts or passwords.
- 💵 **Flexible Expense Splitting Engine:**
  - **Equal Split:** Divides expenses equally among selected participants with exact penny-rounding adjustment (`SUM(shares) == total_amount` exactly to 2 decimal places).
  - **Unequal / Exact Split:** Assigns custom monetary amounts to each participant with strict sum validation (`SUM(shares) == total_amount`).
  - **Percentage Split:** Calculates shares dynamically based on custom percentages (`SUM(percentages) == 100.0%`).
- 📊 **Balance Engine:** Instantly calculates total paid, total share, and net balances (`Total Paid - Total Share`) per participant (*Creditor / Debtor / Settled*).
- 🤝 **Simplify Debts:** Automatically generates optimal "Who Owes Whom" settlement transactions to settle all trip debts with minimum payment transactions.
- 📱 **Responsive & Adaptive UI:** Flawlessly scales across Mobile (Bottom Navigation Bar, horizontal scrollable metric cards), Tablet, Laptop, and Wide Desktop Web monitors (Side NavigationRail, Centered Content Max-Width).
- 🌓 **Material 3 Theming:** Full Light and Dark theme configurations.

---

## 🛠️ Tech Stack & Architecture

- **Framework:** [Flutter](https://flutter.dev) (Dart SDK `>=3.12.2`)
- **State Management & Routing:** [GetX](https://pub.dev/packages/get) (`GetxController`, `Obx`, `GetPage` named routes, GetX Bindings)
- **Backend & Database:** [Supabase](https://supabase.com) (Auth, PostgreSQL DB, Row Level Security)
- **Responsive Layout:** Custom Responsive Design System (`ResponsiveLayout`, `CenteredContentWrapper`, `AppResponsive`) + `flutter_screenutil`
- **Formatting & Utilities:** `intl`, `cupertino_icons`

---

## 📂 Project Structure

```
lib/
 ├── main.dart                          # App startup & Supabase initialization
 ├── app/
 │   ├── config/
 │   │   └── supabase_config.dart       # Configurable Supabase URL & Anon Key
 │   ├── routes/
 │   │   ├── app_routes.dart            # Named route string constants
 │   │   └── app_pages.dart             # GetPage route configurations
 │   ├── theme/
 │   │   ├── app_colors.dart            # Brand palette (Emerald Teal, Owe Red, Owed Green)
 │   │   ├── app_text_styles.dart       # Responsive typography scale
 │   │   └── app_theme.dart            # Material 3 Light & Dark ThemeData
 │   └── bindings/
 │       └── initial_binding.dart       # Global GetX services binding
 ├── data/
 │   ├── models/
 │   │   ├── trip_model.dart            # Trip model
 │   │   ├── trip_person_model.dart     # Trip participant model
 │   │   ├── trip_expense_model.dart    # Trip expense model
 │   │   ├── expense_split_model.dart   # Individual expense split model
 │   │   └── balance_model.dart         # Net balance & settlement suggestion model
 │   └── services/
 │       ├── supabase_service.dart      # Shared SupabaseClient instance
 │       ├── auth_service.dart          # Admin Auth operations
 │       ├── trip_service.dart          # Trips & Trip People DB operations
 │       ├── expense_service.dart       # Expenses & Splits DB operations
 │       └── balance_service.dart       # Balance engine & Debt simplification math
 ├── modules/
 │   ├── splash/                        # Animated Splash Screen
 │   ├── auth/                          # Admin Login Screen & Controller
 │   ├── main_navigation/               # Responsive Shell Container (Bottom Bar / Nav Rail)
 │   ├── home/                          # Admin Home Overview & Summary Cards
 │   ├── trips/                         # Trips List, Create/Edit Trip & Trip Detail
 │   ├── people/                        # Manage Trip Participants
 │   ├── expenses/                      # Add/Edit Expense & Expense Details
 │   └── profile/                       # Admin Profile & Logout
 └── widgets/
     ├── custom_button.dart             # Stylized primary/outlined button
     ├── custom_textfield.dart          # Custom text input with validation styling
     ├── custom_toast.dart              # Styled Get.snackbar alerts
     ├── responsive_layout.dart         # Breakpoint builder & content wrapper
     └── loading_indicator.dart        # Smooth circular loading indicator
```

---

## 🗄️ Database Schema & Setup

For full backend operation, create the following public tables in your Supabase project:

### 1. `trips`
- `id` (uuid, primary key, default `gen_random_uuid()`)
- `owner_id` (uuid, references `auth.users(id)`)
- `name` (text, not null)
- `destination` (text)
- `start_date` (timestamptz)
- `end_date` (timestamptz)
- `description` (text)
- `created_at` (timestamptz, default `now()`)
- `updated_at` (timestamptz, default `now()`)

### 2. `trip_people`
- `id` (uuid, primary key, default `gen_random_uuid()`)
- `trip_id` (uuid, references `public.trips(id)` on delete cascade)
- `name` (text, not null)
- `phone` (text)
- `created_at` (timestamptz, default `now()`)
- `updated_at` (timestamptz, default `now()`)

### 3. `trip_expenses`
- `id` (uuid, primary key, default `gen_random_uuid()`)
- `trip_id` (uuid, references `public.trips(id)` on delete cascade)
- `description` (text, not null)
- `total_amount` (numeric, not null)
- `paid_by_person_id` (uuid, references `public.trip_people(id)`)
- `category` (text)
- `split_type` (text, not null — `equal`, `unequal`, `percentage`)
- `expense_date` (timestamptz, not null)
- `note` (text)
- `created_at` (timestamptz, default `now()`)
- `updated_at` (timestamptz, default `now()`)

### 4. `expense_splits`
- `id` (uuid, primary key, default `gen_random_uuid()`)
- `expense_id` (uuid, references `public.trip_expenses(id)` on delete cascade)
- `person_id` (uuid, references `public.trip_people(id)`)
- `share_amount` (numeric, not null)
- `share_percentage` (numeric)
- `created_at` (timestamptz, default `now()`)

---

## 🚀 Getting Started & Installation

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.12.2`)
- [Dart SDK](https://dart.dev/get-dart)
- An active [Supabase](https://supabase.com) Project

### Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/spliteasy-flutter.git
   cd spliteasy-flutter
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase Credentials:**
   Update your credentials in `lib/app/config/supabase_config.dart` or supply them via `--dart-define`:
   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=https://your-project.supabase.co \
     --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```

4. **Run the application:**
   - **Android / iOS:**
     ```bash
     flutter run
     ```
   - **Flutter Web:**
     ```bash
     flutter run -d chrome
     ```

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

This project is licensed under the MIT License.
