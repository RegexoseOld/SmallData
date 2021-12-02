s.boot;
ServerOptions.devices;
Server.default.options.device_("Fireface 400 (BEF)");
s.options.numAudioBusChannels;
s.options.numOutputBusChannels = 4;
s.options.numInputBusChannels;
s.reboot;


~phrases = Dictionary.new();
{Pulse.ar([400, 500, 600],[0.5, 0.1, 0.1], 0.2)}.play;(

(
SynthDef.new(\mutter, {
	|fund=150, max=600, modRate=5, gate=1, atk=0.4, sus=3, rel=2, iter=5, dup=2|
	var temp, sig, env, mod, amp;
	env = EnvGen.kr(Env.adsr(atk,0.2,sus, rel), gate, doneAction:2);
	mod = SinOsc.kr(modRate);
	amp = Saw.kr({ExpRand(0.05, 2)}!4).range(0,1);
	sig = Pulse.ar({ExpRand(fund, max)}!4);
	sig = sig * amp * env * mod;
	sig = Splay.ar(sig) * 0.5;
	Out.ar(0, sig);
}).add;
)


x = Synth.new(\mutter);

x.set(\gate, 1);
x.set(\iter, 2);
x.set(\modRate, 1.5);
x.set(\max, 300);
	x.set(\fund, 2);

(
TempoClock.default.tempo = 1;
p = Pbind(
	\instrument, \mutter,
	\degree, Pseq([4], inf),
    \dur, 1.4,
	\modRate, Prand([0.66, 0.99, 4], inf),
	\fund, Pseq([50, 90], inf),
	\max,  Pkey(\fund),
).play;
)

// check den als Alternatice
{Pan2.ar(Gendy1.ar)}.play
	{Gendy1.ar}.play
(
		SynthDef.new(\nagger, {
			|maxF=1300, durD= 1, minF=300, adp=1.0, gate=1|
			var sig, env;
			env = EnvGen.kr(Env.adsr(0.2, 0.2, 0.9, 0.2), gate, doneAction:2);
			sig = Pan2.ar(Gendy1.ar(ampdist:1.0, durdist: durD, minfreq:minF, maxfreq:maxF));
			sig = sig * env;
			// sig = Pan2.ar(Gendy1.ar(dist, durD, 1.0, 1.0, minF));
			Out.ar(0, sig);
		}).add;

)

(
Pbind(
	\instrument, \nagger,
    \note,  1,
    \dur, 0.1,
	\minF, Pwhite(500, 1000, 10),
    \maxF, 1300,
	\durD, 2
).play
)


(
SynthDef.new(\q2, {
	|freq=300, detune=1, gate=1, atk=0.1, rel=0.5, iter=4|
	var sig, temp, env, mod;
	sig = 0;
	env = EnvGen.kr(Env.adsr(atk, 0.1, 0,1, rel), gate, doneAction:2);
	mod = 0.5;
	iter.do({|item|
		temp = Saw.ar(
			freq + item * detune,
			0.6)!2;
		sig = sig + temp ;
	});
	sig = sig * env * 0.2;
	Out.ar(0, sig!2);
}).add;
	)
 // pattern guide cookbook 02, manipulation patterns
(
~degree_01 = PatternProxy(Pwrand([1, 2, 7], [0.75, 0.18, 0.07], 16));
~detune_01 = PatternProxy(Pgauss(1.0, 0.04, 4));
~dur_01 = PatternProxy(Pn(2, inf));
~iter_01 = PatternProxy(Pwrand([2, 6, 15], [0.1, 0.2, 0.6], 4));
~atk_01 = PatternProxy(Pn(1, inf));


~phrases.put("praise", Pdef(\chromatic,
	Pbind(
	\instrument, \q2,
	\degree, ~degree_01,
	\detune, ~detune_01,
	\dur, ~dur_01,
	\rel, Pexprand(0.2, 1.5, inf),
	\iter, ~iter_01,
	\atk, ~atk_01,
	\legato, 0.3)
)
)
)
	(
~degree_01.source =  Pseq([4], inf);
~detune_01.source = Pgauss(1.0, 0.04, inf);
~dur_01.source = Pseq([2], inf);
~atk_01.source = Pn(1, inf);
)

(
~degree_02 = PatternProxy(Pwrand([1, 2, 7], [0.75, 0.18, 0.07], inf));
~modRate_02 = PatternProxy(Pgauss(1.0, 0.04, inf));
~dur_02 = PatternProxy(Pn(0.2, inf));
~iter_02 = PatternProxy(Prand([2, 6], inf));
~atk_02 = PatternProxy(Pn(1, inf));

~phrases.put("dissence", Pdef(\chromatic,
	Pbind(
	\instrument, \mutter,
	\degree, ~degree_02,
	\modRate, ~modRate_02,
	\dur, ~dur_02,
	\rel, Pexprand(0.2, 1.5, inf),
	\iter, ~iter_02,
	\atk, ~atk_02,
	\legato, 0.3)
)
)
)
~phrases["pr aise"].play;
~phrases["praise"].stop;



~phrases["dissence"].play;
~phrases["dissence"].stop;
(
~modRate_02.source = Pgauss(5, 1.5, inf);
)

(
	Pdef(\chromatic, {
		Pbind(
	\instrument, \q2,
	\degree, Pseq(Scale.major, 1),
	\detune, Pgauss(1, 0.02, 12),
	\dur, Pgauss(0.23, 0.01, 12),
	\rel, Pexprand(0.2, 1.5, inf),
	\atk, 0.1,
	\iter, 5,
	\legato, 0.3)
	}).play;

)


( 'instrument': \quengel, 'degree': 2, 'dur': 0.5 ).stop;
q = Pseq(Scale.minor, 3).asStream;
q.next();
((0..7) ++ [\rest]).size
[0.99, 0.98, 1.01, 1.05, 0.91, 0.97, 1.0, 0.98, 1.01].size
(
~b = Pgauss(9.95, 0.05, 5);

)
~b.asStream.nextN(5);
Scale.chromatic.size