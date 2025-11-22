# Udhaar App

Udhaar is a simple and efficient Flutter application designed to track and manage personal borrow/lend transactions. It helps users maintain clear records of who owes what, with an intuitive interface for adding, editing, and calculating balances.

---

## ✨ Features

- 📌 Add new Udhaar entries (borrow/lend)
- ✏️ Edit existing entries with adjustment tracking
- 🧮 Auto-calculated total balance
- 📋 User-wise Udhaar list
- 💾 Local persistence using `shared_preferences`
- 🎨 Clean and minimal UI

---

## 🚀 Getting Started

### 1. Clone the repository
```sh
git clone https://github.com/saipy10/Udhar-Personal-Loan-Book.git
cd Udhar-Personal-Loan-Book
````

### 2. Install dependencies

```sh
flutter pub get
```

### 3. Run the application

```sh
flutter run
```

---

## 🛠️ Tech Stack

* **Flutter** (Dart)
* **Material UI**
* **shared_preferences** for local data persistence

---

## 🔧 How It Works

* Users can add Udhaar entries specifying amount & description.
* Editing an entry generates an adjustment value (+/-).
* The total Udhaar is automatically calculated from all entries.
* Modular widgets ensure clean, reusable UI components.

---

## 📸 Screenshots

<img width="350" alt="Udhaar Screenshot" src="https://github.com/user-attachments/assets/8e8eebf8-ce36-4800-ac0e-d12267a9b19d" />

---

## 🤝 Contributing

Contributions, suggestions, and feature requests are welcome!
Feel free to open an issue or submit a pull request.

---

## 📄 License

This project is licensed under the **MIT License**.
