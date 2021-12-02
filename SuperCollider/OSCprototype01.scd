s.boot;
ServerOptions.devices;
Server.default.options.device_("Fireface 400 (BEF)");
s.options.numAudioBusChannels;
s.options.numOutputBusChannels = 4;
s.options.numInputBusChannels;
s.reboot;

// 5 patterns, die je nach OSC message (1-5) wechseln

~cat = '';
~instruments = Dictionary.new();

// der Nagger für dissence
(
SynthDef.new('dissence', {
			|maxF=1300, durD= 1, minF=300, adp=1.0, gate=1|
			var sig, env;
			env = EnvGen.kr(Env.adsr(0.2, 0.2, 0.9, 0.2), gate, doneAction:2);
			sig = Pan2.ar(Gendy1.ar(ampdist:1.0, durdist: durD, minfreq:minF, maxfreq:maxF));
			sig = sig * env;
			Out.ar(0, sig);
		}).add;
)
 // der mutter für insinuation
(
SynthDef.new('insinuation', {
	|minF=150, maxF=600, modRate=5, gate=1, atk=0.4, sus=3, rel=2, iter=5, dup=2|
	var temp, sig, env, mod, amp;
	env = EnvGen.kr(Env.adsr(atk,0.2,sus, rel), gate, doneAction:2);
	mod = SinOsc.kr(modRate);
	amp = Saw.kr({ExpRand(0.05, 2)}!4).range(0,1);
	sig = Pulse.ar({ExpRand(minF, maxF)}!4);
	sig = sig * amp * env * mod;
	sig = Splay.ar(sig) * 0.5;
	Out.ar(0, sig);
}).add;
)

// der bass für lecture

(
SynthDef('lecture', {
	|out, minF = 440, gate = 1, amp = 0.5, slideTime = 0.1, maxF = 1100, width = 0.15,
        detune = 1.005, preamp = 4|
    var  sig, env, freq;
      env = Env.adsr(0.5, 0.3, 0.4, 0.1);
    freq = Lag.kr(minF, slideTime);
    sig = Mix(VarSaw.ar([freq, freq * detune], 0, width, preamp)).distort * amp
        * EnvGen.kr(env, gate, doneAction: Done.freeSelf);
    sig = LPF.ar(sig, maxF);
    Out.ar(out, sig ! 2)
}).add;
)

// ein default für concession
(
SynthDef('concession', {
	|out=0, minF = 440, gate = 1, maxF= 200, detune=0.8|
    var  sig, env;
	env = Env();
    sig = VarSaw.ar(minF * detune) * EnvGen.kr(env, gate, doneAction: 2);
    sig = LPF.ar(sig, maxF);
    Out.ar(out, sig ! 2)
}).add;
)
// ein arpeggio für praise
(
SynthDef('praise', {
	|ampHz=4, minF=40, maxF=4, width=0.4, gate=1|
	var amp1, amp2, freq1, freq2, sig1, sig2;
	amp1 = LFPulse.kr(ampHz, 0, 0.12) * 0.75;
	amp2 = LFPulse.kr(ampHz, 0, 0.12) * 0.75;
	freq1 = LFNoise0.kr(4).exprange(minF, minF*maxF).round(minF);
	freq2 = LFNoise0.kr(4).exprange(minF, minF*maxF).round(minF);
	freq1 = freq1 * LFPulse.kr(4, add:1);
	freq2 = freq2 * LFPulse.kr(4, add:1);
	sig1 = Pulse.ar(freq1, width, amp1) * EnvGen.kr(Env.adsr(0.5, 0.3, 0.4, 0.9), gate, doneAction: 2);
	sig2 = Pulse.ar(freq2, width, amp2) * EnvGen.kr(Env.adsr(0.5, 0.3, 0.4, 0.9), gate, doneAction: 2);
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;
)

(
Pbind(
	\instrument, 'dissence',
    \note,  1,
    \dur, 2,
	\minF, Pwhite(100, 500, 2),
			\maxF, Pkey(\minF) * 2.5,
	\durD, 2
).play
)

// Pdef Section

(
Pdef.new('praise', Pbind(
	\instrument, 'dissence',
    \note,  1,
    \dur, 2,
	\minF, Pwhite(100, 500, 2),
			\maxF, Pkey(\minF) * 1.01,
	\durD, 2
)
)
)
(
Pdef.new('dissence',Pbind(
	\instrument, 'dissence',
    \note,  1,
    \dur, 0.3,
	\minF, Pwhite(100, 500, 10),
	\maxF, Pkey(\minF) * 3,
	\durD, 2
)
)
)
(
Pdef.new('insinuation',Pbind(
	\instrument, 'insinuation',
    \note,  1,
    \dur, 0.8,
	\minF, Pwhite(500, 750, 2),
	\maxF, Pkey(\minF) * 1.1,
	\durD, 2
)
)
)
(
Pdef.new('concession',Pbind(
	\instrument, 'concession',
    \note,  1,
    \dur, 2,
	\minF, Pwhite(100, 500, 2),
	\maxF, Pkey(\minF) + 120,
	\durD, 2
)
)
)

(
Pdef.new('lecture', Pbind(
	\instrument, 'lecture',
    \note,  10,
    \dur, 0.5,
	\minF, Pwhite(100, 500, 2) /2,
	\maxF, Pkey(\minF) * 2,
	\durD, 2
)
)
)
(
~praise = PatternProxy(Pdef('praise'));
)
Pdef('praise').source.postcs;

/// Osc Section

(
n = NetAddr("127.0.0.1", NetAddr.langPort); // local machine
)

(
OSCdef.new(
	\cat,
	{ arg msg, time, addr, recvPort;
		postf("\nnew cat: %", msg[1]);
		postf("\nnew count: %", msg[2]);
		~cat = msg[1];
		postf("\n~cat renamed %", ~cat);
// toDo sublte detune changes in the \nagger synth
		// Pdef(msg[1]).play;
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
		ctrl = List.newUsing(msg[1..]);
		//ctrl.postln;
		postf("\ncat object   %", ~cat); // manchmal 2 cats hintereinander ???
		Pdef(~cat, Pbind(
			\instrument, ~cat.asString,
			\note,  10,
			\dur, 0.2,
			\minF, Pseq(ctrl, 1) *4,
			\maxF, Pkey(\minF) *2
		)
	);

		Pdef(~cat).play;

	},
	'/control'
);
)

// set functions
setPdef = {
	arg name, count;

	Pdef(name,)
}




