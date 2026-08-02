# Inkwell

A story-writing and social app: login/register, profile customization,
publish stories, a For You feed, friends, chat, and settings.

## Stack
- **Flutter** (app, builds to a real Android APK)
- **Firebase**: Auth (email/password), Firestore (users, stories, chats)
- **GitHub Actions**: builds the APK on every push — no local Flutter needed

## One-time setup

1. **Firebase project**
   - console.firebase.google.com → Add project → "Inkwell"
   - Add an Android app with package name `com.inkwell.app`
   - Build → Authentication → Sign-in method → enable Email/Password
   - Build → Firestore Database → Create database
   - Firestore → Rules → paste the contents of `firestore.rules` in this repo → Publish
   - Project settings → Your apps → copy `apiKey`, `appId`, `messagingSenderId`,
     `projectId`, `storageBucket`

2. **Fill in config**
   - Open `lib/firebase_options.dart`
   - Replace the `PASTE_..._HERE` placeholders with the values above

3. **Push**
   ```bash
   git add .
   git commit -m "Configure Firebase"
   git push
   ```

4. **Get the APK**
   - GitHub repo → Actions tab → latest run → Artifacts → `inkwell-apk`
   - Download, unzip, transfer `app-release.apk` to your phone, install
     (enable "install unknown apps" for whatever app opens it)

## Firestore data model
- `users/{uid}` — username, usernameLower, displayName, bio, photoUrl, friendIds[]
- `stories/{id}` — authorId, authorName, title, content, createdAt, likeCount
- `chats/{id}` — participants[], lastMessage, lastTimestamp
- `chats/{id}/messages/{id}` — senderId, text, createdAt

## Not included yet (possible next steps)
- Profile photo / story cover image upload (needs Firebase Storage + image picker)
- Friend requests with accept/decline (current version adds friends instantly)
- Push notifications for new messages
- Story likes/comments
