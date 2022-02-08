#!/usr/bin/node

var r = require('rethinkdb')
var ip = process.env.STF_PROVIDER_PUBLIC_IP;

if (!ip) {
  console.log("IP is not selected");
  process.exit(1);
}

r.connect({
  host: process.env.RETHINKDB_URL,
  port: process.env.RETHINKDB_PORT,
  db: 'stf',
  authKey: process.env.RETHINKDB_ENV_AUTHKEY
}, function(err, conn) {
  if (err) throw err;

  r.table('devices')
    .filter({serial:ip+':10001'})
    .delete()
    .run(conn, function(err, something) {
      if (err) throw err;

      conn.close();
      console.log('cleaned devices: ' + something['deleted']);
    });

});
