/* ab minute 30
https://www.youtube.com/watch?v=ztVLMS15n1c&t=1585s
*/
SynthDescLib.global.browse;
ServerOptions.inDevice_(0);
~fxGroup = nil
(
Server.default.options.numInputBusChannels_(0);
//Server.default.options.outDevice_("BeatsSolo Wireless");
// Server.default.options.inDevice_("Built-in Microph");
// löscht alle funktionen
ServerTree.removeAll;
s.newBusAllocators; // Busse machen
~fx1Bus = Bus.audio(s,2);
~cat = "";
~out = 0;

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

	SynthDef.new(\rauschen, {
		var sig, env;
		env = Env([0, 1, 1, 0], [\atk.kr(1.5), \dec.kr(0.3), \sus.kr(0.5), \rls.kr(1.5)], [-2, 0, 2, 1]).ar(2);
		sig = BPF.ar(BrownNoise.ar(\mul.kr(0.4)), \ffreq.kr(666), \rq.kr(0.6));
		sig = sig * env * \amp.kr(0.2);
		Out.ar(\out.kr(~out), sig!2);
		Out.ar(\outfx.kr(~fxBus), sig + \send.kr(-30).dbamp);

	}).add;

	SynthDef.new('dissence', {
		var sig, gend, env;
		env = Env([0, 1, 1, 0], [\atk.ir(0.1), \sus.ir(0.2), \rls.ir(0.5)], \lin).ar(2);
		gend = BPF.ar(Gendy1.ar(1, 1, 1.0, 1.0, \minfreq.kr(600), \maxfreq.kr(1000), 0.3, \gendmul.kr(0.05), 5), \ffreq.kr(300), \rq.kr(0.9));
		sig = LFSaw.ar(\freq.kr(400), 0.0, \sawMul.kr(0.3)) + gend;
		sig = sig * env * \amp.ir(0.6);
		Out.ar(\out.ir(~out), sig!2);
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.ir(-30).dbamp);
	}).add;

	SynthDef.new('insinuation', {
		|atk=1.5, sus=0.8, rls=1, gate=1|
		var temp, sig, env, mod, ampMod;
		env = EnvGen.kr(Env.adsr(atk, 0.8, sus, rls, curve:\crv.ir(-4.0)), gate, doneAction: 2);
		mod = SinOsc.kr(\modRate.ir(50));
		ampMod = Saw.kr({ExpRand(\ampMod1.ir(0.01), \ampMod2.ir(1.0))}).range(0, 2);
		sig = PMOsc.ar({Rand(\freq.ir(100), \maxF.ir(200))}!4, LFNoise0.kr(\modRate.ir(50))!4, pmindex:\pmindx.ir(pi));
		sig = sig * ampMod * env * mod;
		sig = Splay.ar(sig * \amp.ir(0.4));
		Out.ar(~out, sig);
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.ir(-30).dbamp);
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
		Out.ar(~out, sig ! 2);
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.ir(-30).dbamp);
	}).add;


	SynthDef('concession', {
		var sig, env;
		sig = PlayBuf.ar(2, \buf.ir(0), \rate.ir(1)*BufRateScale.ir(\buf.ir(0)), \trig.kr(1), \spos.ir(0));
		//die Env muss wohl .ar sein, um bufnums austauschen zu können
		env = Env([0, 1, 1, 0], [\atk.ir(0), 0.2,  \sus.ir(0), \rls.ir(1)], [0, 0, 0]).kr(2);
		sig = LPF.ar(sig, \freq.ir(440), \bpfmix.ir(0)*2-1);
		sig = sig * env;
		sig = Pan2.ar(sig, \pan.ir(0), \amp.ir(0.5));
		Out.ar(\out.ir(~out), sig) ;
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.ir(-30).dbamp);
	}).add;


	SynthDef('praise', {
		|ampHz=4, ampScale=0.01, pulWidth= 0.12, pulRate=4, freq=40, fMul=80, rnd=1, fRate= 4, width=0.4, gate=1, atk=0.5, rls=0.9, gain=0.3,
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
		Out.ar(~out, sig1);
		Out.ar(~out +1, sig2);
		Out.ar(\outfx.ir(~fx1Bus), [sig1, sig2] * \send.ir(-30).dbamp);
	}).add;

	SynthDef('reverb', {
		var sig, wet;
		sig = In.ar(\in.ir(~fx1Bus), 2);
		sig = FreeVerb2.ar(sig[0], sig[1], mix:1, room:0.99, damp:0.99);
		sig = LPF.ar(sig, 900);
		Out.ar(\out.ir(~out), sig);
	}).add;

	b= Dictionary.new;
	~path = "/Volumes/Macintosh HD 2/projekte/Meinung/Instruments/SuperCollider/percSamples01";
	PathName(~path).entries.do({
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

	// ~postBeats = {t.beats.postln; 1};
	//t.schedAbs(t.nextBar, {~postBeats.value});
	// Funktionen, die bei jedem cmd-. oder freeAll Aufruf automatisch neu gestartet werden
	ServerTree.add(~makeNodes);
	ServerTree.run;
	Server.default.options.device_("Fireface 400 (BEF)");
	s.options.numOutputBusChannels = 4;
	s.sync;
	/// Osc Section

	n = NetAddr("127.0.0.1", NetAddr.langPort); // local machine

	['dissence', 'praise', 'insinuation', 'concession', 'lecture'].do(
		{
			arg catName;
			OSCdef.new(
				catName.asSymbol,
				{ arg msg, time, addr, recvPort;
					postf("\nnew cat: %", msg[1]);
					postf("\nnew count: %", msg[2]);
					~cat = msg[1];
					postf("\n~cat renamed %\n", ~cat);
					~allocateSynth.value(msg[1], msg[2]);
				},
				catName
			);
	});
	t = TempoClock.new(108/60).permanent = true;
	// jetzt kommen theoretisch noch die Patterns hier her


	~reset = Dictionary.new;
	~reset.add(\dissence01 -> {
		Pbind(
			\instrument, 'dissence',
			\dur, Pn(1, 2),
			\freq, 666,
			\ffreq, 300,
			\sawMul, 0.1
		);
	});
	~reset.add(\insinuation02 -> {
		Pbind(
			\instrument, 'insinuation',
			\dur, Pn(1.4, 5),
			\freq, 100,
			\maxF, 400,
			\modRate, 5,
			\gate, 1,
			\atk, 0.01,
			\sus, 0.8,
			\rls, 3,
			\ampMod1, 0.01,
			\ampMod2, 0.3
		);
	});
	~reset.add(\lecture03 -> {
		Pbind(
			\instrument, 'lecture',
			\dur, Pn(2, 5),
			\freq, 100,
			\modWidth, 0.5,
			\rls, 0.4,
			\atk, 0.2,
			\preamp, 2.5,
			\slideTime, pi,
			\ffreq, 10,
			\maxF, 50,
			\detune, 1
		);
	});

	~bdPat = Pbind(\instrument, 'concession', \buf, Pxrand(b[\bd], inf), \dur, 5, \sustain, 0.4, \freq, 100);
	~snPat = Pbind (\instrument, 'concession', \buf, b[\sn][0], \dur, 3, \sustain, 0.4, \freq, 600);
	~dryPat = Pbind(\instrument, 'concession', \buf, b[\dry][0], \dur, 1, \sustain, 0.4, \freq, 440);
	~hhPat = Pbind(\instrument, 'concession', \buf, Pxrand(b[\hh], inf), \dur, 1.5, \sustain, 0.4, \freq, 1200);
	~tonalPat = Pbind(\instrument, 'concession', \buf, Pxrand(b[\tonal], inf), \dur, 4, \sustain, 0.4);

 	~reset.add(\concession04 -> {
		Pbus(Pgpar([~bdPat, ~snPat, ~dryPat, ~hhPat, ~tonalPat]));
	});

	~reset.add(\praise05-> {
		Pbind(
			\instrument, 'praise',
			\dur, Pn(1, 4),
			\ampHz , 0.1,
			\ampScale, 0.03,
			\freq, 70,
			\fMul, 10,
			\pulWidth, 0.24,
			\fRate, 0.5,
			\width, 0.3,
			\gain, 0.6,
			\atk, 3.5,
			\rls, 2,
			\ffreq, 1000,
			\rq, 3,
			\pulWidth, 5,
			\pulRate, 0.1,
		)
	});

	~reset.add(\rauschen-> {
		Pbind(
			\instrument, \rauschen,
			\dur, 8,
			\ffreq, Pseq([666, 150], inf)
			\amp, 0.8
		)
	});

	s.sync;
	"done".postln;
}
);

)


////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////

/* Das Soundwesen
5 SynthDefs die von eingehenden Categories mit passenden messages beliefert werden.
Jede SynthDef wechselt Noten/Akkorde (die alte \advance message), Klangeffekte 8Volume, FX, Modulationen)

Frage: Was ist mit mehreren Instanzen von SynthDefs? Klanglich eben sehr interessant.
Ich brauche globale Patternvariablen, die ich an- und ausschalten kann und verändern, und resetten kann.
*/

// basic patterns
/*
Idee ist es grundpattern zu haben, die mit einkommenden Messages verändert werden
Problem: Wie schaffe ich es, gezielt die richtigen Paramenter der Synths mit den richtigen Werten zu beschicken und zu verändern?
Jeder Synth hat andere Parameter, die bestimmte Werte brauchen.
*/

// test
b[\dry][0].play;

~reset[\dissence01].value.play(t, quant:1)
Synth(\rauschen, [\ffreq, 666])
currentEnvironment

(
g = Pbind(
	\instrument, 'dissence',
	\dur, Pseq([1, 0.5], inf),
	\amp, Pkey(\dur),
	\freq, Pwhite(90, 500, inf),
	\ffreq, Pkey(\freq) * 1.3,
	\minfreq, Pwhite(200, 800, inf),
	\maxfreq, Pkey(\minfreq) + 500,
	\atk, 0.03,
	\rls, 0.2
).play(t, quant:1)
)

(
~rauschenNow = ~reset[\rauschen].value;
~rauschenPlay = ~rauschenNow.play(t, quant:1);
)

(~dissenceNow = ~reset[\dissence01].value;
~dissencePlay = ~dissenceNow.play(t, quant:1);
)

~dissencePlay.stop;
~setDissence.value('dissence', 5);
(
~insinuationNow = ~reset[\insinuation02].value;
~insinuationPlay = ~insinuationNow.play(t, quant:1);
)
~insinuationPlay.stop
~setInsinuation.value('insinuation', 4);
(
~lectureNow = ~reset[\lecture03].value;
~lecturePlay = ~lectureNow.play(t, quant:1);
)
~setLecture.value('lecture', 4)
(
~concessionNow = ~reset[\concession04].value;
~concessionPlay = ~concessionNow.play(t, quant:1);
)
~setConcession.value('concession', 8);
(
~praiseNow = ~reset[\praise05].value;
~praisePlay = ~praiseNow.play(t, quant:1);
)
~setPraise.value('praise', 4);



d = nil;
~dissenceNow.isPlaying;
d = ~dissenceNow.asStream;
d.next(());

~setLecture.value('lecture', 1);

/// set functions
(
~setDissence = {
	/*
man kann ~dissenceNow nicht einfach so mit Pbindf ersetzen.
	Ich habe es mit der variable "now" versucht, aber auch die lässt sich nicht richtig wieder in ~dissenceNow zurückverwandeln.
	Der Parameter \dur kann nur mit Proxies oder Pdefn verändert werden.
*/
	|s_name, count|
	var c, dura;
	postf("\nsetting %\t with count %\n", s_name, count);
	postf("\ndissence runnung %\t \n", ~dissencePlay.isPlaying);
	// wie regeln man diese Pdefn?
	//muss man zwischen Pdefs und Pbindf usw switschen???
	dura = Env.new([1,0], [count], [-2]).asPseg;
	c = case
	{(count > 0) && (count < 5)} {
		~dissenceNow = Pbind(\instrument, \dissence, \freq, Pwhite(600, 666, inf), \sawMul, 0.3, \amp, 0.2 * dura, \ffreq, 1000)}
	{(count >= 5) && (count < 10) } {
		postf("\nsetting %\t", count);
		~dissenceNow = Pbindf(~dissenceNow, \dur, 0.33, \atk, 0.02, \rls, Pwhite(0.1, 0.2, inf), \amp, 0.25 * dura, \send, -25.dbamp)}
	{true} {"end of dissence reached".postln};
	if(~dissencePlay.isPlaying, {~dissencePlay.stop});
	postf("\ndissence running after %\t \n", ~dissenceNow.isPlaying);
	~dissencePlay = ~dissenceNow.play(t, quant:1);

};

~setInsinuation = {
	|s_name, count|
	var c, dura;
	postf("\nsetting %\t with count %\n", s_name, count);
	postf("\n% runnung %\t \n", s_name, ~insinuationPlay.isPlaying);
	dura = Env.new([1,0], [count], [-2]).asPseg;
	c = case
	{(count > 0) && (count < 3)} {
		~insinuationNow = Pbind(\instrument, \insinuation, \dur, Pn(1, 10))}
	{(count >= 3) && (count < 5) } {
		~insinuationNow = Pbind(\instrument, \insinuation, \dur, Pseq([3.0, 4.0], 5), \rls, Pkey(\dur, 5) * 0.9, \atk, Pseq([0.1, 0.7], 5)).trace}
	{true} {"end of insinuation reached".postln};
	if(~insinuationPlay.isPlaying, {~insinuationPlay.stop});
	postf("\n% running after %\t \n", s_name, ~insinuationNow.isPlaying);
	~insinuationPlay = ~insinuationNow.play(t, quant:1);

};
~setLecture = {
	|s_name, count|
	var c, dura;
	postf("\nsetting %\t with count %\n", s_name, count);
	postf("\n% runnung %\t \n", s_name, ~lecturePlay.isPlaying);
	dura = Env.new([1,0], [count], [-2]).asPseg;
	c = case
	{(count > 0) && (count < 3)} {
		~lectureNow = Pbind(\instrument, \lecture, \dur, Pn(1, 10))}
	{(count >= 3) && (count < 5) } {
		~lectureNow = Pbind(\instrument, \lecture, \dur, Pseq([3.0, 4.0], 5), \rls, Pkey(\dur, 5) * 0.9, \atk, Pseq([0.1, 0.7], 5)).trace}
	{true} {"end of insinuation reached".postln;};
	if(~lecturePlay.isPlaying, {~lecturePlay.stop});
	postf("\n% running after %\t \n", s_name, ~ilectureNow.isPlaying);
	~lecturePlay = ~lectureNow.play(t, quant:1);

};
~setConcession = {
	|s_name, count|
	var c, dura;
	postf("\nsetting %\t with count %\n", s_name, count);
	postf("\n% runnung %\t \n", s_name, ~concessionPlay.isPlaying);
	dura = Env.new([1,0], [count], [-2]).asPseg;
	c = case
	{(count > 0) && (count < 5)} {
		~tonalPat = Pbind(\instrument, \concession, \buf, Pxrand(b[\tonal], inf), \dur, Pwhite(0.1, 0.3, inf), \amp, 0.5 * dura);
		~concessionNow = Pbus(Pgpar([~tonalPat]))}
	{(count >= 5) && (count < 10) } {
	~hhPat = Pbind(\instrument, \concession, \buf, b[\hh][0], \dur, 0.5, \pan, Pwhite([-1,0, 1], count), \amp, Pwhite(0.05, 0.1, inf) * dura, \freq, Pseq([Array.series(8, 1000, -50)], count));
		~dryPat = Pbind(\instrument, \concession, \dur,  Pwhite(0.1, 0.3, inf), \amp, 0.5 * dura);
		~tonalPat = Pbind(\instrument, \concession, \dur, 2, \rls, 0.2, \freq, Pxrand([333, 555, 777], inf), \amp, 0.5 * dura, \send, -15);
		~concessionNow = Pbus(Pgpar([~dryPat, ~hhPat, ~tonalPat]))}
	{true} {"end of insinuation reached".postln;};
	if(~concessionPlay.isPlaying, {~concessionPlay.stop});
	postf("\n% running after %\t \n", s_name, ~concessionNow.isPlaying);
	~concessionPlay =  ~concessionNow.play(t, quant:1);

};
~setPraise = {
	|s_name, count|
	var c, dura;
	postf("\nsetting %\t with count %\n", s_name, count);
	postf("\n% runnung %\t \n", s_name, ~praisePlay.isPlaying);
	dura = Env.new([1,0], [count], [-2]).asPseg;
	c = case
	{(count > 0) && (count < 5)} {
		~praiseNow = Pbind(\instrument, \praise, \dur, Pn(1, 10), \gain, 0.2 * dura)}
	{(count >= 5) && (count < 10) } {
		~praiseNow = Pbind(\instrument, \praise, \dur, Pseq([3.0, 4.0], 5), \rls, Pkey(\dur, 5) * 0.9, \atk, Pseq([0.1, 0.7], 5), \gain, 0.2* dura).trace}
	{true} {"end of insinuation reached".postln;};
	if(~praisePlay.isPlaying, {~praisePlay.stop});
	postf("\n% running after %\t \n", s_name, ~ilectureNow.isPlaying);
	~praisePlay = ~praiseNow.play(t, quant:1);
};

~allocateSynth = {
	|s_name, count|
	var c;
	postf("\nallocating to Synth %\t as %   with count %\n", s_name, s_name.class, count);
	c = case
	{s_name == \lecture} {~setLecture.value(s_name, count)}
	{s_name == \praise} {~setPraise.value(s_name, count)}
	{s_name == \dissence} {~setDissence.value(s_name, count)}
	{s_name == \concession} {~setConcession.value(s_name, count)}
	{s_name == \insinuation} {~setInsinuation.value(s_name, count)}
	{true}{"end of allocation".postln};
	c.postln;

};

)


// set Functions section
// diese Funktionen wandeln eingehende Signale in Patterns für die SynthDefs um
// siehe Pattern Guide Cookbook
/* glissando
    var porta = 400;
    Pdefn(\dur01, Pn(1, inf));
	Pdefn(\freq01, Pfunc({porta}));
	Pdefn(\blipMul01, 0.01);
	\freqRamp, Pseq([100, -30, -100, 30], inf),
	\freq, Pdefn(\freq01),
	\freqEnd, Pfunc({|ev| var next;
			next = porta + ev[\freqRamp]; porta = next;}))}
*/



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




