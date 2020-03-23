#!/usr/bin/node

var r = require('rethinkdb')
var hostname = process.env.HOSTNAME;
var now = new Date().getTime();
var fs = require('fs');

var status_timeout = {
  '3': 24 * 60 * 60 * 1000, // Normal idle devices will be rebooted once per day
  '1': 2 * 60 * 1000, // Offline
  '2': 2 * 60 * 1000, // Unauthorized
  '5': 5 * 60 * 1000  // Connected
}
var present_timeout = 5 * 60 * 1000;
var ready_timeout = 5 * 60 * 1000;
var default_timeout = 4 * 60 * 60 * 1000;

function calculateTimeout(device) {
  if (!device.present) {
    return present_timeout;
  } else if (!device.ready) {
    return ready_timeout;
  } else if (device.status in status_timeout) {
    return status_timeout[device.status];
  } else {
    return default_timeout;
  }
}

function compositeStatus(device) {
  return `${device.present}-${device.ready}-${device.status}-${device.owner == null}`
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
    .run(conn, function(err, cursor) {
      if (err) throw err;

      cursor.each(function(err, device) {
        var filename = '/tmp/' + device.serial + ".json"

        fs.readFile(filename, 'utf-8', function(err, contents) {
            var state = {}
            if (!err) {
                state = JSON.parse(contents);
            }

            var newStatus = compositeStatus(device);
            var needUpdate = false;

            if (state.status != newStatus) {
              needUpdate = true; //just update
            } else if (now - state.time > calculateTimeout(device)) {
              console.log(device.serial);
              needUpdate = true; // prevent rebooting every minute if something is wrong
            }

            if (needUpdate) {
              state.time = now;
              state.status = newStatus;
              fs.writeFileSync(filename, JSON.stringify(state, null, 2) , 'utf-8');
            }
        });
      });
      conn.close();
    });
});
