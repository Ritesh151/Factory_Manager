# Firebase setup (Linux / Kali)

If `firebase` or `flutterfire` is "command not found", follow these steps.

## 1. Install Firebase CLI (standalone, no Node/npm needed)

```bash
curl -sL https://firebase.tools | bash
```

Close and reopen your terminal (or run `source ~/.bashrc`), then check:

```bash
firebase --version
```

## 2. Log in to Firebase (once)

```bash
firebase login
```

A browser window will open to sign in with your Google account.

## 3. Add Dart global bin to PATH (for flutterfire)

Add this line to your shell config file (`~/.bashrc` or `~/.zshrc`):

```bash
export PATH="$PATH:$HOME/.pub-cache/bin"
```

Then reload:

```bash
source ~/.bashrc
```

## 4. Install FlutterFire CLI and configure project

From the **project directory** (where `pubspec.yaml` is):

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

- Select a Firebase project or create one.
- Project ID must be **lowercase, numbers and hyphens only** (e.g. `smarterp-demo`).
- Choose the platforms you need (e.g. Chrome, Linux, Windows).

This creates/updates `lib/firebase_options.dart`.

## 5. Enable Auth and Firestore in Firebase Console

1. Open [Firebase Console](https://console.firebase.google.com).
2. Select your project.
3. **Build → Authentication → Get started** → enable **Email/Password**.
4. **Build → Firestore Database → Create database** → start in production mode (rules from `firestore.rules` can be pasted later).

## 6. Run the app

```bash
flutter pub get
flutter run
```

Pick Chrome or Linux desktop when prompted.

---

### If the curl installer fails

Install via npm and use `npx` so PATH doesn’t matter:

```bash
npm install -g firebase-tools
npx firebase-tools login
```

Then for `flutterfire configure`, the Firebase CLI must be available as `firebase`. Create an alias if needed:

```bash
echo 'alias firebase="npx firebase-tools"' >> ~/.bashrc
source ~/.bashrc
flutterfire configure
```
