# Getting Inkwell onto the Play Store (Termux + GitHub only)

This is a 3-stage process: **deploy the backend** → **package a TWA app** →
**publish on Play Console**. Everything below can be run from Termux.

---

## Stage 1 — Deploy so Inkwell has a real URL

A Play Store app can't reach `localhost` on your phone. Put the code on
GitHub (README.md step 5 already covers `git push`), then deploy it:

1. Go to [render.com](https://render.com) → sign up with GitHub.
2. **New → Web Service** → pick your `inkwell` repo.
3. Settings:
   - Build command: `npm install`
   - Start command: `npm start`
   - Add environment variables: `SESSION_SECRET` (long random string), `PORT` is set automatically by Render.
4. Deploy. You'll get a URL like `https://inkwell-xxxx.onrender.com` — this is
   now your app's real address. Confirm `https://inkwell-xxxx.onrender.com/manifest.json`
   loads in a browser before moving on.

> Free-tier note: Render's free web services spin down when idle and spin
> back up on the next request (~30s cold start), and the free tier's disk
> isn't persistent across deploys — since Inkwell stores data in
> `data/db.json`, **a redeploy will wipe your data** on the free tier. Fine
> for testing; swap in a real database (see README) before real users rely on it.

---

## Stage 2 — Package it as an Android app (TWA)

A **Trusted Web Activity** wraps your live URL in a native Android shell —
no rewriting the app, it just loads your deployed site full-screen.

In Termux:

```bash
pkg install openjdk-17 -y
npm install -g @bubblewrap/cli
```

Initialize the project (answer the prompts — use your Render URL):

```bash
bubblewrap init --manifest=https://inkwell-xxxx.onrender.com/manifest.json
```

It will ask for:
- **Application ID**: reverse-domain style, e.g. `com.yourname.inkwell`
- **App name**: Inkwell
- Icon/color: it reads these from your `manifest.json` automatically

Build the Android App Bundle:

```bash
bubblewrap build
```

This produces `app-release-bundle.aab` and generates/uses a signing
keystore (`android.keystore`). **Back up `android.keystore` and its
password somewhere safe outside your phone** — if you lose it, you can
never update this app on the Play Store again under the same listing.

---

## Stage 3 — Verify domain ownership (Digital Asset Links)

TWAs require proof you own both the app and the website, or Android shows
a browser address bar instead of a full-screen app.

1. Bubblewrap prints a SHA-256 fingerprint after signing — copy it.
2. Create `assetlinks.json`:
   ```json
   [{
     "relation": ["delegate_permission/common.handle_all_urls"],
     "target": {
       "namespace": "android_app",
       "package_name": "com.yourname.inkwell",
       "sha256_cert_fingerprints": ["YOUR_FINGERPRINT_HERE"]
     }
   }]
   ```
3. Add a route in `server.js` (or drop the file in `public/.well-known/`)
   so it's reachable at:
   `https://inkwell-xxxx.onrender.com/.well-known/assetlinks.json`
4. Redeploy, then confirm that URL loads the JSON in a browser.

---

## Stage 4 — Publish

1. Create a [Google Play Developer account](https://play.google.com/console/signup) — **$25 one-time fee**.
2. Play Console → **Create app** → fill in name, category, free/paid.
3. Upload `app-release-bundle.aab` under **Production → Create release**.
4. Complete required sections before it can go live:
   - **Store listing**: screenshots (take some from your phone), short/full description, icon (already generated at `public/icons/icon-512.png`).
   - **Privacy policy URL** — required since Inkwell collects emails, passwords, and messages. Can be a simple static page.
   - **Data safety form** — declare what's collected: email, password (hashed), chat messages, published stories.
   - **Content rating questionnaire**.
5. Submit for review. First-time reviews typically take a few days.

---

## Quick reference: what changed in the code for this

- `public/manifest.json` — PWA identity (name, icons, theme color)
- `public/sw.js` — minimal service worker (required for installability; doesn't cache dynamic content like chat/feed)
- `public/icons/` — generated icon set, including maskable variants
- `views/partials/header.ejs` — links the manifest + icons in `<head>`
- `views/partials/footer.ejs` — registers the service worker

None of this touches your routes, auth, or chat logic — it's purely
additive.
