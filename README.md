# ✈️ SplitEasy — Single-Admin Trip Expense Manager

**SplitEasy** is a modern, responsive, cross-platform trip expense-splitting application built with **Flutter**, **GetX**, and **Supabase**. It is designed specifically as a **Single-Admin Trip Expense Manager**: one app owner/admin manages trips, records participants, and logs shared expenses with accurate Splitwise-style expense splitting (*Equal, Unequal/Exact Amount, and Percentage splits*) and automated debt simplification settlements.

---

## ✨ Final Product Features

- 🔑 **Single-Admin Authentication:** Simple, secure Admin Sign-In using Supabase Auth (Email + Password). No registration flow, social login, or multi-user accounts required.
- 🧳 **Trip Management:** Full CRUD operations for trips (Name, Destination, Start & End Dates, Description).
- 👥 **Participant Management:** Admin can add and manage trip participants (Name, optional Phone Number) per trip without creating user accounts.
- 💵 **Flexible Expense Splitting:**
  - **Equal Split:** Divide expenses equally among selected participants with exact penny rounding adjustment (`SUM(shares) == total_amount`).
  - **Unequal / Exact Split:** Assign custom monetary amounts to each participant with sum validation (`SUM(shares) == total_amount`).
  - **Percentage Split:** Calculate shares dynamically based on custom percentages (`SUM(percentages) == 100%`).
- 📊 **Balance Engine:** Calculates total paid, total share, and net balances (+₹X green creditor, -₹Y red debtor, ₹0 settled) per participant.
- 🤝 **Debt Simplification Algorithm:** Automatically generates optimal "Who Owes Whom" settlement suggestions (e.g. `Suman → Rahul ₹1,000`).
- 📱 **Responsive & Adaptive UI:** Mobile layout featuring a Bottom Navigation Bar and Desktop/Tablet layout featuring a Side Navigation Rail using `flutter_screenutil`.
- 🌓 **Material 3 Theming:** Full Light and Dark theme configurations.

---

## 🛠️ Tech Stack & Architecture

- **Framework:** [Flutter](https://flutter.dev) (latest stable)
- **State Management & Routing:** [GetX](https://pub.dev/packages/get) (`GetxController`, `Obx`, `GetPage` named routes, GetX Bindings)
- **Backend & Database:** [Supabase](https://supabase.com) (Auth, PostgreSQL DB, Row Level Security)
- **Responsive Layout:** `flutter_screenutil` + Custom Breakpoint System (`<600` Mobile, `≥600` Tablet/Desktop)
- **Formatting & Utilities:** `intl`, `cupertino_icons`

---

## 📂 Project Structure

```
lib/
 ├── main.dart                          # App startup & Supabase initialization
 ├── app/
 │   ├── config/
 │   │   └── supabase_config.dart       # Supabase URL & Anon Key (env define enabled)
 │   ├── routes/
 │   │   ├── app_routes.dart            # Named route string constants
 │   │   └── app_pages.dart             # GetPage route configurations
 │   ├── theme/
 │   │   ├── app_colors.dart            # Palette (Emerald Teal, Owe Red, Owed Green)
 │   │   ├── app_text_styles.dart       # Typography scale
 │   │   └── app_theme.dart            # Light & Dark ThemeData
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

The application interacts with these public tables in Supabase:

- **`public.trips`**: `id (uuid, pk)`, `owner_id (uuid, fk)`, `name (text)`, `destination (text)`, `start_date (timestamp)`, `end_date (timestamp)`, `description (text)`, `created_at`, `updated_at`
- **`public.trip_people`**: `id (uuid, pk)`, `trip_id (uuid, fk)`, `name (text)`, `phone (text)`, `created_at`, `updated_at`
- **`public.trip_expenses`**: `id (uuid, pk)`, `trip_id (uuid, fk)`, `description (text)`, `total_amount (numeric)`, `paid_by_person_id (uuid, fk)`, `category (text)`, `split_type (text)`, `expense_date (timestamp)`, `note (text)`, `created_at`, `updated_at`
- **`public.expense_splits`**: `id (uuid, pk)`, `expense_id (uuid, fk)`, `person_id (uuid, fk)`, `share_amount (numeric)`, `share_percentage (numeric)`, `created_at`

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
