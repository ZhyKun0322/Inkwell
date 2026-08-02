const crypto = require('crypto');
const db = require('./db');

function areFriends(meId, otherId) {
  return !!db.get('friendships').find(f =>
    f.status === 'accepted' &&
    ((f.requesterId === meId && f.addresseeId === otherId) ||
     (f.requesterId === otherId && f.addresseeId === meId))
  ).value();
}

function attachSocket(io) {
  io.on('connection', (socket) => {
    socket.on('join', ({ room, userId }) => {
      // Only allow joining a 2-person room the user is actually part of.
      const [idA, idB] = room.split(':');
      if (userId !== idA && userId !== idB) return;
      socket.join(room);
      socket.data.userId = userId;
    });

    socket.on('chat message', ({ room, userId, text }) => {
      if (!text || !text.trim()) return;
      const [idA, idB] = room.split(':');
      if (userId !== idA && userId !== idB) return;
      const otherId = userId === idA ? idB : idA;
      if (!areFriends(userId, otherId)) return;

      const message = {
        id: crypto.randomUUID(),
        room,
        senderId: userId,
        text: text.trim(),
        createdAt: new Date().toISOString()
      };
      db.get('messages').push(message).write();

      io.to(room).emit('chat message', message);
    });
  });
}

module.exports = attachSocket;
