const db = require('../db');
const { gradientFor, userInitials } = require('../utils/cover');

// Attach the logged-in user (if any) to res.locals so every view can use `currentUser`
function attachUser(req, res, next) {
  if (req.session && req.session.userId) {
    const user = db.get('users').find({ id: req.session.userId }).value();
    res.locals.currentUser = user ? { ...user, avatar: { gradient: gradientFor(user.username), initials: userInitials(user.username) } } : null;
  } else {
    res.locals.currentUser = null;
  }
  next();
}

// Require login, otherwise send to /login
function requireAuth(req, res, next) {
  if (!req.session || !req.session.userId) {
    req.session.returnTo = req.originalUrl;
    return res.redirect('/login');
  }
  next();
}

module.exports = { attachUser, requireAuth };
