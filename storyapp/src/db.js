const path = require('path');
const fs = require('fs');
const low = require('lowdb');
const FileSync = require('lowdb/adapters/FileSync');

const dataDir = path.join(__dirname, '..', 'data');
if (!fs.existsSync(dataDir)) fs.mkdirSync(dataDir, { recursive: true });

const adapter = new FileSync(path.join(dataDir, 'db.json'));
const db = low(adapter);

// Collections:
// users:        { id, username, email, passwordHash, bio, createdAt }
// posts:        { id, authorId, title, content, published, createdAt, updatedAt }
// comments:     { id, postId, authorId, text, createdAt }
// likes:        { id, postId, userId }
// friendships:  { id, requesterId, addresseeId, status: 'pending'|'accepted', createdAt }
// messages:     { id, room, senderId, text, createdAt }

db.defaults({
  users: [],
  posts: [],
  comments: [],
  likes: [],
  friendships: [],
  messages: []
}).write();

module.exports = db;
