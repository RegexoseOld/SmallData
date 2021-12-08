/* ab minute 30
https://www.youtube.com/watch?v=ztVLMS15n1c&t=1585s
*/
(
// löscht alle funktionen
ServerTree.removeAll;
s.newBusAllocators; // Busse machen
~fx1Bus = Bus.audio(s,2);

// wird später in ServerTree angemeldet
~makeNodes = {
	s.bind(
		~fxGroup = Group.new;
	//später: Fx Synth machen und hier instantiieren zB ....
		~reverb = Synth('reverb', [\in, ~fx1Bus], ~fxGroup);

	)};
// wenn gebooted wird, passiert alles folgende, Synthdefs etc
s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	s.sync;

SynthDef.new('dissence', {
	var sig, rausch, env;
	// env = EnvGen.kr(Env.adsr(\atk.ir(0.1), 0.2, \sus.ir(0.2), \rls.ir(1.0)), \gate.ir(1), doneAction:2);
    env = Env([0, 1, 1, 0], [\atk.ir(0), \sus.ir(0), \rls.ir(1)], \lin).ar(2);
	rausch = BrownNoise.ar(LFNoise1.kr(\rsch1.ir(0.5), \rsch2.ir(0.5)));
	sig = Blip.ar(\freq.ir(10), \num.ir(2), \blipMul.ir(0.5)) + rausch;
	sig = sig * env * \amp.ir(0.4);
	Out.ar(\out.ir(0), sig!2);
	Out.ar(\outfx.ir(0), sig * \send.ir(-30).dbamp);
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
	Out.ar(\outfx.ir(0), sig * \send.ir(-30).dbamp);
}).add;


SynthDef('lecture', {
	|freq = 220, gate = 1, slideTime = 0.1, maxF = 1100, modWidth = 0.15,
        detune = 1.005, preamp = 1, atk=0.5, rls= 0.1, ffreq = 3|
    var  sig, env, frq;
    env = EnvGen.kr(Env.adsr(atk, 0.3, 0.7, rls), gate, doneAction: 2) ;
    frq = Lag.kr(freq, slideTime);
    sig = PMOsc.ar( frq * detune, LFNoise2.ar(slideTime, maxF), SinOsc.ar(ffreq), pmindex:modWidth, mul:preamp) * \amp.ir(0.6)
        * env ;
	sig = FreqShift.ar(sig, maxF);
    Out.ar(0, sig ! 2);
	Out.ar(\outfx.ir(0), sig * \send.ir(-30).dbamp);
}).add;


SynthDef('concession', {
	var sig, env;
	sig = PlayBuf.ar(2, \buf.ir(0), \rate.ir(1)*BufRateScale.ir(\buf.ir(0)), 1, \spos.ir(0));
	//die Env muss wohl .ar sein, um bufnums austauschen zu können
	env = Env([0, 1, 1, 0], [\atk.ir(0), \sus.ir(0), \rls.ir(1)], \lin).ar(2);
	sig = XFade2.ar(sig, BPF.ar(sig, \freq.ir(440), \rq.ir(1), 1/\rq.ir(1).sqrt), \bpfmix.ir(0)*2-1);
	sig = sig * env;
	sig = Pan2.ar(sig, \pan.ir(0), \amp.ir(0.5));
	Out.ar(\out.ir(0), sig);
	Out.ar(\outfx.ir(0), sig * \send.ir(-30).dbamp);
}).add;


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
	Out.ar(\outfx.ir(0), [sig1, sig2] * \send.ir(-30).dbamp);
}).add;

SynthDef('reverb', {
		var sig, wet;
		sig = In.ar(\in.ir(0), 2);
		sig = FreeVerb2. ar(sig[0], sig[1], mix:1, room:0.99, damp:0.99);
		sig = LPF.ar(sig, 900);
		Out.ar(\out.ir(0), sig);
	}).add;

b= Dictionary.new;
PathName("/Volumes/Macintosh HD 2/projekte/Meinung/Instruments/SuperCollider/percSamples01/").entries.do({
	arg subfolder;
	b.add(
		subfolder.folderName.asSymbol ->
		Array.fill(
			subfolder.entries.size,
			{
				arg i;
				Buffer.read(s, subfolder.entries[i].fullPath);
			}
		)
	)
});
    //Server wartet, bis dieser Block fertig ist
	s.sync;
	// Funktionen, die bei jedem cmd-. oder freeAll Aufruf automatisch neu gestartet werden
	ServerTree.add(~makeNodes);
	ServerTree.run;
	s.sync;
	// jetzt kommen theoretisch noch die Patterns hier her
}
);
)

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
(
ServerOptions.devices;
Server.default.options.device_("Fireface 400 (BEF)");
s.options.numAudioBusChannels;
s.options.numOutputBusChannels = 4;
s.reboot;

)
/* Das Soundwesen
5 SynthDefs die von eingehenden Categories mit passenden messages beliefert werden.
Jede SynthDef wechselt Noten/Akkorde (die alte \advance message), Klangeffekte 8Volume, FX, Modulationen)

Frage: Was ist mit mehreren Instanzen von SynthDefs? Klanglich eben sehr interessant.
Lassen die sich dann noch steuern? In welchen Container kann man sie speichern?
*/

// basic patterns
/*
Idee ist es grundpattern zu haben, die mit einkommenden Messages verändert werden
Problem: Wie schaffe ich es, gezielt die richtigen Paramenter der Synths mit den richtigen Werten zu beschicken und zu verändern?
Jeder Synth hat andere Parameter, die bestimmte Werte brauchen.
*/


(

~resetDissence = Pbindef(\dissence,
	\instrument, 'dissence',
	\dur, Pn(3, 2),
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
);

~resetInsinuation = Pbindef(\insinuation,
	\instrument, 'insinuation',
	\dur, Pn(10, 2),
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
);

~resetLecture = Pbindef(\lecture,
	\instrument, 'lecture',
	\dur, Pn(2, 5),
	\freq, 50,
	\modWidth, 0.5,
	\rls, 0.4,
	\atk, 0.2,
	\preamp, 2.5,
	\slideTime, pi,
	\ffreq, 10,
	\maxF, 50,
	\detune, 1
);



/*~resetConcession = {
	~bdPat = Pbindef(\bd, \instrument, 'concession', \type, \note, \buf, Prand([b[\bd]], inf), \rate, Pwhite(-12, 12, inf).midiratio, \pan, Pwhite([-1,0, 1], inf));
	~snPat = Pbindef (\sn, \instrument, 'concession', \type, \note, \buf, Prand([b[\sn]], inf), \rate, Pwhite(-12, 12, inf).midiratio, \pan, Pwhite([-1,0, 1], inf));
	~miscPat = Pbindef(\misc, \instrument, 'concession', \type, \note, \buf, Prand([b[\misc]], inf ), \rate, Pwhite(-12, 12, inf).midiratio, \pan, Pwhite([-1,0, 1], inf));

	~playConcession = Ptpar([0.0, ~bdPat, 0.0, ~snPat, 0.0, ~miscPat]);

};*/
~resetConcession = Ptpar(
	[
		0.0, Pbindef(\bd, \instrument, 'concession', \type, \note, \buf, Prand([b[\bd]], inf), \rate, Pwhite(-12, 12, inf).midiratio, \pan, Pwhite([-1,0, 1], inf)),
		0.0, 	Pbindef (\sn, \instrument, 'concession', \type, \note, \buf, Prand([b[\sn]], inf), \rate, Pwhite(-12, 12, inf).midiratio, \pan, Pwhite([-1,0, 1], inf)),
		0.0, 	Pbindef(\misc, \instrument, 'concession', \type, \note, \buf, Prand([b[\misc]], inf ), \rate, Pwhite(-12, 12, inf).midiratio, \pan, Pwhite([-1,0, 1], inf));
	]
);


~resetPraise =  Pbindef(\praise,
	\instrument, 'praise',
	\dur, Pn(5, 3),
	\ampHz , 0.3,
	\ampScale, 0.03,
	\freq, 70,
	\fMul, 10,
	\pulWidth, 0.24,
	\fRate, 0.5,
	\width, 0.3,
	\gain, 0.6,
	\atk, 3.5,
	\rls, 3.5,
	\ffreq, 1000,
	\rq, 3,
	\pulWidth, 5,
	\pulRate, 0.1,
	\gain, 0.3
);

)

Pbindef(\bd, \instrument, 'concession', \type, \note, \buf, Prand([b[\bd]], inf), \rate, Pwhite(-12, 12, inf).midiratio, \pan, Pwhite([-1,0, 1], inf)).play;


(
~resetConcession.value;
~resetDissence.value;
~resetInsinuation.value;
~resetPraise.value;
~resetLecture.value;)

Pbindef(\bd).play(quant:1);
Pbindef(\sn).play(quant:1);
Pbindef(\misc).play(quant:1);
~perc.set(\dur, 0.25);
Pbindef(\misc, \outfx, ~fx1Bus, \send, -10);
~playPraise = ~resetPraise.play(quant:1);
~setPraise = Pbindef(\praise, \dur, Pn(5, inf), \atk, 3.5, \rls, 3.5, \fRate, 0.5);
~setPraise = Pbindef(\praise, \pulWidth, 0.8, \ampScale, 0.7, \fRate, 4, \freq, 175, \outfx, ~fx1Bus, \send, Pwhite(-35, 0, inf), \atk, 0.04, \rls, 0.3, \width, Pwhite(0.05, 0.6, inf));
~playLecture = ~resetLecture.play(quant:1);
~setLecture = Pbindef(\lecture, \freq, 50, \preamp, 3, \modWidth, 0.4);

~playInsinuation = ~resetInsinuation.play(quant:1);
~setLecture = Pbindef(\lecture);


~playDissence = ~resetDissence.play(quant:1);
~setDissence = Pbindef(\dissence, \dur, Pn(2, 4));
~playDissence.stop;

~playConcession.play(quant:1);
Pbindef(\misc, \dur, Pn(1, 4), \outfx, ~fx1Bus, \send, -3);
Pbindef(\sn, \dur, Pn(1, 4), \outfx, ~fx1Bus, \send, -40);
Pbindef(\bd, \dur, Pn(1, 4));

// clock

(
t = TempoClock.new(108, 60);
~postBeats = {t.beats.postln; 1};
// t.schedAbs(t.nextBar, {~postBeats.value});
)


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

(
~setBasicDuration = {
	arg dur;
	[\dissence, \praise, \insinuation, \concession, \lecture].do(
	{arg item;
		Pbindef(item, \dur, dur);
});
};
)


