# 📱 POS UMKM - Point of Sale Application

## 🎯 **OVERVIEW**

POS UMKM adalah aplikasi Point of Sale modern yang dirancang khusus untuk Usaha Mikro, Kecil, dan Menengah (UMKM) di Indonesia. Aplikasi ini mendukung operasi offline dan online, dengan fitur AI untuk deteksi produk dan sistem multi-bahasa untuk ekspansi internasional.

---

## ✨ **KEY FEATURES**

### 🔐 **Authentication & Security**
- ✅ **Secure Login** - Username/email dengan password
- ✅ **Session Management** - Auto-login dengan token persistence
- ✅ **Role-based Access** - Admin, Manager, Cashier roles
- ✅ **Route Protection** - Middleware untuk akses kontrol

### 🌍 **Internationalization**
- ✅ **Multi-language** - Indonesia & English
- ✅ **Multi-currency** - IDR & USD dengan format lokal
- ✅ **Language Switcher** - Real-time language switching
- ✅ **Persistent Settings** - Saved preferences

### 📊 **Dashboard & Analytics**
- ✅ **Modern UI** - Material Design 3 dengan gradient
- ✅ **Real-time Stats** - Today's transactions, sales, products
- ✅ **Quick Actions** - Barcode scanner, AI scan
- ✅ **Activity Feed** - Recent activities tracking

### 💾 **Data Management**
- ✅ **Local Database** - SQLite dengan encryption
- ✅ **Offline Support** - Full offline functionality
- ✅ **Data Sync** - Ready for API integration
- ✅ **Mock Data** - Sample data untuk development

### 🤖 **AI Features**
- ✅ **Product Detection** - Camera-based recognition
- ✅ **TensorFlow Lite** - ML model integration
- ✅ **Accuracy Tracking** - AI performance metrics

---

## 🏗️ **ARCHITECTURE**

### **Clean Architecture**
- **Presentation Layer** - UI dengan GetX
- **Domain Layer** - Business logic & entities
- **Data Layer** - Repository pattern & data sources

### **Technology Stack**
- **Flutter** - Cross-platform framework
- **GetX** - State management, DI, routing
- **SQLite** - Local database dengan encryption
- **Material Design 3** - Modern UI/UX

---

## 📁 **PROJECT STRUCTURE**

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants
│   ├── di/                # Dependency injection
│   ├── localization/      # Language & currency
│   ├── theme/             # App styling
│   └── errors/            # Error handling
├── features/              # Feature modules
│   ├── auth/              # Authentication
│   ├── pos/               # Point of Sale
│   └── products/          # Product management
├── shared/                # Shared components
│   ├── models/            # Shared models
│   ├── widgets/           # Reusable widgets
│   └── utils/             # Utilities
└── main.dart              # App entry point
```

---

## 🚀 **GETTING STARTED**

### **Prerequisites**
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code
- Android device / emulator

### **Installation**
```bash
# Clone repository
git clone https://github.com/your-repo/pos-umkm.git
cd pos-umkm

# Install dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Run the app
flutter run
```

### **Development Setup**
```bash
# Install dependencies
flutter pub get

# Generate code
flutter packages pub run build_runner build

# Run tests
flutter test

# Analyze code
flutter analyze
```

---

## 📱 **SCREENSHOTS**

### **Login Screen**
- Modern login form dengan validation
- Language switcher di top-right
- Secure authentication flow

### **Dashboard**
- Beautiful gradient header dengan user info
- Today's stats cards
- Quick actions untuk barcode & AI scan
- Main menu grid dengan 6 menu utama
- AI features section
- Recent activity feed

---

## 🔧 **CONFIGURATION**

### **Environment Setup**
```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'POS UMKM';
  static const String appVersion = '1.0.0';
  static const String databaseName = 'pos_umkm.db';
  static const String databaseVersion = '1';
}
```

### **Theme Configuration**
```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF10B981);
  // ... more colors
}
```

---

## 🌍 **INTERNATIONALIZATION**

### **Supported Languages**
- **🇮🇩 Bahasa Indonesia** - Pasar domestik
- **🇺🇸 English** - Pasar internasional

### **Supported Currencies**
- **💰 IDR** - Rupiah Indonesia (rb, jt, M)
- **💵 USD** - US Dollar (K, M, B)

### **Usage**
```dart
// In widgets
Text(AppLocalizations.of(context)!.welcome)

// In controllers
final languageController = Get.find<LanguageController>();
String formatted = languageController.formatCurrency(150000);
```

---

## 💾 **DATABASE**

### **Tables**
- **users** - User accounts
- **tenants** - Business entities
- **products** - Product catalog
- **categories** - Product categories
- **transactions** - Sales transactions
- **inventory** - Stock levels

### **Features**
- **Encryption** - SQLite dengan SQLCipher
- **Migration** - Database versioning
- **Backup** - Data backup & restore
- **Sync** - Ready for API integration

---

## 🔐 **SECURITY**

### **Data Protection**
- **Database Encryption** - SQLite dengan SQLCipher
- **Secure Storage** - Flutter secure storage
- **Token Management** - JWT token handling
- **Session Security** - Secure session management

### **Authentication**
- **JWT Tokens** - Secure authentication
- **Auto-login** - Persistent sessions
- **Role-based Access** - User permissions
- **Route Protection** - Middleware security

---

## 🧪 **TESTING**

### **Test Coverage**
- **Unit Tests** - Business logic testing
- **Widget Tests** - UI component testing
- **Integration Tests** - End-to-end testing
- **Mock Data** - Test data generation

### **Running Tests**
```bash
# Run all tests
flutter test

# Run specific test
flutter test test/features/auth/presentation/controllers/auth_controller_test.dart

# Run with coverage
flutter test --coverage
```

---

## 📊 **PERFORMANCE**

### **Optimization**
- **GetX Reactive** - Minimal rebuilds
- **Lazy Loading** - On-demand loading
- **Image Caching** - Efficient image handling
- **Database Indexing** - Fast queries

### **Memory Management**
- **Controller Lifecycle** - Proper disposal
- **Stream Management** - Proper stream handling
- **Image Disposal** - Memory cleanup

---

## 🚀 **DEPLOYMENT**

### **Build for Production**
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

### **Environment Configuration**
```bash
# Development
flutter run --dart-define=ENV=dev

# Production
flutter run --dart-define=ENV=prod
```

---

## 📈 **ROADMAP**

### **Phase 1: Core POS (Current)**
- ✅ Authentication system
- ✅ Dashboard dengan stats
- ✅ Internationalization
- ✅ Local database setup

### **Phase 2: POS Features**
- 🔄 Point of Sale interface
- 🔄 Product management
- 🔄 Transaction processing
- 🔄 Payment handling

### **Phase 3: Advanced Features**
- 🔄 Reporting & analytics
- 🔄 AI product detection
- 🔄 Hardware integration
- 🔄 API synchronization

---

## 🤝 **CONTRIBUTING**

### **Development Guidelines**
- **Clean Code** - Readable and maintainable
- **SOLID Principles** - Object-oriented design
- **Testing** - Write tests for new features
- **Documentation** - Update docs for changes

### **Code Style**
- **Dart Style Guide** - Follow Dart conventions
- **GetX Pattern** - Use GetX for state management
- **Clean Architecture** - Follow architectural patterns
- **Error Handling** - Proper exception handling

---

## 📄 **LICENSE**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 **SUPPORT**

### **Documentation**
- [Architecture Overview](ARCHITECTURE_OVERVIEW.md)
- [Implementation Status](IMPLEMENTATION_STATUS.md)
- [API Integration Guide](API_INTEGRATION_GUIDE.md)
- [Internationalization Guide](INTERNATIONALIZATION_GUIDE.md)

### **Contact**
- **Email** - support@pos-umkm.com
- **Website** - https://pos-umkm.com
- **GitHub** - https://github.com/your-repo/pos-umkm

---

## 🎉 **ACKNOWLEDGMENTS**

- **Flutter Team** - Amazing framework
- **GetX** - Powerful state management
- **Material Design** - Beautiful design system
- **Community** - Open source contributors

---

**POS UMKM - Modern, Professional, Ready for Business!** 🚀
