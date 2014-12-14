var path = require('path');
var net = require('net');

var EE = require('events').EventEmitter;
var LS = require('byline').LineStream;

var inherits = require('util').inherits

function noop(){};

function Client(path){
  var client = this;

  this.callbacks = [];
  this.queue = [];
  this.ready = false;

  this.socket = net.createConnection({
    path: path
  });

  this.socket.on('connect', this._flushQueue.bind(this));

  this.socket.setEncoding('utf8');

  var parser = new LineStream();
  var buffer = [];

  parser.on('data', function(data){
    if(data !== "END"){
      buffer.push(data);
      return;
    }

    var cb = this.callbacks.unshift();
    var res = buffer.splice(0, buffer.length).join("");

    if(cb == noop) {
      console.log("UNHANDLED RES: ", res);
    }else{
      cb(res);
    }
  });

  socket.pipe(parser);
}

module.exports = Client;

Client.prototype._flushQueue = function() {
  var data;
  while(this.queue.length && (data = this.queue.shift() )){
    this.socket.write(data);
  }

  this.ready = true;
};

Client.prototype._send = function(cmd, callback){
  this.callbacks.push(callback || noop);

  cmd += "\r\n";

  if(this.ready){
    this.socket.write(cmd);
  } else {
    this.queue.push(cmd);
  }
};

Client.prototype.list_streams = function(callback){
  this._send("list_streams", callback);
};



// // 1. Connect to liquid soap over socket
// var socket = net.createConnection({
//   path: path.resolve(__dirname, "/tmp/liquidsoap-mixer")
// }, function(){
//   socket.resume();
// });

// socket.setEncoding('utf8');

// var parser = new LineStream();
// socket.pipe(parser);

// var buffer = [];

// parser.on('data', function(data){
//   if(data === "END"){
//     console.log(buffer.join(""))
//     buffer = [];
//     return;
//   }

//   buffer.push(data);
// });

// socket.write('count\r\n');
// socket.write('list_streams\r\n');
