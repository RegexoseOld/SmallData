

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
	|out, fund=80, max=220, atk=0.8, rls=1.5, gate=1|
	var sig, env;
	env = EnvGen.kr(Env.linen(atk, 0.2, rls), gate, doneAction:2);
	sig = SinOsc.ar({ExpRand(fund, max)}! 4) * env;
	sig = Splay.ar(sig) * 0.5;
	Out.ar(out, sig);
	}).add;
)


// Uses the bass and being synth above
// make Dictionay to address Pdefs

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
		Pdef(\dim, Pmono(\being,
        \midinote, Pseq([36, 39, 76, 42], 1),
        \dur, Pseq([0.25, 0.5, 0.25, 0.5], 1),
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
        \midinote, Pseq([36, 42, 41, 33], 1),
        \dur, Pseq([0.25, 0.25, 0.25, 0.75], 1),
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
	Pdef(\s_change,
		Pmono(\being,
        \midinote, Pseq([36], 1),
        \dur, Pseq([0.25], 1),
		\fund, 70 ,
		\max, 333,
		\amp, 0.5,
		\atk, 0.2,
		\rls, 0.3
		)
    )
)
)

(
n = NetAddr("127.0.0.1", NetAddr.langPort); // local machine
)

(
OSCdef.new(
	\notes,
	{ arg msg, time, addr, recvPort;
		msg[1].postln;
// toDo sublte sound changes in the \being synth
			if (msg[1].even, {
			~phrases2[\dissence].play;
		},{
			~phrases2[\insinuation].play;
		})

	},
	'\sc'
);
)

(
OSCdef.new(
	\fader01,
	{ arg msg, time, addr, recvPort;
		msg[1].postln;
		/*x.set(\freq1, msg[1]);
		x.set(\freq2, msg[1] *8);
		x.set(\speed, msg[1] /8);*/
		y.set(\speed, msg[1]/400);

	},
	'/fad1'
);
)
~phrases2[\praise].play;