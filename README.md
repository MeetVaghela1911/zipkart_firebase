# ZipKart 🛒

ZipKart is a modern, full-featured e-commerce platform built with **Flutter** and **Firebase**. It supports multiple user roles, including **Buyers**, **Sellers**, and **Admins**, providing a seamless industrial-grade shopping experience.

---

## 🚀 Key Features

### 👤 User (Buyer)
- **Authentication**: Secure sign-up/login via Email, Google, and Apple.
- **Product Discovery**: 
  - Dynamic **Home Page** with banners and categories.
  - Advanced **Search** with filters.
  - **Explore** products by categories and subcategories.
- **Shopping Experience**: 
  - Detailed product information and reviews.
  - **Wishlist/Favorites** for later purchase.
  - Intuitive **Cart** management.
- **Checkout & Payments**: 
  - Integrated payment gateway.
  - Address management for multi-location delivery.
  - Order success and cancellation tracking.
- **Profile Management**: Customizable user profiles and activity tracking.

### 🏪 Seller
- **Seller Dashboard**: Real-time sales and order overview.
- **Product Management**: List, edit, and manage products with ease.
- **Order Tracking**: Keep track of customer orders and delivery status.
- **Settings**: Manage shop-specific configurations.

### 🔑 Admin
- **Central Dashboard**: Monitor overall platform health.
- **Seller Management**: Approve or reject seller applications and list active sellers.
- **User Insights**: Oversee user activity and platform-wide data.

---

## 🛠️ Technology Stack

- **Frontend**: [Flutter](https://flutter.dev/) (Multi-platform support)
- **State Management**:
  - [Riverpod](https://riverpod.dev/) (Functional, reactive state management)
  - [BLoC](https://pub.dev/packages/flutter_bloc) (Event-based architecture for specific modules)
- **Backend (Firebase)**:
  - **Auth**: Firebase Authentication (Email, Social logins)
  - **Firestore**: Scalable NoSQL database for user and product data.
  - **Realtime Database**: For real-time sync (where applicable).
  - **Storage**: Secure image and file storage for products and profiles.
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router) for deep linking and declarative routing.
- **Network**: [Dio](https://pub.dev/packages/dio) and [http](https://pub.dev/packages/http).
- **UI Toolkit**: Google Fonts, Shimmer effects, and polished animations.

---

## 🏗️ Architecture

ZipKart follows **Clean Architecture** principles to ensure scalability and maintainability:

```
lib/
├── core/           # Constants, themes, routes, and shared utilities
├── data/           # Repositories and external data sources
├── domain/         # Business logic and abstract repositories
├── Models/         # Data models and serialization logic
├── providers/      # Riverpod providers for state management
├── screen/         # UI screens (divided by User, Seller, and Admin roles)
└── ui/             # Reusable UI components and theme definitions
```

---

## 🏁 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- [Firebase account](https://firebase.google.com/) and a project set up.

### Installation
1. **Clone the repository**:
   ```bash
   git clone https://github.com/MeetVaghela1911/zipkart_firebase.git
   cd zipkart_firebase
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Configure Firebase**:
   - Ensure `firebase_options.dart` is correctly configured for your environment.
   - Run `flutterfire configure` to set up your own Firebase project.

4. **Run the app**:
   ```bash
   flutter run
   ```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:
1. Fork the project.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## ⚠️ Known Issues & Analysis

For a detailed analysis of current issues and planned improvements, refer to [PROJECT_ISSUES_ANALYSIS.md](./PROJECT_ISSUES_ANALYSIS.md).
Detailed authentication implementation notes can be found in [AUTH_IMPLEMENTATION.md](./AUTH_IMPLEMENTATION.md).

---

*Built with ❤️ by [Meet Vaghela](https://github.com/MeetVaghela1911)*
