<h1 align="center">
  <br>
  💰 Finance Manager
  <br>
</h1>

<h4 align="center">A premium, offline-first personal finance tracker built with <a href="https://flutter.dev" target="_blank">Flutter</a>.</h4>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Platform-Android%20|%20iOS-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" />
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#project-structure">Project Structure</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## ✨ Features

### 💳 Transaction Management
- Add, edit, and delete income & expense transactions
- Categorize transactions with custom categories and icons
- Full transaction history with search & filter support

### 📊 Analytics & Insights
- Beautiful interactive charts powered by `fl_chart`
- Monthly income vs expense breakdown
- Category-wise spending analysis
- Visual trends over time

### 🎯 Budget Tracking
- Set monthly budgets per category
- Real-time progress indicators showing budget usage
- Alerts when approaching or exceeding limits

### 🗂️ Category Management
- Create fully custom categories with names, icons & colors
- Separate income and expense category types
- Manage and reorder categories freely

### 🔒 Biometric Authentication
- Secure app access with fingerprint / Face ID via `local_auth`
- PIN fallback support
- Privacy protection on every launch

### 📤 Export & Share
- Export transaction data to **Excel (.xlsx)**
- Share reports directly via the device share sheet

### 🎨 Premium UI/UX
- Dark-themed, glass-morphism design
- Smooth animations via `flutter_animate`
- Google Fonts typography (`Outfit` / `Inter`)
- Native splash screen & custom app icon

---

## 📱 Screenshots

> _Screenshots coming soon._

---

## 🛠️ Tech Stack

| Category | Package | Purpose |
|---|---|---|
| **State Management** | `provider ^6.1.2` | App-wide reactive state |
| **Local Database** | `hive ^2.2.3` + `hive_flutter` | Offline-first data persistence |
| **Charts** | `fl_chart ^0.69.0` | Analytics visualizations |
| **Export** | `excel ^4.0.6` + `share_plus ^10.0.0` | Excel export & sharing |
| **Authentication** | `local_auth ^2.3.0` | Biometric / PIN lock |
| **UI** | `google_fonts ^6.2.1` + `flutter_animate ^4.5.0` | Typography & animations |
| **Utilities** | `intl ^0.19.0` + `uuid ^4.4.2` | Formatting & unique IDs |
| **Splash / Icons** | `flutter_native_splash` + `flutter_launcher_icons` | Branding assets |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>=3.0.0`
- Dart SDK `>=3.0.0 <4.0.0`
- Android Studio / Xcode (for device/emulator)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/JohnSte098/finance-manager.git
   cd finance-manager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Build for Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS
flutter build ipa --release
```

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/        # App-wide constants (colors, strings, keys)
│   ├── theme/            # Dark theme configuration
│   └── utils/            # Helper functions & formatters
├── data/
│   ├── models/           # Hive data models (Transaction, Budget, Category)
│   └── datasources/      # Local database service (Hive boxes)
├── presentation/
│   ├── pages/            # Full screens
│   │   ├── dashboard_page.dart       # Home overview & summary cards
│   │   ├── transactions_page.dart    # Transaction list & search
│   │   ├── add_transaction_sheet.dart# Bottom sheet to add transactions
│   │   ├── analytics_page.dart       # Charts & spending insights
│   │   ├── budget_page.dart          # Budget setup & progress
│   │   ├── categories_page.dart      # Category management
│   │   ├── settings_page.dart        # App settings & export
│   │   ├── auth_page.dart            # Biometric / PIN auth gate
│   │   └── home_shell.dart           # Bottom nav shell
│   ├── providers/        # Provider-based state management
│   └── widgets/          # Reusable UI components
└── main.dart             # App entry point & Hive initialization
```

---

## 🔐 Security

All data is stored **100% locally** on the device using Hive — no cloud, no servers, no data collection. Biometric authentication ensures only you can access your financial data.

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<p align="center">Made with ❤️ using Flutter</p>
