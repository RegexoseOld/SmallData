# SmallData
This app receives OSC messages from smalldata_webserver / smalldata_proxy and manages the allocation of sonic patterns. It runs on SuperCollider.

- download and install SuperCollider `https://supercollider.github.io/`

# config
- make a copy of `config.scd.template` rename it `config.scd`.
-  Change strings for ~audioInterface. Find out what audioInterfaces you have by evaluating `Server.options.devices;`
-  and ~showName the String points to the directory ind /shows. Check them out

# startup
- open start.scd in SuperCollider and evaluate the code block enclosed with the brackets `(~projectRoot = PathName(thisProcess.nowExecutingPath).parentPath; ......	"done".postln;)`