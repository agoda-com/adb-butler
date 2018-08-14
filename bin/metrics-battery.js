#!/usr/bin/node

var r = require('rethinkdb')
var fs = require('fs');
var hostname = process.env.HOSTNAME;

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
      },
      status: 3,
      present: true
    })
    .withFields('serial', 'battery', 'provider')
    .run(conn, function(err, cursor) {
      if (err) throw err;

      var stream = fs.createWriteStream("/custom-metrics/battery");
      stream.once('open', function(fd) {
        cursor.each(function(err, device) {
            stream.write(`android_battery,serial=\"${device.serial}\" voltage=${device.battery.voltage},level=${device.battery.level}i,temperature=${device.battery.temp} ${Date.now()}\n`);
        }, function() {
          stream.end();
        })
      });
      stream.once('finish', function(){
        conn.close();
      });
    });
});
