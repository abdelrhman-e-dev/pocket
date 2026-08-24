

# Pocket 💰

**Pocket** is a personal finance management application built with Flutter to help users manage their money, accounts, income, and expenses in one simple interface.

The application is designed with an **Arabic-first RTL interface**, supports **offline-first usage**, and focuses on providing a clean and practical personal finance experience.

---

## ✨ Current Features

### 🏠 Dashboard

The main dashboard currently provides:

* Dynamic greeting based on the current time.
* Today's date.
* Total balance across all accounts.
* Current-month expenses.
* Current-month income.
* Number of accounts.
* List of available accounts.
* Recent transactions.
* Quick action button for adding a transaction.

Dashboard values are connected to the local database and update when new income or expenses are recorded.

---

### 💳 Accounts

Users can create and manage different types of financial accounts:

* 💵 Cash
* 🏦 Bank account
* 💳 Credit card
* 📱 Digital wallet
* 💰 Savings account
* 📈 Investment account

Each account contains information such as:

* Account name
* Account type
* Opening balance
* Current balance
* Icon
* Color

When a transaction is created, the account balance is automatically updated.

---

### 💸 Transactions

The application supports two transaction types:

* **Income**
* **Expense**

A transaction currently contains:

* Account
* Category
* Type
* Amount
* Note
* Transaction date

When a transaction is saved:

1. The transaction is stored locally.
2. The related account is retrieved.
3. The new balance is calculated.
4. The account balance is updated.

All of these operations are handled inside a database transaction to keep the data consistent.

---

### 🗂️ Categories

Transactions are associated with categories.

Categories contain:

* Name
* Type
* Color
* Icon
* System/custom status
* Creation date

The category system is designed to support future filtering and reporting features.

---

### 🚀 Onboarding

The first-time user flow includes an onboarding screen introducing the main capabilities of Pocket:

* Accounts
* Expenses
* Reports

The onboarding flow leads the user to the account creation screen.

---

### 🔐 App Lock

Pocket can protect financial data with the device's built-in authentication:

* Optional app lock enabled from Settings.
* Fingerprint authentication on supported devices.
* Device PIN, pattern, or password fallback through the Android system prompt.
* Authentication before the app content is accessible after a cold start.
* Automatic re-lock after the app has been in the background for more than 30 seconds.
* A dedicated lock screen with retry support and no navigation access while locked.
* The setting is persisted locally and remains enabled after the app is killed.

Enabling the lock requires a successful authentication first. If the device has no
configured biometric or device credential, the user is directed to configure one
in the device security settings.

---

### 📊 Reports

Pocket includes financial reports with:

* Income and expense summaries.
* Spending by category.
* Spending by account.
* Period-based filtering.
* Visual charts for understanding financial activity.

---

### ⚙️ Settings

The Settings screen currently provides:

* Daily reminder configuration.
* Reminder time and timezone selection.
* App lock management.
* Category management access.
* Exporting data to Excel.
* Resetting all local financial data.

---

### 🌐 Arabic & RTL

Pocket is designed primarily for Arabic users.

The interface uses:

* Arabic text
* Right-to-left layout
* **Cairo** font
* Arabic-friendly UI components
* Arabic Material/Cupertino localization

---

### 🎨 Theming

The application currently uses a **light/white theme** with a centralized theme configuration.

The theme defines:

* Primary colors
* Background colors
* Surface colors
* Text colors
* Borders
* Input fields
* Buttons
* Cards
* Floating Action Buttons
* Typography

The design is intentionally centralized so the application's visual identity can be changed without modifying every screen individually.

---

## 🛠️ Tech Stack

| Technology | Purpose               |
| ---------- | --------------------- |
| Flutter    | Application framework |
| Dart       | Programming language  |
| Riverpod   | State management      |
| GoRouter   | Navigation            |
| Drift      | Local database        |
| SQLite     | Local data storage    |
| SharedPreferences | Local preferences |
| local_auth | Biometric/device authentication |
| app_settings | Opening device settings |
| Material 3 | UI system             |
| Cairo      | Arabic typography     |

---

## 🏗️ Architecture

The project follows a feature-oriented structure with separation between presentation, providers, repositories, models, and database layers.

A simplified structure:

```text
lib/
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme.dart
│
├── core/
│   ├── database/
│   ├── theme/
│   └── ...
│
├── features/
│   ├── splash/
│   ├── onboarding/
│   ├── accounts/
│   ├── dashboard/
│   ├── transactions/
│   ├── categories/
│   ├── reports/
│   ├── settings/
│   └── app_lock/
│
└── shared/
    └── components/
```

The application uses repositories to communicate with the local database while Riverpod manages application state and data providers.

---

## 🗄️ Database

Pocket uses **Drift** as the local database layer.

Current core tables include:

```text
Accounts
Categories
Transactions
```

### Accounts

Stores financial accounts and their current balances.

### Categories

Stores transaction categories.

### Transactions

Stores income and expense operations and their relationship with accounts and categories.

The application follows an **offline-first** approach, meaning core financial data is stored locally and does not require an internet connection.

---

## 🔄 Transaction Flow

When a user adds an expense:

```text
User
 ↓
Add Transaction
 ↓
Select Expense
 ↓
Select Account
 ↓
Select Category
 ↓
Enter Amount
 ↓
Save Transaction
 ↓
Insert Transaction
 ↓
Calculate New Account Balance
 ↓
Update Account
 ↓
Refresh Dashboard
```

For income, the same flow is used, but the amount is added to the account balance instead of being subtracted.

---

## 🧭 Navigation

The current application flow is approximately:

```text
Splash
  │
  ├── Existing account
  │        ↓
  │     Dashboard
  │
  └── First-time user
           ↓
       Onboarding
           ↓
      Create Account
           ↓
        Dashboard
```

The Splash screen checks the local database before deciding where the user should go.

---

## 📊 Dashboard Data

The dashboard currently displays real data from the database rather than hard-coded values.

Examples include:

* Total account balance
* Monthly income
* Monthly expenses
* Account count
* Recent transactions

This allows the dashboard to immediately reflect changes after adding income or expenses.

---

## 🔮 Planned Features

The project is still under active development.

Planned features include:

### Transactions

* Full transactions page
* Transaction filtering
* Filter by date
* Filter by account
* Filter by category
* Filter by income/expense
* Transaction details
* Edit transaction
* Delete transaction

### Accounts

* Accounts list
* Account details
* Edit account
* Delete account
* Account transaction history
* Account-specific balance information

### Categories

* Custom categories
* Edit categories
* Delete categories
* Category-based transaction filtering

### Reports

* Monthly reports
* Income vs expenses
* Spending by category
* Spending by account
* Date-range reports
* Visual charts

### Settings

* Application preferences
* Theme settings
* Language settings
* Data management

---

## 🎯 Project Goals

Pocket aims to provide a simple personal finance experience without unnecessary complexity.

The main goals are:

* Keep financial data organized.
* Make recording transactions quick.
* Provide a clear overview of current finances.
* Work offline.
* Support Arabic users properly.
* Protect sensitive financial data with device-level authentication.
* Maintain a clean and scalable Flutter architecture.
* Make the application easy to extend with future reporting and analytics features.

---

## 🚧 Project Status

**Development — Active**

The core database, account creation, transaction creation, balance updates, dashboard, onboarding, reports, settings, reminders, data export, and app-lock functionality are currently implemented.

The UI and design system are also being continuously refined before expanding the application's functionality.

---

## 📱 Application Name

**Pocket**

A simple personal finance companion for managing your money, accounts, income, and expenses.

---

## 👨‍💻 Development

Built with ❤️ using Flutter and Dart.

The project is being developed incrementally, with functionality and UI being implemented and tested feature by feature.
