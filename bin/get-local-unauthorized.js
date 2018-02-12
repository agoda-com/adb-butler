#!/usr/bin/node

var r = require('rethinkdb')
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
      status: 2
    })
    .withFields('serial')
    .run(conn, function(err, cursor) {
      if (err) throw err;

      cursor.each(function(err, serial) {
        console.log(serial.serial);
      })
      conn.close();
    });
});
