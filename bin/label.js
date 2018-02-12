#!/usr/bin/node

var r = require('rethinkdb')
var note = process.env.STF_PROVIDER_NOTE;
var hostname = process.env.HOSTNAME;

if (!note) {
  console.log("Note is not provided. Exiting");
  process.exit(0);
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
    .update({notes: `${note}`})
    .run(conn, function(err, something) {
      if (err) throw err;

      conn.close();
      console.log(`Note ${note} added too all devices from ${hostname}`);
    });
});
