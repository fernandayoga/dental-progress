# DDental Progress — Mobile Application & Backend

A production-minded clinical mobile application designed exclusively for dentists to manage patient records, document orthodontic treatment photos, add clinical notes, and monitor treatment progress with side-by-side comparison.

---

## 🌟 Key Features

1. **Dentist Authentication**: Secure JWT-based authentication with bcrypt password hashing and token persistence using Flutter Secure Storage.
2. **Clinical Dashboard**: Real-time patient and photo statistics, quick action shortcuts, and recently added patient overview.
3. **Patient Management**:
   - Register patients with auto-generated clean Patient IDs (`DP-YYYY-XXXX`).
   - Full Name, Date of Birth, Gender, Phone, and Clinical Notes.
   - Live search by patient name, ID, or phone number.
   - Edit patient information and delete patient records with explicit confirmation dialogs.
4. **Orthodontic Photo Documentation**:
   - Capture clinical photos via Camera or select from Gallery.
   - Categorize photos (`Frontal Smile`, `Upper Occlusal`, `Lower Occlusal`, `Right Lateral`, `Left Lateral`, `Panoramic X-Ray`, `Other`).
   - Date of documentation and clinical notes.
   - Photo history organized chronologically.
   - Interactive zoom / full-screen pinch-to-zoom inspection.
   - Edit clinical notes and delete photos with Cloudinary asset cleanup.
5. **Side-by-Side Treatment Monitoring**:
   - Compare two photos side-by-side from the same patient.
   - Prioritizes image visibility with full pinch-to-zoom in both comparison panes.
   - Slot A (Earlier) and Slot B (Later) selector sheet to change either photo easily.
   - Quick swap button to reverse orientation.
   - Side-by-side clinical notes review.
6. **Clinical Design System**:
   - Medical teal palette (`#007A87`), clean slate typography, subtle borders, accessible touch targets.

---

## 🛠️ Technology Stack

- **Mobile Frontend**:
  - Flutter 3.x / Dart 3.x
  - Material Design 3 (Custom clinical aesthetic)
  - Flutter Riverpod (State Management)
  - Dio (HTTP client with Auth Interceptor)
  - GoRouter (Declarative navigation & auth guards)
  - Flutter Secure Storage (Encrypted token storage)
  - Image Picker (Camera & Gallery integration)
  - CachedNetworkImage (Fast photo caching)
- **Backend**:
  - Node.js & Express with TypeScript (Strict mode)
  - MongoDB & Mongoose (with automated In-Memory MongoDB fallback for zero-config local runs)
  - Cloudinary SDK (Backend asset uploads, secure URLs, asset cleanup)
  - JWT & bcryptjs

---

## 🚀 Getting Started

### 1. Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Build TypeScript distribution
npm run build

# Run automated backend test suite (verifies 14 tests: auth, CRUD, search, uploads, cascade deletion)
npm test

# Run development server with live reload
npm run dev
```

The backend server starts at `http://localhost:5000` (or `http://10.0.2.2:5000` for Android emulator).
If no external MongoDB instance is running, an in-memory MongoDB server starts automatically so everything works immediately out of the box!

#### Default Dentist Login Credentials:
- **Email**: `dentist@dentalprogress.com`
- **Password**: `password123`

---

### 2. Mobile App Setup

```bash
cd mobile

# Get Flutter dependencies
flutter pub get

# Run static code analysis (0 warnings, 0 errors)
flutter analyze

# Run Flutter tests
flutter test

# Run the app on your connected device (Windows Desktop, Android, iOS, or Chrome)
flutter run
```

---

## 📁 Repository Structure

```
├── backend/
│   ├── src/
│   │   ├── config/          # DB, Cloudinary, and Env configurations
│   │   ├── controllers/     # Auth, Patient, Photo, Dashboard controllers
│   │   ├── middleware/      # Auth, Multer, ErrorHandler, Validation middleware
│   │   ├── models/          # Dentist, Patient, Photo Mongoose models
│   │   ├── routes/          # REST route handlers
│   │   ├── services/        # Business logic & Cloudinary service
│   │   └── utils/           # Response formatter, ID generator, logger
│   ├── test/                # Automated API test suite
│   ├── .env.example
│   ├── package.json
│   └── tsconfig.json
├── mobile/
│   ├── lib/
│   │   ├── core/            # Theme, constants, networking, validators
│   │   ├── features/        # Auth, Dashboard, Patients, Photos, Profile
│   │   ├── shared/          # Reusable clinical widgets
│   │   └── app/             # Router, app entry point
│   ├── test/                # Unit and widget tests
│   └── pubspec.yaml
└── README.md
```
