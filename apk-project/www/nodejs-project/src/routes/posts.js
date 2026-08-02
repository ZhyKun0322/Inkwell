const express = require('express');
const crypto = require('crypto');
const db = require('../db');
const { requireAuth } = require('../middleware/auth');
const { gradientFor, titleInitials, userInitials } = require('../utils/cover');

const router = express.Router();

const GENRES = ['Fantasy', 'Romance', 'Sci-Fi', 'Mystery', 'Horror', 'Adventure', 'Poetry', 'Slice of Life', 'Non-fiction', 'Other'];

function withAuthor(post) {
  const author = db.get('users').find({ id: post.authorId }).value();
  const likeCount = db.get('likes').filter({ postId: post.id }).size().value();
  const commentCount = db.get('comments').filter({ postId: post.id }).size().value();
  return {
    ...post,
    genre: post.genre || 'Story',
    authorUsername: author ? author.username : 'unknown',
    authorAvatar: { gradient: gradientFor(author ? author.username : 'unknown'), initials: userInitials(author ? author.username : '?') },
    cover: { gradient: gradientFor(post.title), initials: titleInitials(post.title) },
    likeCount,
    commentCount
  };
}

// For You page — feed of published stories
router.get('/', requireAuth, (req, res) => {
  const posts = db.get('posts')
    .filter({ published: true })
    .sortBy('createdAt')
    .reverse()
    .map(withAuthor)
    .value();
  res.render('feed', { posts });
});

router.get('/write', requireAuth, (req, res) => {
  res.render('write', { post: null, error: null, genres: GENRES });
});

router.post('/write', requireAuth, (req, res) => {
  const { title, content, action, genre } = req.body;
  if (!title || !content) {
    return res.render('write', { post: null, error: 'Title and story text are both required.', genres: GENRES });
  }
  const now = new Date().toISOString();
  const post = {
    id: crypto.randomUUID(),
    authorId: res.locals.currentUser.id,
    title: title.trim(),
    content: content.trim(),
    genre: GENRES.includes(genre) ? genre : 'Other',
    published: action === 'publish',
    createdAt: now,
    updatedAt: now
  };
  db.get('posts').push(post).write();
  res.redirect(post.published ? `/post/${post.id}` : '/profile/' + res.locals.currentUser.username);
});

router.get('/post/:id', requireAuth, (req, res) => {
  const post = db.get('posts').find({ id: req.params.id }).value();
  if (!post) return res.status(404).render('404');
  if (!post.published && post.authorId !== res.locals.currentUser.id) {
    return res.status(404).render('404');
  }
  const author = db.get('users').find({ id: post.authorId }).value();
  const comments = db.get('comments')
    .filter({ postId: post.id })
    .sortBy('createdAt')
    .map(c => ({ ...c, authorUsername: (db.get('users').find({ id: c.authorId }).value() || {}).username || 'unknown' }))
    .value();
  const likeCount = db.get('likes').filter({ postId: post.id }).size().value();
  const likedByMe = !!db.get('likes').find({ postId: post.id, userId: res.locals.currentUser.id }).value();

  res.render('post', {
    post: { ...post, genre: post.genre || 'Story', cover: { gradient: gradientFor(post.title), initials: titleInitials(post.title) } },
    authorUsername: author ? author.username : 'unknown',
    authorAvatar: { gradient: gradientFor(author ? author.username : 'unknown'), initials: userInitials(author ? author.username : '?') },
    comments: comments.map(c => ({ ...c, avatar: { gradient: gradientFor(c.authorUsername), initials: userInitials(c.authorUsername) } })),
    likeCount,
    likedByMe
  });
});

router.post('/post/:id/like', requireAuth, (req, res) => {
  const post = db.get('posts').find({ id: req.params.id }).value();
  if (!post) return res.status(404).render('404');

  const existing = db.get('likes').find({ postId: post.id, userId: res.locals.currentUser.id }).value();
  if (existing) {
    db.get('likes').remove({ id: existing.id }).write();
  } else {
    db.get('likes').push({
      id: crypto.randomUUID(),
      postId: post.id,
      userId: res.locals.currentUser.id
    }).write();
  }
  res.redirect(`/post/${post.id}`);
});

router.post('/post/:id/comment', requireAuth, (req, res) => {
  const post = db.get('posts').find({ id: req.params.id }).value();
  if (!post) return res.status(404).render('404');
  const { text } = req.body;
  if (text && text.trim()) {
    db.get('comments').push({
      id: crypto.randomUUID(),
      postId: post.id,
      authorId: res.locals.currentUser.id,
      text: text.trim(),
      createdAt: new Date().toISOString()
    }).write();
  }
  res.redirect(`/post/${post.id}`);
});

module.exports = router;
