# Building the APK via GitHub Actions (recommended — no SDK needed on your phone)

This project now includes `.github/workflows/build-apk.yml`. Once this code
is pushed to a GitHub repo, GitHub's own servers do the actual Android
build for you — you just download the finished `.apk` afterward. Nothing
about your app itself goes on a public website; only the source code sits
in the repo (make it **private** if you'd rather no one else see it), and
the build happens on GitHub's temporary build machine, not a live server.

You only need `git` in Termux for this — no Android SDK, no Gradle, no
Java install required on your phone.

---

## 1. Create the GitHub repo

On github.com (mobile browser or the GitHub app), sign in (or create a free
account), then **New repository** → name it e.g. `inkwell-apk` → set it to
**Private** if you want → **Create repository** (don't add a README, this
project already has files).

## 2. Get a Personal Access Token (used instead of a password)

GitHub → Settings → Developer settings → Personal access tokens →
Generate new token (classic) → check the `repo` scope → Generate → copy it
somewhere safe. You'll paste this in place of a password in step 4.

## 3. Get the project into Termux

```bash
pkg install git unzip -y
cd ~
unzip /sdcard/Download/inkwell-apk-project.zip -d inkwell-apk-project
cd inkwell-apk-project
```

(If you already unzipped this earlier while trying the local-build route,
just `cd` into that existing folder instead.)

## 4. Push it to GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/inkwell-apk.git
git push -u origin main
```

When it asks for a username, enter your GitHub username. When it asks for
a password, paste the **Personal Access Token** from step 2 (not your
actual GitHub password — that won't work).

## 5. Watch it build

Go to your repo on github.com → **Actions** tab. You'll see "Build Inkwell
APK" running (takes roughly 3–6 minutes). Green check = success.

## 6. Download the APK

Click the finished workflow run → scroll to **Artifacts** → download
`inkwell-apk` (it's a zip containing `app-debug.apk`). Unzip it, then open
the `.apk` file from your Downloads with your file manager and allow
"install from unknown sources" when prompted.

---

That's it — no Android SDK, no Gradle, no build errors to debug on-device.
If a workflow run fails, open it and expand the red step; paste me the
error text and I'll fix the workflow file for you.
