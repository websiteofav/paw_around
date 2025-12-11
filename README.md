# 🐾 Paw Around

A comprehensive Flutter app for pet owners to manage their pets' health, find nearby services, and connect with the pet community.

## ✨ Features

- **Pet Management** - Add and manage multiple pet profiles with health records
- **Vaccine Tracking** - Track vaccination schedules with local notification reminders
- **Services Map** - Discover nearby vets, groomers, and pet services using Google Places
- **Lost & Found** - Community-driven lost pet alerts and found pet reports
- **Premium Features** - Ad-free experience and exclusive features via in-app purchases

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.35+ |
| State Management | flutter_bloc |
| Navigation | go_router |
| Local Database | Hive CE |
| Dependency Injection | get_it |
| Image Handling | image_picker |

## 📱 App Flow

```
Splash / Intro
     ↓
Onboarding (3 slides)
     ↓
Login / Sign Up → Location Permission
     ↓
Home (Bottom Tabs)
   ├── Dashboard
   ├── Services Map
   ├── Lost & Found
   └── Profile
        ├── Add/Edit Pet
        └── Premium Upsell
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.1.0 <4.0.0)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator or Android Emulator

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/websiteofav/paw_around.git
   cd paw_around
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Generate Hive adapters
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Run the app
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── bloc/               # BLoC state management
│   ├── auth/
│   ├── home/
│   ├── onboarding/
│   └── pets/
├── constants/          # App constants, colors, strings
├── core/               # DI, error handling
├── models/             # Data models
│   ├── pets/
│   └── vaccines/
├── repositories/       # Data repositories
├── router/             # Navigation setup
├── services/           # Business services
├── ui/                 # UI screens & widgets
│   ├── auth/
│   ├── home/
│   ├── intro/
│   ├── onboarding/
│   ├── pets/
│   └── widgets/
└── utils/              # Utility functions
```

## 🗺️ Roadmap

- [x] Project setup & architecture
- [x] Core theme & navigation
- [x] Onboarding screens
- [x] Pet profiles with Hive storage
- [ ] Vaccine reminders with local notifications
- [ ] Firebase integration
- [ ] Services Map with Google Places
- [ ] Lost & Found community feed
- [ ] Premium subscription features
- [ ] Analytics & crash reporting

## 🔌 Planned Plugins

<details>
<summary>Click to expand full plugin list</summary>

### 🏛️ Core App Setup
| Purpose | Plugin |
|---------|--------|
| State Management | flutter_bloc |
| Local Database | hive_ce + hive_ce_flutter |
| Authentication | firebase_auth |
| Backend & Data | firebase_core, cloud_firestore |
| Storage | firebase_storage |

### 📍 Location & Maps
| Purpose | Plugin |
|---------|--------|
| Google Maps | google_maps_flutter |
| User Location | geolocator |
| Places Search | google_place |

### 📸 Media
| Purpose | Plugin |
|---------|--------|
| Image Picker | image_picker |
| Image Caching | cached_network_image |
| SVG Icons | flutter_svg |

### 🔔 Notifications
| Purpose | Plugin |
|---------|--------|
| Push Notifications | firebase_messaging |
| Local Notifications | flutter_local_notifications |

### 📊 Analytics
| Purpose | Plugin |
|---------|--------|
| Analytics | firebase_analytics |
| Crash Reporting | firebase_crashlytics |

### 💳 Monetization
| Purpose | Plugin |
|---------|--------|
| Subscriptions | in_app_purchase |
| Ads | google_mobile_ads |

### 🖌️ UI Helpers
| Purpose | Plugin |
|---------|--------|
| Onboarding | introduction_screen |
| Charts | fl_chart |
| Animations | flutter_animate |

</details>

## 🔀 Git Workflow

### Branch Naming Convention

```
feature/   → New features        (feature/add-pet-profile)
bugfix/    → Bug fixes           (bugfix/fix-login-crash)
hotfix/    → Urgent prod fixes   (hotfix/critical-auth-fix)
refactor/  → Code refactoring    (refactor/clean-bloc-structure)
docs/      → Documentation       (docs/update-readme)
```

### Commit Message Format

Use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]
```

**Types:**
| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation changes |
| `style` | Formatting, no code change |
| `refactor` | Code restructuring |
| `test` | Adding tests |
| `chore` | Maintenance tasks |

**Examples:**
```bash
feat(pets): Add pet profile creation screen
fix(auth): Resolve login crash on iOS
docs(readme): Update installation steps
refactor(bloc): Simplify home state management
```

### Workflow

1. **Pull latest changes**
   ```bash
   git checkout main
   git pull --rebase origin main
   ```

2. **Create feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make changes & commit regularly**
   ```bash
   git add .
   git commit -m "feat(scope): Description of change"
   ```

4. **Push branch**
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create Pull Request** on GitHub

6. **After merge, clean up**
   ```bash
   git checkout main
   git pull --rebase origin main
   git branch -d feature/your-feature-name
   ```

### Git Rules

- ✅ Commit regularly (one feature/fix per commit)
- ✅ Always use `pull --rebase` before push
- ✅ Write meaningful commit messages
- ✅ Remove unused code before committing
- ❌ Never force push to `main`
- ❌ Don't commit `.env`, secrets, or API keys

## 📄 License

This project is private and proprietary.

---

Github commands --

git remote set-url origin https://websiteofav:PASTE_TOKEN_HERE@github.com/websiteofav/paw_around.git
git push -u origin main

Made with ❤️ and Flutter
