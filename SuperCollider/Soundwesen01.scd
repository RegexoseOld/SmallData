(s.boot;
ServerOptions.devices;
Server.default.options.device_("Fireface 400 (BEF)");
s.options.numAudioBusChannels;
s.options.numOutputBusChannels = 4;
s.options.numInputBusChannels;
s.reboot;
)

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
			|rsch1= 0.3, rsch2=0.5, freq=200, num=2, blipMul= 0.5, atk= 0.1, sus=0.2, rls=1.0, gate=1, amp=0.4|
			var sig, rausch, env;
			env = EnvGen.kr(Env.adsr(atk, 0.2, sus, rls), gate, doneAction:2);
	  rausch = BrownNoise.ar(LFNoise1.kr(rsch1, rsch2));
			sig = Blip.ar(freq, num, blipMul) + rausch;
			sig = sig * env * amp;
			Out.ar(0, sig!2);
		}).add;

SynthDef.new('insinuation', {
	|minF=150, maxF=600, modRate=5, gate=1, atk=0.4, sus=1, rls=2, ampMod1=0.05, ampMod2=1.6|
	var temp, sig, env, mod, amp;
	env = EnvGen.kr(Env.adsr(atk,0.2,sus, rls), gate, doneAction:2);
	mod = SinOsc.kr(modRate);
	amp = Saw.kr({ExpRand(ampMod1, ampMod2)}!4).range(0,1);
	sig = Pulse.ar({ExpRand(minF, maxF)}!4);
	sig = sig * amp * env * mod;
	sig = Splay.ar(sig) * 0.5;
	Out.ar(0, sig);
}).add;


// der bass für lecture


SynthDef('lecture', {
	|minF = 220, gate = 1, amp = 0.5, slideTime = 0.1, maxF = 1100, width = 0.15,
        detune = 1.005, preamp = 4|
    var  sig, env, freq;
      env = Env.adsr(0.5, 0.3, 0.4, 0.1);
    freq = Lag.kr(minF, slideTime);
    sig = Mix(VarSaw.ar([freq, freq * detune], 0, width, preamp)).distort * amp
        * EnvGen.kr(env, gate, doneAction: Done.freeSelf);
    sig = LPF.ar(sig, maxF);
    Out.ar(0, sig ! 2)
}).add;

// ein default für concession

SynthDef('concession', {
	|freq = 440, gate = 1, detune=0.8, atk=0.3, rls=0.9, amp=0.8, iter=5, pan=0.6|
    var sig, env, temp;
	sig = 0;
	env = EnvGen.kr(Env.adsr(atk, 0.2, 0.8, rls), gate, doneAction: 2);
	iter.do({
		temp = VarSaw.ar({ExpRand(freq, freq * detune)}!2);
		sig = sig + temp ;
	});
    sig = Pan2.ar(sig, SinOsc.kr(pan)) * amp * env;
    Out.ar(0, sig ! 2)
}).add;

// ein arpeggio für praise

SynthDef('praise', {
	|ampHz=4, pulWidth= 0.12, minF=40, fMul=80, fRate= 4, width=0.4, gate=1, atk=0.5, rls=0.9, gain=0.7|
	var amp1, amp2, freq1, freq2, sig1, sig2;
	amp1 = LFPulse.kr(ampHz, 0, pulWidth) * 0.75;
	amp2 = LFPulse.kr(ampHz, 0, pulWidth) * 0.75;
	freq1 = LFNoise0.kr(fRate).exprange(minF, minF*fMul).round(minF);
	freq2 = LFNoise0.kr(fRate).exprange(minF, minF*fMul).round(minF);
	freq1 = freq1 * LFPulse.kr(4, add:1);
	freq2 = freq2 * LFPulse.kr(4, add:1);
	sig1 = Pulse.ar(freq1, width, amp1) * EnvGen.kr(Env.adsr(atk, 0.3, 0.4, rls), gate, doneAction: 2) * gain;
	sig2 = Pulse.ar(freq2, width, amp2) * EnvGen.kr(Env.adsr(atk, 0.3, 0.4, rls), gate, doneAction: 2) * gain;
	Out.ar(0, sig1);
	Out.ar(1, sig2);
}).add;

)

(
Pbind(
	\instrument, 'praise',
    \fRate, 1,
    \dur, 1.5,
	\atk, 0.2,
	\rls, 0.3,
	\ampHz, 0 ,
	\minF, 80
).play
)

// basic patterns
/*
Idee ist es grundpattern zu haben, die mit einkommenden Messages verändert werden
Problem: Wie schaffe ich es, gezielt die richtigen Paramenter der Synths mit den richtigen Werten zu beschicken und zu verändern?
Jeder Synth hat andere Parameter, die bestimmte Werte brauchen.
*/

(

Pbindef(\dissence,
	\instrument, 'dissence',
	\dur, 3,
	\freq, Pseq([200, 200, 200, 500], inf),
	\rsch1, 0.2,
	\rsch2 , 0.5,
	\num, 2,
	\blipMul,  0.01,
	\atk,  1.5,
	\sus, 0.7,
	\rls, 3,
	\gate, 1,
	\amp, 0.4
);

Pbindef(\insinuation,
	\instrument, 'insinuation',
	\dur, Pwhite(3.0, 8.0, inf).trace,
	\minF, 150,
	\maxF, 40,
	\modRate, 0.04,
	\gate, 1,
	\atk, 01.5,
	\sus, 1,
	\rsl, 3,
	\ampMod1, 0.01,
	\ampMod2, 0.1
);

Pbindef(\lecture,
	\instrument, 'lecture',
	\dur, 1,
	\minF, Pwhite(200, 400, inf),
	\gate , 1,
	\amp , 0.5,
	\slideTime , 1.8,
	\maxF , 800,
	\width , 0.15,
    \detune , 1.005,
	\preamp , 4
);

Pbindef(\concession,
	\instrument, 'concession',
	\dur, 2,
	\atk , 0.03,
	\rls, 0.8,
	\freq, Prand([100, 150, 300], inf),
	\detune, Pwrand([0.3, 1.01, 2.1], [0.2, 0.7, 0.1], inf),
	\amp, 0.7,
	\iter, Prand([2, 4, 6], inf),
	\pan, Pgauss(3, 2.5, inf)
);

Pbindef(\praise,
	\instrument, 'praise',
	\dur, 2,
	\ampHz , Pgauss(0.8, 0.5, inf),
	\minF, 100,
	\fMul, 3,
	\fRate, 2,
	\width, 1.5,
	\gain, 0.6,
	\atk, Pwhite(0.03, 0.9, inf),
	\rls, Pkey(\atk)*3,
	\pulWidth, 5
);
)


(
~setBasicDuration = {
	arg dur;
	[\dissence, \praise, \insinuation, \concession, \lecture].do(
	{arg item;
		Pbindef(item, \dur, dur);
});
};
)
 /// testing
)
Pbindef('dissence').play;
Pbindef(\dissence).stop;
Pbindef(\insinuation).play;
Pbindef(\concession).stop;
Pbindef(\dissence, \dur, 0.8 , \num, 2, \freq, Pseq([200, 200, 200, 400], inf), \rls, 8);
Pbindef(\dissence, \rsch2, 0.9, \rls, 6, \legato, 2, \blipMul, Pn(Pseries(0.08, 0.05, 16), inf));
Pbindef(\dissence, \atk, Pn(Pseries(0.04, 0.02, 8), inf), \rls, 4);
Pbindef(\insinuation, \sus, 0.7 );
Pbindef(\dissence).clear;


// clock

(
t = TempoClock.new(108, 60);
~postBeats = {t.beats.postln; 1};
// t.schedAbs(t.nextBar, {~postBeats.value});
)
//case functions

(
// die erste Message?

~init = {// start a Pattern
	arg name, repeat;
	name.postln;
	repeat.postln;
	Pbindef(name).play(t, quant:1);
}
)
~init.value(\dissence, 1);

// set Functions section
// diese Funktionen wandeln eingehende Signale in Patterns für die SynthDefs um
// siehe Pattern Guide Cookbook

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
		Pbindef(~cat).stop;
		postf("\nnew cat: %", msg[1]);
		postf("\nnew count: %", msg[2]);
		~cat = msg[1];
		postf("\n~cat renamed %\n", ~cat);
		Pbindef(~cat).play;
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




