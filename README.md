# Clarity - Project Management App

A comprehensive Flutter project management application designed for freelancers and small businesses to track projects, clients, payments, and tasks.

## Features

### 🎯 Core Features
- **Project Dashboard**: Overview of all projects with status indicators
- **Project Creation**: Add new projects with detailed information
- **Project Details**: Comprehensive project view with tabs for phases, payments, and notes
- **Client Management**: Track client information and project relationships
- **Payment Tracking**: Monitor budgets, payments, and outstanding balances
- **Task Management**: Organize work into phases and tasks
- **Analytics Dashboard**: Visual insights into earnings and project performance
- **Smart Suggestions**: AI-driven recommendations for priority tasks
- **Quick Notes**: Jot down ideas and notes for projects

### 📱 Screens Overview

1. **Projects Dashboard**
   - List view of all projects
   - Priority indicators (High/Medium/Low)
   - Progress bars and completion percentages
   - Deadline countdowns
   - Payment status indicators
   - Filter and search functionality

2. **New Project Creation**
   - Project name and client information
   - Budget and deadline setting
   - Priority level selection
   - Optional notes and descriptions

3. **Project Details**
   - Comprehensive project header with key metrics
   - Tabbed interface for:
     - Phases & Tasks management
     - Payment tracking
     - Project notes
   - Edit and delete functionality

4. **Suggestions Screen**
   - High priority projects
   - Overdue tasks and deadlines
   - Outstanding payments
   - Smart recommendations

5. **Analytics Dashboard**
   - Total earnings overview
   - Outstanding balance tracking
   - Project completion statistics
   - Visual charts and insights

6. **Settings**
   - Profile management
   - Theme preferences
   - Notification settings
   - Backup and restore options

## 🛠 Technical Stack

- **Framework**: Flutter 3.9.2+
- **State Management**: Provider
- **Database**: SQLite (sqflite)
- **UI Components**: Material Design 3
- **Charts**: FL Chart
- **Icons**: Font Awesome Flutter

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.2
  sqflite: ^2.3.3+1
  path: ^1.9.0
  flutter_staggered_grid_view: ^0.7.0
  fl_chart: ^0.69.0
  intl: ^0.19.0
  font_awesome_flutter: ^10.7.0
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd clarity
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📱 App Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── project.dart         # Data models (Project, Client, Task, etc.)
├── providers/
│   └── project_provider.dart # State management
├── services/
│   └── database_helper.dart # Database operations
├── screens/
│   ├── main_navigation.dart
│   ├── projects_dashboard.dart
│   ├── new_project_screen.dart
│   ├── project_details_screen.dart
│   ├── suggestions_screen.dart
│   ├── analytics_dashboard.dart
│   ├── notes_screen.dart
│   └── settings_screen.dart
└── widgets/
    ├── project_card.dart
    ├── project_header.dart
    └── filter_bottom_sheet.dart
```

## 🎨 Design Features

- **Material Design 3**: Modern, clean interface
- **Responsive Layout**: Works on phones and tablets
- **Dark/Light Theme**: Automatic theme switching
- **Color-coded Priorities**: Visual priority indicators
- **Progress Tracking**: Visual progress bars and completion percentages
- **Intuitive Navigation**: Bottom navigation with clear icons

## 📊 Data Models

### Project
- Basic information (name, client, budget, deadline)
- Priority levels (High, Medium, Low)
- Progress tracking and completion percentage
- Payment status and financial tracking

### Client
- Contact information and company details
- Project relationships
- Payment history tracking

### Task & Phase Management
- Hierarchical task organization
- Due dates and completion tracking
- Progress monitoring

## 🔧 Development

### Running Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 🚧 Roadmap

### Phase 1 (Current)
- ✅ Basic project management
- ✅ Client tracking
- ✅ Payment monitoring
- ✅ Task organization
- ✅ Analytics dashboard

### Phase 2 (Planned)
- 🔄 Advanced task management
- 🔄 Time tracking
- 🔄 Invoice generation
- 🔄 Cloud synchronization
- 🔄 Advanced analytics

### Phase 3 (Future)
- 📋 Team collaboration
- 📋 Advanced reporting
- 📋 Integration with external tools
- 📋 Mobile notifications
- 📋 Offline support

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions, please open an issue in the repository or contact the development team.

---

**Clarity** - Bringing clarity to your project management workflow.