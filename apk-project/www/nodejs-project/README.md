# Inkwell

A small social platform for writers: publish stories, get likes and comments,
add friends, and chat with them in real time.

Built with **Node.js + Express + EJS + lowdb (JSON file database) + Socket.io**.
This stack was chosen specifically because it needs **no native compilation**,
so it installs cleanly in Termux on Android.

---

## 1. Set up Termux

Open Termux and run:

```bash
pkg update && pkg upgrade -y
pkg install nodejs git -y
node -v      # should print v18 or higher
```

## 2. Get the project onto your phone

**Option A — you already have this folder** (e.g. unzipped from a download):

```bash
cd ~/storage/downloads   # or wherever you put it
cd inkwell
```

If Termux can't see your phone's storage yet, first run `termux-setup-storage`
and allow the permission popup, then browse to your Downloads folder.

**Option B — clone from GitHub** (after you've pushed it, see step 5):

```bash
git clone https://github.com/YOUR_USERNAME/inkwell.git
cd inkwell
```

## 3. Install dependencies and configure

```bash
npm install
cp .env.example .env
```

Open `.env` (e.g. `nano .env`) and set `SESSION_SECRET` to any long random
string — this keeps login sessions secure.

## 4. Run it

```bash
npm start
```

You should see:

```
Inkwell is running: http://localhost:3000
```

Open that URL in your phone's browser. Register an account, write and publish
a story, then register a second account (in a private/incognito tab) to test
friend requests, comments, and chat between the two.

To stop the server, press `Ctrl+C` in Termux.

> **Note on the database:** Inkwell stores everything in `data/db.json`, a
> plain JSON file — no database server to install or configure. It's great
> for learning and for a small number of users, but a real file isn't built
> for many simultaneous writers. When you're ready to grow, swap `src/db.js`
> for a real database (Postgres/SQLite) — everything else stays the same
> since only that one file touches storage.

---

## 5. Push it to GitHub

If you don't have a GitHub account yet, create one at github.com, then in
Termux:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Create a **new, empty** repository on GitHub called `inkwell` (don't
initialize it with a README — this project already has one). Then, inside
the `inkwell` folder in Termux:

```bash
git init
git add .
git commit -m "Initial commit: Inkwell story platform"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/inkwell.git
git push -u origin main
```

GitHub will ask you to authenticate. Password auth is disabled for git —
use a **Personal Access Token** instead:
GitHub → Settings → Developer settings → Personal access tokens → generate
one with `repo` scope, and paste it in place of your password when prompted.

From now on, whenever you make changes:

```bash
git add .
git commit -m "describe what you changed"
git push
```

---

## What's built (v1)

- **Auth** — register/login with email + password, sessions, logout
- **For You feed** — every published story, newest first
- **Write** — publish a story or save it as a draft
- **Post page** — read a story, like it, comment on it
- **Profile** — your published stories (and drafts if it's you), editable bio
- **Friends** — search users, send/accept/decline friend requests
- **Chat** — real-time messaging with friends via Socket.io

## What's intentionally deferred

- **Google / GitHub OAuth login** — real OAuth needs a live callback domain,
  which Termux's `localhost` can't provide. The auth logic is isolated in
  `src/routes/auth.js`, so once you deploy Inkwell somewhere with a real URL
  (Render, Railway, a VPS, etc.), you can add `passport-google-oauth20` /
  `passport-github2` alongside the existing email/password flow.
- **Notifications, image uploads, search-by-story** — natural next additions
  once the core loop feels good.

## Project structure

```
inkwell/
├── server.js              # entry point, wires everything together
├── src/
│   ├── db.js               # lowdb JSON database
│   ├── middleware/auth.js  # session auth helpers
│   ├── routes/              # auth, posts, profile, friends, chat
│   └── socket.js            # real-time chat handlers
├── views/                  # EJS templates
├── public/                 # css + client-side js
└── data/db.json            # created automatically on first run
```
