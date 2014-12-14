set("log.file.path","/tmp/mixer.log")
set("log.stdout", true)

set("gstreamer.debug_level", 5)

set("scheduler.log", true)
set("scheduler.fast_queues",10)
set("scheduler.generic_queues",10)
set("scheduler.non_blocking_queues",10)

# Socket control
set("server.socket",true)
set("server.socket.path","/tmp/liquidsoap-mixer")
set("server.timeout",-1.0)

set("harbor.bind_addr","0.0.0.0")
set("harbor.reverse_dns", false)

dyn_sources = ref []
dyn_sources_names = ref []
dyn_source_id = ref 0
active_source = ref 0

def add_dyn_source(~id, s)
  dyn_source_id := !dyn_source_id + 1

  dyn_sources := list.append(!dyn_sources, [ s ] )
  dyn_sources_names := list.append(!dyn_sources_names, [ id ] )

  # make sure we read from `s`
  ignore(output.dummy(fallible=true, s))
end

def add_stream(uri)
  ident = "s#{!dyn_source_id}_stream"
  httpstream = input.http(id=ident, autostart=true, uri)
  ignore(add_dyn_source(id=ident, httpstream))
  ignore(ident)
end

def add_source(mount, password)
  ident = "s#{!dyn_source_id}_source"
  harbor = input.harbor(id=ident, port=8080, password=password, mount)
  ignore(add_dyn_source(id=ident, harbor))
end

jingle = single(id="jingle", conservative=true, default_duration=7.0, length=7.0, "~/jingle.mp3")

default = amplify(id="default", 0.00001, noise())
ignore(add_dyn_source(id="default", default))

add_stream("http://listen.ntslive.co.uk/stream")
add_source("s1", "testing")
add_source("s2", "testing")
add_source("s3", "testing")
add_source("s4", "testing")



def transition(sInt)
  index = int_of_string(sInt)
  len = list.length(!dyn_sources)

  if index >= 0 and index < len then
    log("switching to: #{index}")

    id = list.nth(!dyn_sources_names, index)
    log("streams.select(#{index}) => #{id}")
    active_source := index
    json_of("done")
  else
    "Error: Could not transition to out-of-bounds stream"
  end
end

def dyn_names(_)
  # list.fold(fun (a, b) -> string_concat(",", [a, b]), )
  json_of(!dyn_sources_names)
end

def dyn_count(_)
  json_of(list.length(!dyn_sources))
end


def mute(_)
  active_source := 0
  json_of("done")
end

server.register(description="Retrieve number of available streams", "count", dyn_count)
server.register(description="Retrieve names of available streams", "list_streams", dyn_names)
server.register(description="Select a stream.", "transition", transition)
server.register("mute", mute)

sfs = list.map(fun (source) -> begin
  (fun() -> begin
    list.nth(!dyn_sources_names, !active_source) == source.id(source)
  end, source)
end, !dyn_sources)


def crossfade(a,b)
  if source.id(a) == "default" and source.id(b) != "default" then
    add(normalize=false, [
      sequence(merge=true, [ fade.initial(jingle, duration=0.6, type="log"), blank(duration=2.5) ]),
      sequence(merge=true, [ blank(duration=3.75), fade.initial(b) ])
    ])
  elsif source.id(a) != "default" and source.id(b) == "default" then
    add(normalize=false, [
      fade.final(a, duration=2.0),
      sequence(merge=true, [ blank(duration=0.75), fade.initial(jingle, duration=0.6, type="log"), blank(duration=2.5) ])
    ])
  else
    add(normalize=false, [
      fade.final(a, duration=2.0),
      sequence(merge=true, [ blank(duration=0.9), fade.initial(jingle, duration=0.6, type="log"), blank(duration=2.5) ]),
      sequence(merge=true, [ blank(duration=4.5), fade.initial(b) ])
    ])
  end
end


stream = switch(track_sensitive=false, transitions=list.map(fun(_) -> crossfade, sfs), sfs)
stream = fallback(track_sensitive=false, transitions=[ crossfade, crossfade ], [stream, default])


output.icecast(%mp3,
  id="icecast",
  host="localhost",
  port=8000,
  password="on-stage-source",
  mount="radio",
  fallible=true,
  stream
)

