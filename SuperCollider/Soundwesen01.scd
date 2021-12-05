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
	|rsch1= 0.5, rsch2=0.5, freq=10, num=2, blipMul= 0.5, atk= 0.1, sus=0.2, rls=1.0, gate=1, amp=0.4|
	var sig, rausch, env;
	env = EnvGen.kr(Env.adsr(atk, 0.2, sus, rls), gate, doneAction:2);
	rausch = BrownNoise.ar(LFNoise1.kr(rsch1, rsch2));
	sig = Blip.ar(freq, num, blipMul) + rausch;
	sig = sig * env * amp;
	Out.ar(0, sig!2);
	}).add;

SynthDef.new('insinuation', {
	|freq=150, maxF=600, modRate=5, gate=1, atk=0.4, sus=1, rls=2, ampMod1=0.05, ampMod2=1.6, pmindx=pi|
	var temp, sig, env, mod, amp;
	env = EnvGen.kr(Env.adsr(atk, 0.2,sus, rls), gate, doneAction:2);
	mod = SinOsc.kr(modRate);
	amp = Saw.kr({ExpRand(ampMod1, ampMod2)}!4).range(0,0.8);
	sig = PMOsc.ar({ExpRand(freq, maxF)}!4, {LFNoise0.ar(modRate)}!4, pmindex:pmindx);
	sig = sig * amp * env * mod;
	sig = Splay.ar(sig) * 0.5;
	Out.ar(0, sig);
}).add;


// der bass für lecture


SynthDef('lecture', {
	|freq = 220, gate = 1, amp = 0.5, slideTime = 0.1, maxF = 1100, modWidth = 0.15,
        detune = 1.005, preamp = 1, atk=0.5, rls= 0.1, ffreq = 3|
    var  sig, env, frq;
    env = EnvGen.kr(Env.adsr(atk, 0.3, 0.7, rls), gate, doneAction: 2) ;
    frq = Lag.kr(freq, slideTime);
    sig = PMOsc.ar( frq * detune, LFNoise2.ar(slideTime, maxF), SinOsc.ar(ffreq), pmindex:modWidth, mul:preamp) * amp
        * env ;
    sig = FreqShift.ar(sig, maxF, );
    Out.ar(0, sig ! 2)
}).add;

// ein default für concession

SynthDef('concession', {
	|freq = 440, maxF=500, gate = 1, detune=0.8, atk=0.3, rls=0.9, amp=0.8, iter=5, pan=0.6|
    var sig, env, temp;
	sig = 0;
	env = EnvGen.kr(Env.adsr(atk, 0.2, 0.8, rls), gate, doneAction: 2);
	iter.do({
		temp = VarSaw.ar({ExpRand(freq, freq * Rand(0.98, 1.2))}!2);
		sig = sig + temp ;
	});
    sig = Pan2.ar(sig, SinOsc.kr(pan)) * amp * env;
    Out.ar(0, sig!2)
}).add;

// ein arpeggio für praise

SynthDef('praise', {
	|ampHz=4, ampScale=0.01, pulWidth= 0.12, pulRate=4, freq=40, fMul=80, rnd=1, fRate= 4, width=0.4, gate=1, atk=0.5, rls=0.9, gain=0.7,
	ffreq= 150, rq=1.0|
	var amp1, amp2, freq1, freq2, sig1, sig2, env1, env2;
	amp1 = LFPulse.kr(ampHz, 0, pulWidth) * ampScale;
	amp2 = LFPulse.kr(ampHz, 0, pulWidth) * ampScale;
	env1 = EnvGen.kr(Env.adsr(atk, 0.2, 0.7, rls), gate, doneAction:2);
    env2 = EnvGen.kr(Env.adsr(atk, 0.1, 0.7, rls), gate, doneAction:2);
	freq1 = LFNoise0.kr(fRate).exprange(freq, freq*fMul).round(freq *rnd);
	freq2 = LFNoise0.kr(fRate).exprange(freq, freq*fMul).round(freq *rnd);
	freq1 = freq1 * LFPulse.kr(pulRate, add:0);
	freq2 = freq2 * LFPulse.kr(pulRate, add:0);
	sig1 = RHPF.ar(Pulse.ar(freq1, width) + Pulse.ar(freq1, width, amp1), ffreq, rq) * env1 * gain ;
	sig2 = RHPF.ar(Pulse.ar(freq2, width) + Pulse.ar(freq2, width, amp2), ffreq, rq) * env2 * gain;
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

~resetDissence = {Pbindef(\dissence,
	\instrument, 'dissence',
	\dur, Pseq([3, 1], inf),
	\freq, 80,
	\rsch1, 0.5,
	\rsch2 , 0.5,
	\num, 2,
	\blipMul, 0.01,
	\atk,  2,
	\sus, 0.7,
	\rls, 1,
	\gate, 1,
	\amp, 0.4
);};

~resetInsinuation = {Pbindef(\insinuation,
	\instrument, 'insinuation',
	\dur, 10,
	\freq, 100,
	\maxF, 200,
	\modRate, 50,
	\gate, 1,
	\atk, 1.5,
	\sus, 1,
	\rls, 2,
	\ampMod1, 0.01,
	\ampMod2, 1,
	\pmindx, pi,
);};

~resetLecture = {Pbindef(\lecture,
	\instrument, 'lecture',
	\dur, 2,
	\freq, 20,
	\modWidth, 1,
	\rls, 0.4,
	\atk, 0.2,
	\preamp, 0.7,
	\slideTime, pi,
	\ffreq, 10,
	\maxF, 50,
	\detune, 1
);
};
~resetConcession = {Pbindef(\concession,
	\instrument, 'concession',
	\dur, 2,
	\atk , 0.03,
	\rls, 0.8,
	\freq, Prand([100, 150, 300], inf),
	\detune, Pwrand([0.3, 1.01, 2.1], [0.2, 0.7, 0.1], inf),
	\amp, 0.7,
	\iter, Prand([2, 4, 6], inf),
	\pan, Pgauss(3, 2.5, inf)
);};

~resetPraise =  {Pbindef(\praise,
	\instrument, 'praise',

	\dur, Pn(0.3, 3),
	\ampHz , 0.3,
	\ampScale, 0.03,
	\freq, 100,
	\fMul, 10,
	\pulWidth, 0.24,
	\fRate, 0.5,
	\width, 0.3,
	\gain, 0.6,
	\atk, 2.8,
	\rls, 3,
	\ffreq, 40,
	\rq, 3,
	\pulWidth, 5,
	\pulRate, 0.15,
	\gain, 0.3
);};
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
(~resetConcession.value;
~resetDissence.value;
~resetInsinuation.value;
~resetPraise.value;
~resetLecture.value;)
Pbindef('praise').play;

(
Pbindef('praise', \dur, Pn(0.3, 3), \gain, 0.3,
	\ampHz, 0.3, \ampScale, 0.03, \fMul, 10, \pulWidth, 0.24, \atk, 2.9, \rls, 3, \fRate, 0.5, \freq, 100, \ffreq, 40, \rq, 3, \pulRate, 0.15, \width, 0.2);
)
Pbindef(\dissence).stop;
Pbindef(\insinuation).play;
Pbindef(\concession).stop;
Pbindef('dissence', \blipMul, 0.01, \freq, 150);
Pbindef(\dissence, \rsch2, 0.9, \rls, 6, \legato, 2, \blipMul, Pn(Pseries(0.08, 0.05, 16), inf));
Pbindef(\dissence, \atk, Pn(Pseries(0.04, 0.02, 8), inf), \rls, 4);
Pbindef(\insinuation, \sus, 0.7 );
(
Pbindef('concession').clear;
Pbindef('praise').clear;
Pbindef('lecture').clear;
Pbindef('dissence').clear;
Pbindef('insinuation').clear;

)


// clock

(
t = TempoClock.new(108, 60);
~postBeats = {t.beats.postln; 1};
// t.schedAbs(t.nextBar, {~postBeats.value});
)
//case functions

(
// die erste Message?


(
~setSynth = {
	|s_name, count|
	var c;
	postf("\ncat in setSynth %\t count %\n", s_name, count);
	// postf("\ncount in setSynth %\n", count);
	c = case
	{count == 1} { Pbindef(s_name, \dur, Pn(2, 1), \rls, 4).play;}
	{count == 2 } { Pbindef(s_name, \dur, Pn(2,2), \rls, 3).play;}
	{count == 3 } { Pbindef(s_name, \dur, Pn(2,3),\rls, 2).play;}
	{count >= 4 } { Pbindef(s_name, \dur, Pn(2,count), \rls, count.reciprocal).play;};

	// {count > 3 and count < 6} {Pbindef('dissence', \dur, Pseq([2, 1]), \blipMul, 0.1 + (count.reciprocal)).play;};
	c.postln;

})




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
		~setSynth.value(msg[1], msg[2]);
		// Pbindef(~cat).play;
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




