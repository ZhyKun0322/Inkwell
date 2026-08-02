(function () {
  const socket = io();
  const messagesEl = document.getElementById('messages');
  const form = document.getElementById('chat-form');
  const input = document.getElementById('chat-text');

  socket.emit('join', { room, userId: myId });

  function appendMessage(msg) {
    const div = document.createElement('div');
    const mine = msg.senderId === myId;
    div.className = 'msg ' + (mine ? 'mine' : 'theirs');

    const text = document.createElement('span');
    text.textContent = msg.text;

    const time = document.createElement('span');
    time.className = 'time';
    time.textContent = new Date(msg.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

    div.appendChild(text);
    div.appendChild(time);
    messagesEl.appendChild(div);
    messagesEl.scrollTop = messagesEl.scrollHeight;
  }

  socket.on('chat message', (msg) => {
    if (msg.room === room) appendMessage(msg);
  });

  form.addEventListener('submit', (e) => {
    e.preventDefault();
    const text = input.value.trim();
    if (!text) return;
    socket.emit('chat message', { room, userId: myId, text });
    input.value = '';
  });

  if (messagesEl) messagesEl.scrollTop = messagesEl.scrollHeight;
})();
