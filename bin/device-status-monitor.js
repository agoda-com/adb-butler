#!/usr/bin/node

var r = require('rethinkdb')
var hostname = process.env.HOSTNAME;
var now = new Date().getTime();
var fs = require('fs');

var timeout = {
  '1': 2 * 60 * 1000, // Offline
  '2': 2 * 60 * 1000, // Unauthorized
  '5': 5 * 60 * 1000  // Connected
}

r.connect({
  host: process.env.RETHINKDB_URL,
  port: process.env.RETHINKDB_PORT,
  db: 'stf',
  authKey: process.env.RETHINKDB_ENV_AUTHKEY
}, function(err, conn) {
  if (err) throw err;


  r.table('devices')
    .filter({
      provider: {
          name: `${hostname}`
      }
    })
    .withFields('serial', 'status')
    .run(conn, function(err, cursor) {
      if (err) throw err;

      cursor.each(function(err, device) {
        var filename = '/tmp/' + device.serial + ".json"

        fs.readFile(filename, 'utf-8', function(err, contents) {
            var state = {}
            if (!err) {
                state = JSON.parse(contents);
            }

            if (state.status != device.status) {
              state.time = now;
              state.status = device.status;
              fs.writeFileSync(filename, JSON.stringify(state, null, 2) , 'utf-8');
            }

            if (timeout[device.status] != null && now - state.time > timeout[device.status]) {
              console.log(device.serial);
            }
        });
      });
      conn.close();
    });
});
