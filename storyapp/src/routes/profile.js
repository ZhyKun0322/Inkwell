const express = require('express');
const db = require('../db');
const { requireAuth } = require('../middleware/auth');
const { gradientFor, titleInitials, userInitials } = require('../utils/cover');

const router = express.Router();

router.get('/profile/:username', requireAuth, (req, res) => {
  const user = db.get('users').find({ username: req.params.username }).value();
  if (!user) return res.status(404).render('404');

  const isOwner = user.id === res.locals.currentUser.id;

  let posts = db.get('posts').filter({ authorId: user.id });
  if (!isOwner) posts = posts.filter({ published: true });
  posts = posts.sortBy('createdAt').reverse()
    .map(post => ({
      ...post,
      genre: post.genre || 'Story',
      cover: { gradient: gradientFor(post.title), initials: titleInitials(post.title) },
      likeCount: db.get('likes').filter({ postId: post.id }).size().value()
    }))
    .value();

  const profileAvatar = { gradient: gradientFor(user.username), initials: userInitials(user.username) };

  const friendship = isOwner ? null : db.get('friendships')
    .find(f =>
      ((f.requesterId === res.locals.currentUser.id && f.addresseeId === user.id) ||
       (f.requesterId === user.id && f.addresseeId === res.locals.currentUser.id))
    ).value();

  res.render('profile', {
    profileUser: user,
    profileAvatar,
    posts,
    isOwner,
    friendship: friendship || null
  });
});

router.post('/profile/bio', requireAuth, (req, res) => {
  const { bio } = req.body;
  db.get('users').find({ id: res.locals.currentUser.id }).assign({ bio: (bio || '').trim() }).write();
  res.redirect('/profile/' + res.locals.currentUser.username);
});

module.exports = router;
