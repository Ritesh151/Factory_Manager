# SmartERP — Windows Desktop ERP

Single-user, client-heavy ERP for Windows Desktop. Built with Flutter, Firebase (Spark Plan), and strict Clean Architecture.

## Target

- **Platform:** Flutter Windows Desktop
- **Backend:** Firebase Spark (free): Auth, Firestore, Storage
- **Constraints:** No Cloud Functions, no paid APIs, no Razorpay/WhatsApp API, offline persistence

## Prerequisites

- Flutter SDK 3.22+ (stable)
- Windows 10/11 (for desktop)
- Firebase project (Spark Plan)

## Setup

### 1. Clone and dependencies

```bash
cd try1
flutter pub get
```

### 2. Firebase

1. **Install the official Firebase CLI** (required by FlutterFire CLI):
   - https://firebase.google.com/docs/cli#install_the_firebase_cli
   - Linux/macOS: `npm install -g firebase-tools` (requires Node.js)
   - Then run `firebase login` once.

2. **Add Dart global bin to PATH** (so `flutterfire` is found):
   ```bash
   export PATH="$PATH:$HOME/.pub-cache/bin"
   ```
   Add that line to `~/.bashrc` or `~/.zshrc` and reload the shell.

3. **Install FlutterFire CLI and generate config** (from project directory):
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Select your project (or create one) and platforms. This generates `lib/firebase_options.dart`.

4. In [Firebase Console](https://console.firebase.google.com), enable **Authentication** (Email/Password) and **Firestore** for your project.

### 3. Firestore rules and indexes

Deploy rules and indexes (optional; required for production):

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

Or paste contents of `firestore.rules` and `firestore.indexes.json` into the Firestore console.

### 4. Run (Windows)

```bash
flutter run -d windows
```

For first run without Firebase configured, the app will throw until `flutterfire configure` is run and `firebase_options.dart` is generated.

## Project structure (Clean Architecture)

```
lib/
  core/           # Theme, router, errors, constants, utils
  domain/         # Entities, repository contracts, calculations (no Flutter)
  data/           # DTOs, mappers, Firestore sources, repository implementations
  features/       # auth, product, invoice, sales, purchase, expense, payroll, dashboard, reports, settings
  shared/         # Reusable widgets (buttons, cards, tables, sidebar)
```

- **UI** uses only providers and domain entities (no direct Firestore, no DTOs in UI).
- **Domain** has no Flutter imports; repositories are abstract.
- **Data** implements repositories and talks to Firestore.

## Features (implemented / planned)

- **Auth:** Login, register (Firebase Auth).
- **Products:** CRUD, HSN, GST %, stock, low-stock (data layer + domain ready; UI placeholder).
- **Invoices:** Create, lock, batch write with stock deduction (domain + repo contract; UI placeholder).
- **Sales:** History, date filter, profit (placeholder).
- **Purchases:** Supplier, stock increment (placeholder).
- **Expenses:** CRUD, category, date filter (placeholder).
- **Payroll:** Employees, salary marking (placeholder).
- **Dashboard:** Stat cards (placeholder values).
- **Reports:** Client-side aggregation, PDF/CSV export (placeholder).
- **Settings:** Sign out, business profile (sign out implemented).

## Performance (Spark Plan)

- Minimize reads: cache product list, paginate lists (e.g. 50).
- Batch writes: invoice + stock update in one batch.
- Local aggregation for dashboard and reports (no Firestore aggregation).
- Offline persistence enabled; handle conflicts client-side.

## Tests

```bash
flutter test
```

Sample unit test: `test/domain/calculations/gst_calculator_test.dart`.

## License

Private / internal use. See project terms.
