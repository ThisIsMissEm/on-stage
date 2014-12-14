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

socket.setEncoding('utf8');

var parser = new LineStream();
socket.pipe(parser);

var buffer = [];

parser.on('data', function(data){
  if(data === "END"){
    console.log(buffer.join(""))
    buffer = [];
    return;
  }

  buffer.push(data);
})
