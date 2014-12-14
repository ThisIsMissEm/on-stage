var path = require('path');
var net = require('net');
var LineStream = require('byline').LineStream;

// 1. Connect to liquid soap over socket
var socket = net.createConnection({
  path: path.resolve(__dirname, "/tmp/liquidsoap-mixer")
});


var parser = new LineStream();
var generator = new LineStream();

socket.pipe(parser);
generator.pipe(socket);

generator.write('count');
generator.write('list_streams');
