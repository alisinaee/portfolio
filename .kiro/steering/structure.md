# Project Structure

## Architecture Pattern

**Clean Architecture** with feature-based organization:
- `data/` - Data sources and repository implementations
- `domain/` - Entities and repository interfaces
- `presentation/` - Controllers, pages, widgets

## Directory Layout

```
lib/
├── core/                          # Shared core functionality
│   ├── animations/                # Reusable animation components
│   │   ├── menu/                  # Menu-specific animations
│   │   └── moving_text/           # Text scrolling animations
│   ├── constants/                 # App-wide constants
│   ├── effects/                   # Visual effects
│   │   └── liquid_glass/          # Shader-based glass effects
│   ├── performance/               # Performance optimization utilities
│   ├── utils/                     # General utilities
│   ├── web_shaders/              # Web-specific shader implementations
│   └── widgets/                   # Reusable UI components
│
├── features/                      # Feature modules
│   ├── menu/                      # Main navigation menu
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── prelaunch/                 # Splash/loading screen
│   └── liquid_glass_test/         # Shader testing feature
│
├── firebase_options.dart          # Firebase configuration
└── main.dart                      # App entry point

assets/
├── fonts/                         # 11 custom font files
├── icons/                         # SVG navigation icons
├── images/                        # Image assets
└── shaders/                       # GLSL shader files

docs/                              # Documentation
├── liquid_glass/                  # Shader implementation guides
└── *.md                           # Performance and optimization guides
```

## Key Conventions

### State Management
- Use `Provider` for dependency injection
- Controllers extend `ChangeNotifier`
- Use `Selector` for granular rebuilds
- Batch state updates with microtasks

### Performance Patterns
- `RepaintBoundary` for animation isolation
- `const` constructors wherever possible
- Debounced hover states (16ms frame-aligned)
- Smart animation pausing when inactive
- Cached calculations for expensive operations

### Naming
- Controllers: `AppMenuController`, `*Controller`
- Entities: `MenuEntity`, `*Entity`
- Repositories: `MenuRepository`, `*Repository`
- Widgets: `MainAppWidget`, descriptive names

### File Organization
- One widget per file for large components
- Group related small widgets in single file
- Separate platform-specific code (`web_shaders/`, `native_shaders/`)

## Build Artifacts

- `build/web/` - Production web build output
- `.dart_tool/` - Dart tooling cache
- `.firebase/` - Firebase deployment cache
