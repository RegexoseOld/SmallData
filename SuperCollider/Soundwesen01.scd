s.boot;
ServerOptions.devices;
Server.default.options.device_("Fireface 400 (BEF)");
s.options.numAudioBusChannels;
s.options.numOutputBusChannels = 4;
s.options.numInputBusChannels;
s.reboot;

/* Das Soundwesen
5 SynthDefs die von eingehenden Categories mit passenden messages beliefert werden.
Jede SynthDef wechselt Noten/Akkorde (die alte \advance message), Klangeffekte 8Volume, FX, Modulationen)

Frage: Was ist mit mehreren Instanzen von SynthDefs? Klanglich eben sehr interessant.
Lassen die sich dann noch steuern? In welchen Container kann man sie speichern?
*/

~cat = '';
~instruments = Dictionary.new();

//Simple Blips, von Metronom, Echolot mit Telefontuten
(
SynthDef.new('dissence', {
			|freq=200, num=150, atk= 0.1, sus=0.2, rls=1.0, gate=1, amp=0.4|
			var sig, env;
			env = EnvGen.kr(Env.adsr(atk, 0.2, sus, rls), gate, doneAction:2);
			sig = Blip.ar(freq, num);
			sig = sig * env * amp;
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
	|out, minF = 220, gate = 1, amp = 0.5, slideTime = 0.1, maxF = 1100, width = 0.15,
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

b = Synth.new('lecture');
b.getMsg(2);
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
    \freq, Pseq([100, 100, 100, 200], inf),
    \dur, 1.5,
	\atk, Pgauss(0.01, 0.005, inf),
	\rls, Pseries(0.2, 0.2, inf),
	\sus, Pseries(0.02, 0.05, inf),
	\cf, 800
).play
)


// basic patterns
/*
Idee ist es grundpattern zu haben, die mit einkommenden Messages verändert werden
*/
(
~argNames = Dictionary.new;
~argNames['dissence'] = [\freq, \num, \atk, \sus, \rls, \gate, \amp];
~setBasicPatterns = {
	arg synthName;
	~rhythm01 = EventPatternProxy(Pbind(
	\instrument, synthName,
	\dur, 1,
    \legato, 0.1));

	~melo01 = EventPatternProxy(Pbind(
	\instrument, synthName,
    \degree, Pseq([200, 200, 200, 400], inf).trace,
	\num, 600));
}
~setPatternByName = {
	arg sName;
}
)
~setBasicPatterns.value('dissence');
~rhythm01.play;
~rhythm01.source = Pbind(\dur, Pgauss(0.23, 0.05, inf), \degree, Pwhite(-2, 10, inf), \atk, Pwhite(0.1, 0.4, inf) );
(
// die erste Message?
~init = {// start a Pattern
	arg name, repeat;
	name.source = Pbind(\dur, Pgauss(1.0, 0.05, repeat));
	name.play(quant:1);
}

)
~init.value(~rhythm01, 4);
(
TempoClock.default.tempo = 100/60;

~rhythm01.play(quant:1);
~melo01.play(quant:1);

~rhythm01.source = Pbind(\dur, Pgauss(1.0, 0.05, inf), \legato, Pwhite(0.1, 0.2, inf), \width, 0.1,
	\amp, 0.8, \amp, Pwrand([0.2, 0.4, 0.8], [0.4, 0.5, 0.6], inf), \instrument, 'dissence');
~melo01.source = Pbind(\degree, Pwrand([-12, 0, 12], [0.4, 0.3, 0.1], inf), \amp, Pwrand([0.2, 0.4, 0.8], [0.4, 0.5, 0.6], inf), \instrument, 'dissence', \num, 200);
)

~rhythm01 = Pset(\dur, Pgauss(0.2, 0.03, inf), ~rhythm01);
Pchain(~melo02, ~rhythm01).play;

// set Functions section
// diese Funktionen wandeln eingehende Signale in Patterns für die SynthDefs um
// siehe Pattern Guide Cookbook


// Pdef Section1
(
Pdef.new('dissence', Pbind(
	\instrument, 'dissence',
    \freq, Pseq([100, 200], 3),
    \dur, 1.5,
	\atk, Pgauss(0.01, 0.005, 6),
	\rls, Pseries(0.2, 0.2, 6),
	\sus, Pseries(0.02, 0.05, 6)
)
)

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
['dissence', 'praise', 'insinuation', 'concession', 'lecture'].do(
	{
	arg catName;
	OSCdef.new(
	catName.asSymbol,
	{ arg msg, time, addr, recvPort;
		postf("\nnew cat: %", msg[0]);
		postf("\nnew count: %", msg[1]);
		~cat = msg[0];
		postf("\n~cat renamed %", ~cat);
		~init.value(~rhythm01, msg[1]);
// toDo sublte detune changes in the \nagger synth
		// Pdef(msg[1]).play;
	},
	catName
);
});

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




