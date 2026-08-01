require('dotenv').config();
const express = require('express');
const session = require('express-session');
const path = require('path');
const http = require('http');
const { Server } = require('socket.io');

const { attachUser } = require('./src/middleware/auth');
const attachSocket = require('./src/socket');

const authRoutes = require('./src/routes/auth');
const postRoutes = require('./src/routes/posts');
const profileRoutes = require('./src/routes/profile');
const friendRoutes = require('./src/routes/friends');
const chatRoutes = require('./src/routes/chat');

const app = express();
const server = http.createServer(app);
const io = new Server(server);

const PORT = process.env.PORT || 3000;

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

app.use(session({
  secret: process.env.SESSION_SECRET || 'dev-secret-change-me',
  resave: false,
  saveUninitialized: false,
  cookie: { maxAge: 1000 * 60 * 60 * 24 * 7 } // 1 week
}));

app.use(attachUser);

app.use('/', authRoutes);
app.use('/', postRoutes);
app.use('/', profileRoutes);
app.use('/', friendRoutes);
app.use('/', chatRoutes);

app.use((req, res) => {
  res.status(404).render('404');
});

attachSocket(io);

server.listen(PORT, () => {
  console.log(`Inkwell is running: http://localhost:${PORT}`);
});
