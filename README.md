# 🚭 QuitSmoking App

Description was generated with ChatGPT (I'll change ReadMe in the future)

This is a SwiftUI + Firebase iOS application designed to help users track their smoke-free days. Originally forked from another project, this version includes improvements such as Firestore integration, 
Sign In with Apple, and real-time updates using snapshot listeners.

---

## ✨ Features

- 🔒 **Sign In with Apple** via Firebase Authentication  
- 🔁 **Sort of Auto-login** support via Firebase Auth state persistence  
- 🔥 **Firestore integration** for tracking non-smoking days  
- 📡 **Real-time updates** with Firestore snapshot listeners [WIP]
- 🎯 **SwiftUI-based UI** for modern iOS experience (but very simple)
- 🔔 **Notifications** with some nice and motivating texts
- 📋 **Last changes date** to display

---

## 📋 TBD
- 🎉 Fireworks when you add a non-smonking day
- 🔙 Sign out behavior

---

## 📲 Getting Started

### Prerequisites

- Xcode 15+  
- Firebase iOS SDK (installed via Swift Package Manager)  
- A Firebase project with:
  - **Firestore** enabled
  - **Authentication** enabled (Apple sign-in configured)

### Installation

```bash
git clone https://github.com/your-user/quit-smoking-app.git
cd quit-smoking-app
open QuitSmoking.xcodeproj
