# Building Inkwell.apk

This folder is a **Cordova + nodejs-mobile** project. It bundles your entire
Inkwell Express app (routes, EJS views, Socket.io chat, lowdb) so it runs
*inside* the Android app itself — no website, no external server, works
offline. When the app launches it starts a real Node.js process in the
background and points an in-app WebView at `http://localhost:3000`.

I can't compile the final `.apk` inside this chat sandbox (no Android SDK,
no network access here), so these are the exact steps to build it yourself.
It's a one-time setup.

---

## What you need on your build machine (a PC, not your phone)

1. **Node.js** (v18+) — https://nodejs.org
2. **Java JDK 17**
3. **Android Studio** — installing it also installs the Android SDK,
   platform-tools, and build-tools you need. Open it once so it finishes
   the SDK setup wizard.
4. **Cordova CLI**:
   ```bash
   npm install -g cordova
   ```

(Advanced: this can also be done entirely inside Termux on the phone
itself, but installing the Android SDK/Gradle/Java on-device is heavy and
slow. A PC is much faster for this one-time build step. Once you have the
`.apk` file, everything after that is 100% on-device.)

---

## Build steps

From inside this `inkwell-apk-project` folder:

```bash
# 1. Add the Android platform
cordova platform add android

# 2. Add the required plugins
cordova plugin add cordova-plugin-whitelist
cordova plugin add nodejs-mobile-cordova

# 3. Build (this automatically runs `npm install` inside
#    www/nodejs-project to fetch express, socket.io, lowdb, etc.
#    for the embedded Node runtime)
cordova build android
```

If that last step succeeds, your APK is here:

```
platforms/android/app/build/outputs/apk/debug/app-debug.apk
```

Copy that file to your phone (USB cable, or a cloud drive folder you sync,
whatever you prefer — doesn't need to be public), tap it, and allow
"install from unknown sources" when prompted. That's it — no website, no
Play Store, no external server.

---

## Notes

- **First launch** will show a short "Starting up…" screen while the
  embedded Node server boots (usually under a second), then it loads
  straight into Inkwell's login page.
- **Data storage**: `data/db.json` is created inside the app's private
  storage on first run. It persists across app restarts, and is only
  wiped if you uninstall the app or clear its storage from Android
  settings.
- **This produces a debug build**, which is fine for installing on your
  own phone. If you ever want to distribute it more widely, you'd need to
  sign a release build (`cordova build android --release`) with your own
  keystore — not required just to run it yourself.
- If Android blocks the install with a Play Protect warning, that's normal
  for any sideloaded APK not from the Play Store — choose "Install anyway."
- If you'd rather skip building yourself entirely, remember Termux
  (Option 1 from earlier) gets you running *today* with no build tooling —
  worth doing in parallel while you set up Android Studio.
