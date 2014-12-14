var path = require('path');
var net = require('net');
var LineStream = require('byline').LineStream;

// 1. Connect to liquid soap over socket
var socket = net.createConnection({
  path: path.resolve(__dirname, "/tmp/liquidsoap-mixer")
}, function(){
  socket.write('count\r\n');
  socket.write('list_streams\r\n');

});

var parser = new LineStream();
socket.pipe(parser);
