document.addEventListener('deviceready', onDeviceReady, false);

function setStatus(text) {
  var el = document.getElementById('status');
  if (el) el.textContent = text;
}

function onDeviceReady() {
  setStatus('Starting local server\u2026');

  var nodejs = window.nodejs;
  if (!nodejs) {
    setStatus('nodejs-mobile-cordova plugin not found. Did you run:\ncordova plugin add nodejs-mobile-cordova ?');
    return;
  }

  nodejs.channel.setListener(function (msg) {
    console.log('[cordova] received from node: ' + msg);

    if (typeof msg === 'string' && msg.indexOf('ready:') === 0) {
      var port = msg.split(':')[1] || '3000';
      setStatus('Loading Inkwell\u2026');
      // Give the OS network stack a brief moment, then load the app.
      setTimeout(function () {
        window.location.href = 'http://localhost:' + port + '/';
      }, 300);
    } else if (typeof msg === 'string' && msg.indexOf('error:') === 0) {
      setStatus('Server error: ' + msg.substring(6));
    }
  });

  nodejs.start('main.js', function (err) {
    if (err) {
      console.error(err);
      setStatus('Failed to start Node engine: ' + err);
      return;
    }
    setStatus('Node engine started, waiting for server\u2026');
  });
}
