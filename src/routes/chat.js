const express = require('express');
const db = require('../db');
const { requireAuth } = require('../middleware/auth');
const { gradientFor, userInitials } = require('../utils/cover');

const router = express.Router();

function withAvatar(user) {
  if (!user) return user;
  return { ...user, avatar: { gradient: gradientFor(user.username), initials: userInitials(user.username) } };
}

function roomFor(idA, idB) {
  return [idA, idB].sort().join(':');
}

function areFriends(meId, otherId) {
  return !!db.get('friendships').find(f =>
    f.status === 'accepted' &&
    ((f.requesterId === meId && f.addresseeId === otherId) ||
     (f.requesterId === otherId && f.addresseeId === meId))
  ).value();
}

router.get('/chat', requireAuth, (req, res) => {
  const me = res.locals.currentUser.id;
  const accepted = db.get('friendships')
    .filter(f => f.status === 'accepted' && (f.requesterId === me || f.addresseeId === me))
    .value();
  const friends = accepted.map(f => {
    const otherId = f.requesterId === me ? f.addresseeId : f.requesterId;
    return withAvatar(db.get('users').find({ id: otherId }).value());
  }).filter(Boolean);

  res.render('chat', { friends, activeFriend: null, messages: [], room: null });
});

router.get('/chat/:friendId', requireAuth, (req, res) => {
  const me = res.locals.currentUser.id;
  const friend = withAvatar(db.get('users').find({ id: req.params.friendId }).value());
  if (!friend || !areFriends(me, friend.id)) {
    return res.redirect('/chat');
  }

  const accepted = db.get('friendships')
    .filter(f => f.status === 'accepted' && (f.requesterId === me || f.addresseeId === me))
    .value();
  const friends = accepted.map(f => {
    const otherId = f.requesterId === me ? f.addresseeId : f.requesterId;
    return withAvatar(db.get('users').find({ id: otherId }).value());
  }).filter(Boolean);

  const room = roomFor(me, friend.id);
  const messages = db.get('messages')
    .filter({ room })
    .sortBy('createdAt')
    .map(m => ({ ...m, mine: m.senderId === me }))
    .value();

  res.render('chat', { friends, activeFriend: friend, messages, room });
});

module.exports = router;
