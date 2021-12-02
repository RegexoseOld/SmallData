s.boot;
ServerOptions.devices;
Server.default.options.device_("Fireface 400 (BEF)");
s.options.numAudioBusChannels;
s.options.numOutputBusChannels = 4;
s.options.numInputBusChannels;
s.reboot;

// 5 patterns, die je nach OSC message (1-5) wechseln

~phrases = Dictionary.new();
~cat = '';

// der Nagger
(
		SynthDef.new(\nagger, {
			|maxF=1300, durD= 1, minF=300, adp=1.0, gate=1|
			var sig, env;
			env = EnvGen.kr(Env.adsr(0.2, 0.2, 0.9, 0.2), gate, doneAction:2);
			sig = Pan2.ar(Gendy1.ar(ampdist:1.0, durdist: durD, minfreq:minF, maxfreq:maxF));
			sig = sig * env;
			Out.ar(0, sig);
		}).add;

)

(
Pbind(
	\instrument, \nagger,
    \note,  1,
    \dur, 2,
	\minF, Pwhite(100, 500, 2),
			\maxF, Pkey(\minF) * 2.5,
	\durD, 2
).play
)

// Pdef Section
(
Pdef.new('praise',Pbind(
	\instrument, \nagger,
    \note,  1,
    \dur, 2,
	\minF, Pwhite(100, 500, 2),
			\maxF, Pkey(\minF) * 1.01,
	\durD, 2
)
)

Pdef.new('dissence',Pbind(
	\instrument, \nagger,
    \note,  1,
    \dur, 0.3,
	\minF, Pwhite(100, 500, 10),
	\maxF, Pkey(\minF) * 3,
	\durD, 2
)
)
Pdef.new('insinuation',Pbind(
	\instrument, \nagger,
    \note,  1,
    \dur, 0.8,
	\minF, Pwhite(500, 750, 2),
	\maxF, Pkey(\minF) * 1.1,
	\durD, 2
)
)
Pdef.new('concession',Pbind(
	\instrument, \nagger,
    \note,  1,
    \dur, 2,
	\minF, Pwhite(100, 500, 2),
	\maxF, Pkey(\minF) + 120,
	\durD, 2
)
)
Pdef.new('lecture',Pbind(
	\instrument, \nagger,
    \note,  1,
    \dur, 1,
	\minF, Pwhite(500, 700, 2),
	\maxF, Pkey(\minF) * 2,
	\durD, 2
)
)
)



// make changes to Pdefs. ToDo - soundchanges with OSC

(
~phrases2.put(\concession,
	Pdef(\s_change,
		Pmono(\bass,
        \midinote, Pseq([36, 42, 41, 33], 3),
        \dur, Pseq([0.25, 0.25, 0.25, 0.75], 3),
		\freq, Prand([80, 1000], 1) ,
		\amp, 0.5,
		\detune, 0.3,
			\ffreq, 900
		)
    )
)
)

(
~phrases2.put(\insinuation,
		Pdef(\dim,
		Pbind(
			\instrument, \being,
        \midinote, Pseq([36, 39, 96, 42], inf),
        \dur, Pseq([0.25, 0.5, 0.25, 0.5], inf),
		\amp, 0.2,
		\detune, 0.6,
			\rls, 0.7,
			\atk, 0.7,
			\fund, 400,
			\max, 900,
			\vrate, 3Pbindf
		)
    )
)
)

(
n = NetAddr("127.0.0.1", NetAddr.langPort); // local machine
)

(
OSCdef.new(
	\cat,
	{ arg msg, time, addr, recvPort;
		msg[1].postln;
		~cat = msg[1];
// toDo sublte detune changes in the \nagger synth
		Pdef(msg[1]).play;
	},
	'\cat'
);
)

(
OSCdef.new(
	\quitt,
	{ arg msg, time, addr, recvPort;
		msg[1].postln;


			},
	'/quitt'
);
)

(
OSCdef.new(
	\controller,
	{ arg msg, time, addr, recvPort;
		var ctrl, test;
		msg[1..].postln;
		ctrl = List.newUsing(msg[1..]);
		ctrl.postln;
		postf("cat object   %", ~cat);
		Pdef(~cat, Pbind(\instrument, \nagger, \dur, 0.2, \minF, Pseq(ctrl, 2) * 10));
		Pdef(~cat).play;
		/*test = Pseq(ctrl, 2).asStream;
	5.do({test.next.postln;});*/

	},
	'/control'
);
)




