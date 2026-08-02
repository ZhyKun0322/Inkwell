const express = require('express');
const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const db = require('../db');

const router = express.Router();

router.get('/register', (req, res) => {
  if (res.locals.currentUser) return res.redirect('/');
  res.render('register', { error: null, formData: {} });
});

router.post('/register', async (req, res) => {
  const { username, email, password, confirmPassword } = req.body;
  const formData = { username, email };

  if (!username || !email || !password) {
    return res.render('register', { error: 'All fields are required.', formData });
  }
  if (password !== confirmPassword) {
    return res.render('register', { error: 'Passwords do not match.', formData });
  }
  if (password.length < 6) {
    return res.render('register', { error: 'Password must be at least 6 characters.', formData });
  }

  const usernameTaken = db.get('users').find({ username }).value();
  if (usernameTaken) {
    return res.render('register', { error: 'That username is already taken.', formData });
  }
  const emailTaken = db.get('users').find({ email }).value();
  if (emailTaken) {
    return res.render('register', { error: 'An account with that email already exists.', formData });
  }

  const passwordHash = await bcrypt.hash(password, 10);
  const user = {
    id: crypto.randomUUID(),
    username: username.trim(),
    email: email.trim().toLowerCase(),
    passwordHash,
    bio: '',
    createdAt: new Date().toISOString()
  };
  db.get('users').push(user).write();

  req.session.userId = user.id;
  res.redirect('/');
});

router.get('/login', (req, res) => {
  if (res.locals.currentUser) return res.redirect('/');
  res.render('login', { error: null, formData: {} });
});

router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const user = db.get('users').find({ email: (email || '').trim().toLowerCase() }).value();

  if (!user) {
    return res.render('login', { error: 'No account found with that email.', formData: { email } });
  }
  const valid = await bcrypt.compare(password || '', user.passwordHash);
  if (!valid) {
    return res.render('login', { error: 'Incorrect password.', formData: { email } });
  }

  req.session.userId = user.id;
  const returnTo = req.session.returnTo;
  delete req.session.returnTo;
  res.redirect(returnTo || '/');
});

router.post('/logout', (req, res) => {
  req.session.destroy(() => {
    res.redirect('/login');
  });
});

module.exports = router;
