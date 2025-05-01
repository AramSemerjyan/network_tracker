# 🛰️ Network Tracker

A lightweight and developer-friendly Flutter package for tracking and viewing all your app's HTTP network activity in real-time — powered by Dio interceptors and a clean, built-in viewer.

---

## ✨ Features

- ✅ Automatically captures all Dio HTTP requests and responses
- 🕵️‍♂️ View full request/response logs directly in your app
- 📱 Simple integration with just **two lines of code**
- 📦 No need for custom tooling or complex setup
- 🧩 Useful for debugging, QA, and network profiling

---

## 🚀 Getting Started
### 1. Add to your `pubspec.yaml`

```yaml
dependencies:
  network_tracker: ^0.0.1  # Replace with latest version
```

---------

## 🛠️ Usage
## 2. Just add the interceptor to your existing Dio client:

```dart
  _dio.interceptors.add(NetworkTrackerInterceptor());
```

---------

## 👁️ View requests in-app
## 3. Trigger the built-in viewer from anywhere in your app:

```dart
  NetworkRequestsViewer.showPage(context: context);
```

---------

## 📂 License

MIT License — free for personal or commercial use.