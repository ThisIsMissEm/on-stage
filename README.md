# On-Stage

Easily fade between different Icecast source clients and Icecast streams.

## NOTE: This is a pre-release and under heavy development as part of the ongoing London Music Hackday.

----

**On Stage** is design for situations where you currently broadcast from an Icecast Source Client (ices, nicecast, butt) into an Icecast Server, but wish to now broadcast from multiple studios.

An example usage can be found below:

```
     __________           __________
    | Source 1 |         | Source 2 |
    | (London) |         | (Berlin) |
    |___   ___|          |___   ____|
        |.|                  |.|
        |.|                  |.|
        |.|                  |.|               __________
   _____\_/__________________\_/________      |          |
  |                                    |      | On-Stage |
  |         Mixer  (Liquidsoap)        <======>  Web UI  |
  |______________      ________________|      |          |
                 |     |                      |__________|
   ______________ \   / _______________
  |                \./                 |
  |                                    |
  |           Icecast Server           |
  |                                    |
  |____________________________________|

```

Without On-Stage, you'd be forced to rely on using Icecast Fallback mountpoints, which provide very limited functionality other than rescueing you when your stream goes down.

-----

## About FutureRadio

FutureRadio is an organisation under which Micheil Smith <micheil@brandedcode.com> is working on tools to improve the standards of radio production, broadcast, and management.

