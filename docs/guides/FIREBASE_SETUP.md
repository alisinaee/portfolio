# Firebase Setup Guide

## Prerequisites

- Firebase CLI installed
- Firebase project created
- Flutter project configured

## Installation

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project
firebase init hosting
```

## Configuration

### firebase.json
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

### .firebaserc
```json
{
  "projects": {
    "default": "your-project-id"
  }
}
```

## Deployment

### Preview Channel
```bash
./scripts/deploy_preview.sh
```

### Production
```bash
./scripts/deploy_firebase.sh
```

## Build Process

1. Build WASM version:
```bash
./scripts/build_wasm.sh
```

2. Deploy to Firebase:
```bash
firebase deploy --only hosting
```

## Verification

After deployment:
1. Visit your Firebase hosting URL
2. Check performance in Chrome DevTools
3. Verify animations are smooth
4. Test on different browsers

## Troubleshooting

### Build Fails
- Run `flutter clean`
- Update Flutter: `flutter upgrade`
- Check Firebase CLI: `firebase --version`

### Deployment Fails
- Check Firebase login: `firebase login`
- Verify project ID in `.firebaserc`
- Check hosting configuration in `firebase.json`

### WASM Not Loading
- Use proper web server (not file://)
- Check browser console for errors
- Verify CORS headers
- Test in Chrome (best WASM support)
