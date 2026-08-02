const express = require('express');
const crypto = require('crypto');
const db = require('../db');
const { requireAuth } = require('../middleware/auth');
const { gradientFor, userInitials } = require('../utils/cover');

const router = express.Router();

function withAvatar(user) {
  if (!user) return user;
  return { ...user, avatar: { gradient: gradientFor(user.username), initials: userInitials(user.username) } };
}

function friendshipBetween(aId, bId) {
  return db.get('friendships').find(f =>
    (f.requesterId === aId && f.addresseeId === bId) ||
    (f.requesterId === bId && f.addresseeId === aId)
  ).value();
}

router.get('/friends', requireAuth, (req, res) => {
  const me = res.locals.currentUser.id;
  const q = (req.query.q || '').trim().toLowerCase();

  const accepted = db.get('friendships')
    .filter(f => f.status === 'accepted' && (f.requesterId === me || f.addresseeId === me))
    .value();
  const friends = accepted.map(f => {
    const otherId = f.requesterId === me ? f.addresseeId : f.requesterId;
    return withAvatar(db.get('users').find({ id: otherId }).value());
  }).filter(Boolean);

  const incoming = db.get('friendships')
    .filter({ status: 'pending', addresseeId: me })
    .map(f => ({ friendshipId: f.id, user: withAvatar(db.get('users').find({ id: f.requesterId }).value()) }))
    .value();

  const outgoing = db.get('friendships')
    .filter({ status: 'pending', requesterId: me })
    .map(f => ({ friendshipId: f.id, user: withAvatar(db.get('users').find({ id: f.addresseeId }).value()) }))
    .value();

  let results = [];
  if (q) {
    results = db.get('users')
      .filter(u => u.id !== me && u.username.toLowerCase().includes(q))
      .value()
      .map(u => ({ user: withAvatar(u), friendship: friendshipBetween(me, u.id) || null }));
  }

  res.render('friends', { friends, incoming, outgoing, results, q });
});

router.post('/friends/request/:username', requireAuth, (req, res) => {
  const me = res.locals.currentUser;
  const target = db.get('users').find({ username: req.params.username }).value();
  if (!target || target.id === me.id) return res.redirect('/friends');

  const existing = friendshipBetween(me.id, target.id);
  if (!existing) {
    db.get('friendships').push({
      id: crypto.randomUUID(),
      requesterId: me.id,
      addresseeId: target.id,
      status: 'pending',
      createdAt: new Date().toISOString()
    }).write();
  }
  res.redirect(req.get('referer') || '/friends');
});

router.post('/friends/accept/:id', requireAuth, (req, res) => {
  const f = db.get('friendships').find({ id: req.params.id }).value();
  if (f && f.addresseeId === res.locals.currentUser.id) {
    db.get('friendships').find({ id: f.id }).assign({ status: 'accepted' }).write();
  }
  res.redirect('/friends');
});

router.post('/friends/decline/:id', requireAuth, (req, res) => {
  const f = db.get('friendships').find({ id: req.params.id }).value();
  if (f && (f.addresseeId === res.locals.currentUser.id || f.requesterId === res.locals.currentUser.id)) {
    db.get('friendships').remove({ id: f.id }).write();
  }
  res.redirect('/friends');
});

module.exports = router;
