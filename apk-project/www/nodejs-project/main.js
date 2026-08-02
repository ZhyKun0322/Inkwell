// Entry point used by nodejs-mobile-cordova.
// It starts the existing Inkwell Express server unmodified, then tells the
// WebView side (via cordova-bridge) which port to load once the server is
// actually listening.

var cordova;
try {
  cordova = require('cordova-bridge');
} catch (e) {
  cordova = null; // allows `node main.js` to still work on a desktop for testing
}

process.on('uncaughtException', function (err) {
  console.error('[inkwell-node] uncaught exception:', err);
  if (cordova) cordova.channel.send('error:' + err.message);
});

// server.js calls server.listen() itself and logs when ready. We just need
// to know when that happened so the WebView can navigate to localhost.
var PORT = process.env.PORT || 3000;

require('./server.js');

// Give Express a tick to actually bind before telling the UI to load it.
setTimeout(function () {
  if (cordova) cordova.channel.send('ready:' + PORT);
  console.log('[inkwell-node] signaled ready on port ' + PORT);
}, 500);
