# Finance Navigator

> A personal finance management app built with Flutter and Firebase — track expenses, manage budgets, set savings goals, and stay on top of bills.

<br/>

<p align="center">
  <img src="assets/images/logo.png" alt="Finance Navigator Logo" width="120"/>
</p>

---

## Overview

Finance Navigator is a mobile application designed to give users complete control over their personal finances. It combines expense tracking, budgeting, savings goal management, and bill calendar reminders into a single intuitive interface — built with a dark-first glassmorphism design that also supports a full light mode.

---

## Features

### Dashboard
The home screen gives a live snapshot of your financial health — total balance pulled from all your transactions, this month's income vs expenses, a savings goal progress ring, budget status bars, recent transactions, and upcoming unpaid bills. Every section is a live Firestore stream, so the numbers update the moment data changes anywhere in the app.

### Transactions
Log income and expenses with a category, date, amount, and optional note. Transactions are grouped by date (Today / Yesterday / specific date) and are searchable and filterable by type. Tapping any transaction opens it for editing or deletion.

### Analytics
Visual spending insights powered by live Firestore data. Switch between Week, Month, and Year views. Includes an income vs expenses bar chart for the last 6 months, a donut chart of spending by category, and a per-category breakdown with percentage bars.

### Budget Tracking
Set monthly spending limits per category. The budget page shows how much you've spent against each limit in real time, color-coded from green (on track) to red (over budget). Tap any category to create or edit its limit.

### Bill Calendar
An interactive monthly calendar where each day shows colored dots for unpaid (red) and paid (green) bills. Tap any day to see its bills. Tap a bill to open the full detail page where you can edit, delete, or mark it as paid. New bills can be added directly from the calendar.

### Savings Goals
Create savings goals with a name, emoji, target amount, and deadline. Each goal displays a color-coded circular progress indicator and a linear progress bar. Tap a goal to edit it or add funds. The profile page stats row shows your real-time total saved across all goals.

### User Profile
Displays live stats (transaction count, total saved, active goals) fetched from Firestore. Supports editing your display name and email, changing your password, and toggling between dark and light mode. The theme preference is persisted across sessions using `SharedPreferences`.

### Authentication
Full Firebase Authentication — email/password sign in, account registration, and password reset via email. Auth state is listened to globally so the app navigates automatically on login and logout.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| State Management | Provider (`ThemeProvider`) |
| Theme Persistence | SharedPreferences |
| Navigation | Flutter Navigator 2 + custom `MainShell` tab switcher |
| UI Style | Glassmorphism — dark navy + gold accent, full light mode support |

---

## Project Structure

```
lib/
├── main.dart                        # App entry point, Firebase init, auth gate
├── core/
│   ├── theme.dart                   # Colors, text styles, ThemeData, context extensions
│   └── theme_provider.dart          # ChangeNotifier for dark/light toggle
├── models/
│   └── models.dart                  # TransactionModel, BillModel, SavingsGoalModel, BudgetModel
├── services/
│   ├── auth_service.dart            # Firebase Auth wrapper
│   ├── user_service.dart            # Display name, email, profile updates
│   └── db_service.dart             # All Firestore CRUD — streams + one-time fetches
├── widgets/
│   ├── glass_card.dart              # Reusable glassmorphism card
│   └── glass_nav_bar.dart           # Rounded floating bottom nav bar
└── features/
    ├── main_shell.dart              # Root scaffold with IndexedStack + tab switcher
    ├── onboarding/                  # Splash screen + onboarding flow
    ├── auth/                        # Login + registration pages
    ├── dashboard/                   # Home page with live data sections
    ├── analytics/                   # Charts and spending insights
    ├── transactions/                # Transaction list + add/edit form
    ├── calendar/                    # Bill calendar with interactive grid
    ├── bills/                       # Bill detail / edit / delete page
    ├── budget/                      # Monthly budget overview + category sheets
    ├── savings/                     # Savings goals list + add/edit sheet
    ├── add_transaction/             # Unified add/edit transaction form
    └── profile/                     # User profile, settings, theme toggle
```

---

## Database Structure

All data is scoped per user under `users/{uid}/` in Firestore:

```
users/{uid}/
├── transactions/{id}     amount, type, category, date, note, title, isRecurring
├── bills/{id}            name, amount, category, frequency, dueDate, isPaid, note
├── savings_goals/{id}    emoji, name, target, saved, colorValue, deadline, note
└── budgets/{id}          category, limit, month ("2026-05")
```

Every page uses Firestore **streams** (`StreamBuilder`) so the UI updates in real time across the app with no manual refresh required.

---

## Firestore Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Each user can only read and write their own data.

---

## Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- A Firebase project with **Authentication** (Email/Password) and **Firestore** enabled

### Setup

**1. Clone the repository:**
```bash
git clone https://github.com/your-username/finance-navigator.git
cd finance-navigator
```

**2. Install dependencies:**
```bash
flutter pub get
```

**3. Add your Firebase config:**

Download `google-services.json` from your Firebase project console and place it at:
```
android/app/google-services.json
```

**4. Run the app:**
```bash
flutter run
```

---

## Screenshots

> *(Add screenshots of Home, Calendar, Analytics, Budget, and Savings pages here)*

---

## Future Improvements

- Connect remaining hardcoded sections to live Firestore data
- Transaction detail page with full edit and delete support
- Premium plan with advanced analytics and CSV data export
- Biometric login (fingerprint / Face ID)
- iOS support and App Store release

---

## Author

**Anderson Roy Djeutio**  
Built as a course project — April 2026

---

## License

This project is for educational purposes. All rights reserved.