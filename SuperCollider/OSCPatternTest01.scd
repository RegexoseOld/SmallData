

// 5 patterns, die je nach OSC message (1-5) wechseln
(
SynthDef(\bass, { |out, freq = 440, gate = 1, amp = 0.5, slideTime = 0.1, ffreq = 1100, width = 0.15,
        detune = 1.005, preamp = 4|
    var    sig,
        env = Env.adsr(0.5, 0.3, 0.4, 0.1);
    freq = Lag.kr(freq, slideTime);
    sig = Mix(VarSaw.ar([freq, freq * detune], 0, width, preamp)).distort * amp
        * EnvGen.kr(env, gate, doneAction: Done.freeSelf);
    sig = LPF.ar(sig, ffreq);
    Out.ar(out, sig ! 2);
}).add;
)

(
SynthDef.new(\being, {
	|out, fund=150, max=220, atk=0.8, rls=1.5,
	|vfreq=300, vrate= 3, vdepth=0.03 |
	var sig, flt, env;
	env = EnvGen.kr(Env.linen(atk, 0.2, rls), 1, doneAction:2);
	flt = Vibrato.kr(vfreq,vrate, vdepth);
	sig = SinOsc.ar({ExpRand(fund, max)}! 4) * env * flt;
	sig = Splay.ar(sig) * 0.2;
	Out.ar(out, sig);
	}).add;
)


// Uses the bass and being synth above
// make Dictionary to address Pdefs
~being = Synth(\being);

(
~phrases2 = Dictionary.new();

(
~phrases2.put(\praise,
    Pdef(\repeated, Pbind(
        \instrument, \bass,
        \midinote, 36,
        \dur, Pseq([0.75, 0.25, 0.25, 0.25, 0.5], 1),
        \legato, Pseq([0.9, 0.3, 0.3, 0.3, 0.3], 1),
        \amp, 0.5, \detune, 1.005)
	)
)
)
(
~phrases2.put(\dissence,
    Pdef(\octave, Pmono(\bass,
        \midinote, Pseq([36, 44, 36], 1),
        \dur, Prand([0.01, 0.22], 1) ,
		\freq, Prand([80, 1000], 1) ,
        \amp, 0.5, \detune, 1.005)
	)
)
)
(
~phrases2.put(\concession,
	Pdef(\tritone, Pmono(\bass,
        \midinote, Pseq([36, 42, 41, 33], 1),
        \dur, Pseq([0.25, 0.25, 0.25, 0.75], 1),
		\amp, 0.5, \detune, 1.005)
    )
)
)
(
~phrases2.put(\insinuation,
		Pdef(\dim, Pbind(
		\instrument, \being,
        \midinote, Pseq([36, 39, 96, 42], 3),
        \dur, Pseq([0.25, 0.5, 0.25, 0.5], 3),
		\amp, 0.5, \detune, 1.005)
    )
)
)
)
~phrases2.getPairs

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
			\vrate, 3
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
// toDo sublte sound changes in the \being synth


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
		msg[1..].postln;

	/*	msg[1..].do({ arg item, i;
			[i, item].postln;


		});*/
		/*	if (msg[1].even, {
			~phrases2[\dissence].play;
		},{
			~phrases2[\insinuation].play;
		})*/

	},
	'/control'
);
)
~phrases2[\concession].play;
~phrases2[\insinuation].play;
(
Pbind(
	\instrument, \being,
	\fund, 500,
	\max, 900,
	\vfreq, 200,
	\vdepth, 0.6
)
)



