# PingMe

PingMe is a minimalist chat application designed for real-time communication, built using **SwiftUI** and **Firebase**. This project showcases a clean and intuitive interface combined with powerful backend functionality to create a seamless user experience.

---

## 🚀 Features

- **User Authentication**
  - Sign up and log in with Firebase Authentication.
  - "Continue with Google" option for quick access.

- **Real-Time Messaging**
  - Chats are synced instantly using Google Firestore.

- **Modern UI/UX**
  - Designed with SwiftUI, featuring a clean and user-friendly layout.

---

## 🛠️ Technologies Used

### Frontend
- **SwiftUI**: Apple’s declarative framework for building responsive and beautiful UIs.
  - **NavigationStack**: For navigation between app views.
  - **ZStack**: To layer UI components effectively.
  - **Custom Views**: Modular components for forms, buttons, and input fields.
  - **Property Wrappers**: Leveraged `@State`, `@Binding`, and `@Environment` for state management.

### Backend
- **Firebase Authentication**: For secure user sign-in and management.
- **Google Firestore**: Real-time database to store and sync messages.

---

## 📸 Screenshots
![Login Screen](path-to-login-screenshot)  
![Chat Screen](path-to-chat-screenshot)

*(Add your screenshots here to showcase the app)*

---

## 💻 Setup Instructions

### Prerequisites
- Xcode installed on your Mac.
- A Firebase project set up with Authentication and Firestore enabled.

### Steps
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/PingMe.git
   cd PingMe
   ```
2. Open the project in Xcode:
   ```bash
   open PingMe.xcodeproj
   ```
3. Configure Firebase:
   - Download the `GoogleService-Info.plist` file from your Firebase project.
   - Add it to the Xcode project.
4. Build and run the app:
   - Select a simulator or connected device.
   - Press `Cmd+R` to run the app.

---

## 🤔 Challenges Faced

- Learning Firebase SDK integration and configuring Firestore rules.
- Designing a responsive and visually appealing UI using SwiftUI components.
- Debugging real-time sync issues in Firestore.

---

## 📋 To-Do

- Add support for group chats.
- Enable media sharing (images, videos).
- Implement a push notification system for incoming messages.

---

## 🤝 Contributing

Contributions are welcome! Feel free to fork this repository and submit pull requests.

---

## 📧 Contact

For any questions or feedback, reach out to me at [your email address].

---

## 📜 License

This project is licensed under the MIT License. See the `LICENSE` file for details.
