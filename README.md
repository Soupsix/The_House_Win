# 🏆 The House Wins (Betwise)

**The House Wins (Betwise)** is a Flutter-based Virtual Betting Simulator application designed primarily for **educational and anti-gambling awareness purposes**. 

By simulating a real-world betting environment with live football data, the app demonstrates how "the house always wins" through mathematical probabilities, Monte Carlo simulations, and built-in "loan traps". It educates users on the inherent risks of gambling without involving any real money.

---

## ✨ Key Features

*   **⚽ Live Football Data:** Fetches real-time and upcoming match schedules, odds, and results using the [Football-Data.org API](https://www.football-data.org/).
*   **🤖 AI Match Analysis:** Integrates Google's **Gemini 3.5 Flash API** to act as a virtual football analyst, providing match overviews, head-to-head trends, and risk assessments.
*   **💰 Virtual Wallet & Betting:** Place virtual bets (1X2, Over/Under) with a simulated wallet. All transactions are securely processed using Firestore Transactions to prevent race conditions.
*   **🎰 Mini-games & Monte Carlo Simulation:** Includes Slot Machines and Spin Wheels. Visualizes the long-term mathematical loss of gambling using `fl_chart`.
*   **🚨 Anti-Gambling Education:** Features realistic "Loan Traps" and educational warnings when users run out of virtual funds, emphasizing the dangers of chasing losses.
*   **🔔 Push Notifications:** Utilizes Firebase Cloud Messaging (FCM) and Local Notifications to send match reminders and admin alerts.
*   **👑 Admin Dashboard:** Built-in role-based access control (RBAC) allowing admins to lock bets, settle matches, and manage users.

---

## 🛠 Tech Stack

*   **Framework:** Flutter SDK (>=3.22.0)
*   **Language:** Dart
*   **State Management:** Riverpod (`flutter_riverpod`, `riverpod_annotation`)
*   **Backend as a Service (BaaS):** Firebase (Auth, Cloud Firestore, Storage, Cloud Messaging)
*   **Local Database:** SQLite (`sqflite`) for offline match caching
*   **Networking:** Dio
*   **AI Integration:** Google Generative Language API (Gemini)
*   **Architecture:** Clean Architecture (Domain, Data, Application, Presentation)

---

## 📁 Project Structure

The project strictly follows **Clean Architecture** to ensure separation of concerns and maintainability:

```text
lib/
 ├── application/      # State management (Riverpod Providers, Notifiers)
 ├── core/             # Core utilities, constants, theme, router (GoRouter)
 ├── data/             # Repositories implementations, Firebase services, API clients
 ├── domain/           # Models, Entities, Enums (Freezed, JSON Serializable)
 └── presentation/     # UI Layer (Screens, Widgets) separated by feature
```

---

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK (v3.22.0 or higher)
*   Dart SDK (v3.3.0 or higher)
*   Android Studio / VS Code
*   A Firebase Project with Firestore and Authentication enabled

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/the-house-wins.git
   cd the-house-wins
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Environment Configuration (`.env`):**
   Create a `.env` file in the root directory of the project and add your API keys:
   ```env
   FOOTBALL_DATA_API_KEY=your_football_data_api_key_here
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

4. **Firebase Configuration:**
   Make sure to configure your project with Firebase using the FlutterFire CLI:
   ```bash
   flutterfire configure
   ```

5. **Generate Code (Freezed & Riverpod):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

6. **Run the App:**
   ```bash
   flutter run
   ```

---

## ⚠️ Disclaimer

**THIS IS NOT A REAL GAMBLING APPLICATION.** 
This project is strictly for educational purposes to demonstrate the risks of gambling. No real money can be deposited, wagered, or withdrawn. The virtual currency has no real-world value. 

---
*Developed as an educational PRM393 Project.*
