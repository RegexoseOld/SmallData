/*
Begrüßung: Mic an

Rauschen beginnt+ Feedbacks
Synth insinuation evtl BufRd mit dem text-to-speech engine
Patterns bekommen ~addVolume message
Patterns morphen von der Ausgangsposition in eine deutlich andere Bewegung



Utts > 5, 8: Patterns ctranspose(-2, 2).choose
Utts = 10: Feedback variieren + Patterns randomize

*/

SynthDescLib.global.browse;
ServerOptions.devices;
ServerOptions.inDevices;
~fxGroup = nil
(
Server.default.options.numInputBusChannels_(2);
//Server.default.options.outDevice_("BeatsSolo Wireless");
// Server.default.options.outDevice_("SoundFlower (2ch)");
// Server.default.options.outDevice.postln;
Server.default.options.inDevice_("Fireface 400 (BEF)");

ServerTree.removeAll; // löscht alle funktionen
OSCFunc.trace(false);
s.newBusAllocators; // Busse machen
~fx1Bus = Bus.audio(s,2);
~fx2Bus = Bus.audio(s,2);
~cat = "";
~out = 0;
~totalUtts = 0;
~sharedValues = (
	key: 60,
	tempo: 90/60,
	transpose: 0,
	scale: Scale.major
);
~uttDict = Dictionary.new;
~categories = ['dissence', 'praise', 'insinuation', 'concession', 'lecture'];
~synthDict = Dictionary.new;
~categories.do({arg i;
	~synthDict.add(i -> (synth: List.new, vol: 0.5, patternVol: 0.2));
	~uttDict.add(i -> 0);
});
// wird später in ServerTree angemeldet
~makeNodes = {
	s.bind(
		~fxGroup = Group.new;
		//später: Fx Synth machen und hier instantiieren zB ....
		~reverb = Synth('reverb', [\in, ~fx1Bus], ~fxGroup);
		~delay = Synth('delay', [\in, ~fx2Bus], ~fxGroup);
)};

~fadeIn = {
	|cat, step, max|
	// das geht nicht. braucht ich globale variable fürs volume?
	var vol = ~synthDict[cat][\vol];
	vol.postln;
	if (vol < max, {~synthDict[cat][\vol] = vol* step; vol = vol * step}, {~synthDict[cat][\vol] = max; vol = max});

};

~fadeOut = {
	|cat, step, min|
	// das geht nicht. braucht ich globale variable fürs volume?
	var vol = ~synthDict[cat][\vol];
	vol.postln;
	if (vol > min, {~synthDict[cat][\vol] = vol* step; vol = vol * step}, {~synthDict[cat][\vol] = min; vol = min});

};

~continuousFadeOut = {
	|min, step|
	~categories.do({|cat|
		var vol, c;
		vol = ~synthDict[cat][\patternVol];
		//postf("\nthe vol %  of the pattern   %\n", vol, cat);
		c = case
		{(vol > min) && (Pbindef(cat).isPlaying)} {~synthDict[cat][\patternVol] = vol - step; vol = vol-step} // make sure only playing Patterns are faded
		{(vol <= min) && (Pbindef(cat).isPlaying)} {~synthDict[cat][\patternVol] = min; vol = min}
		{true} {"end of fade Cases"};
		//if (vol > min, {~synthDict[cat][\pattern] = vol - step; vol = vol-step}, {~synthDict[cat][\pattern] = min; vol = min});
		Pbindef(cat, \amp, vol);
	});

};

~addVolume = {
	|cat, add, max|
	if (~synthDict[cat][\patternVol] < max, {~synthDict[cat][\patternVol] = ~synthDict[cat][\patternVol] + add}, {~synthDict[cat][\patternVol] = max};
		postf("new vol of %  is % \n", cat, (~synthDict[cat][\patternVol]) );
	)
};

// wenn gebooted wird, passiert alles folgende, Synthdefs etc
s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	s.sync;
	SynthDef.new(\rauschen, {
		var sig, env;
		env = EnvGen.kr(Env([0, 1, 1, 0], [\atk.kr(1.5), 0.2, \sus.kr(0.2), \rls.kr(2.0)], [1, 0, -2, 3]), doneAction:2);
		sig = BPF.ar(BrownNoise.ar(\mul.kr(0.4)), \ffreq.kr(666), \rq.kr(0.6));
		sig = Pan2.ar(sig * env * \amp.kr(0.1), \pan.kr(0));
		Out.ar(\out.kr(~out), sig);
		Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-30).dbamp);

	}).add;

	SynthDef.new('dissence', {
		|gate=1|
		var sig, gend, env;
		env = EnvGen.kr(Env.adsr(\atk.ir(0.1), releaseTime:\rls.kr(1), curve:\crv.kr(-10)), gate, doneAction:2);
		gend = BPF.ar(Gendy1.ar(\ampDist.kr(1.0), \durDist.kr(1.0), 1.0, 1.0, \minfreq.kr(400), \maxfreq.kr(1000), 0.3, 0.05, 5), \ffreq.kr(300), \rq.kr(0.9)) * \gendAmp.kr(0.3);
		sig = LFPulse.ar(\freq.kr(100).varlag(\lag.kr(0.3), \lagcrv.kr(5.0)), \pPhase.kr(0.0), \width.kr(0.4),\pulseMul.kr(0.15)) + gend ;
		sig = Pan2.ar(sig * env * \amp.kr(0.1), \pan.kr(0.0));
		Out.ar(\out.ir(~out), sig);
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.ir(-30).dbamp);
	}).add;


	SynthDef.new('lecture', {
		|gate = 1|
		var detune, sig, env, mod, ampMod;
		env = EnvGen.kr(Env.adsr(\atk.kr(0.01), 0.2, \sus.kr(0.8), \rls.kr(1.0), curve:\crv.ir(-4.0)), gate, doneAction: 2);
		mod = SinOsc.kr(\modRate.kr(1.2));
		detune = {ExpRand(\det1.kr(0.99), \det2.kr(1.01))}!4;
		sig = VarSaw.ar(\freq.kr(41.2)!4 * detune, 0, LFTri.kr(\filTime.kr(0.3)).range(0,1));
		sig = sig * env * mod;
		sig = Splay.ar(sig * \amp.kr(0.15));
		Out.ar(~out, sig);
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.ir(-30).dbamp);
	}).add;


	SynthDef('insinuation', {
		| gate = 1|
		var  sig, env, lagfrq;
		env = EnvGen.kr(Env([0,1,1,0], [\atk.kr(0.05), \sus.kr(0.5), \rls.kr(0.4)], \linear), gate, doneAction: 2);
		lagfrq = Lag.kr(\freq.kr(220), \slideTime.kr(0.6));
		sig = PMOsc.ar(lagfrq, LFNoise2.ar(\noisFreq.kr(0.1), \maxF.kr(600)), SinOsc.ar(\ffreq.kr(3.0)), pmindex:\modWidth.kr(0.15), mul:\preamp.kr(0.2)) * \amp.kr(0.4)
		* env ;
		sig = FreqShift.ar(sig, \fShift.kr(100))!2;
		Out.ar(~out, sig);
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.kr(-30).dbamp);
	}).add;


	SynthDef('concession', {
		var sig, env;
		sig = PlayBuf.ar(2, \buf.kr(0), \rate.kr(1)*BufRateScale.ir(\buf.kr(0)), \trig.kr(1), \spos.kr(0));
		//die Env muss wohl .ar sein, um bufnums austauschen zu können
		env = Env([0, 1, 1, 0], [\atk.kr(0), 0.2,  \sus.kr(0), \rls.kr(1)], [0, 0, 0]).kr(2);
		sig = LPF.ar(sig, \freq.kr(440));
		sig = sig * env;
		sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.5));
		Out.ar(\out.ir(~out), sig) ;
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.ir(-30).dbamp);
	}).add;


	SynthDef('praise', {
		|gate=1|
		var channels;
		channels = {
		var amp1, freq1, sig1, env1;
		amp1 = LFPulse.kr(\ampHz.kr(0.2), 0, \pulWidth.kr(0.9)) * \ampScale.kr(0.75);
		env1 = EnvGen.kr(Env.adsr(\atk.kr(1.5), 0.2, 0.7, \rls.kr(2.9)), gate, doneAction:2);
		freq1 = LFNoise0.kr(\fRate.kr(0.2)).exprange(\freq.kr(120), \freq.kr(120) * \fMul.kr(4)).round(\freq.kr(120) * \rnd.kr(1.0));
		freq1 = freq1 * LFPulse.kr(\pulRate.kr(0.2));
		sig1 = RHPF.ar(Pulse.ar(freq1, \width.kr(0.2)), \ffreq.kr(300),  \rq.kr(1.0)) * amp1 * env1 * \amp.kr(0.2) ;
		sig1 = BPF.ar(sig1, \bpf.kr(120));
		}!2;
		Out.ar(~out, channels);
		Out.ar(\outfx.kr(~fx1Bus), channels * \send.kr(-30).dbamp);
	}).add;

	SynthDef(\mic, {
		var sig, verb;
		sig = SoundIn.ar(1) * \amp.kr(0.3);
		sig = LPF.ar(sig, \ffreq.kr(200));
		Out.ar(0, sig!2);
		Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-40).dbamp);
	}).add;

	SynthDef('reverb', {
		var sig, wet;
		sig = In.ar(\in.ir(~fx1Bus), 2);
		sig = FreeVerb2.ar(sig[0], sig[1], mix:1, room:0.99, damp:0.99);
		sig = LPF.ar(sig, 900);
		Out.ar(\out.ir(~out), sig);
	}).add;

	SynthDef('delay', {
		var sig, wet;
		sig = In.ar(\in.ir(~fx2Bus), 2);
		sig = CombL.ar(sig, \maxdel.kr(0.6), \deltime.kr(0.8), \decayT.kr(3.0),\mul.kr(1.2));
		sig = LPF.ar(sig, 300);
		Out.ar(\out.ir(~out), sig);
	}).add;

	~buffers= Dictionary.new;
	~path = "/Volumes/Macintosh HD 2/projekte/Meinung/Instruments/SuperCollider/percSamples01";
	PathName(~path).entries.do({
		arg subfolder;
		~buffers.add(
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
	s.options.numOutputBusChannels = 6;
	s.sync;
	t = TempoClock.new(90/60).permanent_(true);

	/// Osc Section
	// n = NetAddr("127.0.0.1", NetAddr.langPort); // local machine
	n = NetAddr("127.0.0.1", 57120); // local machine
	m = NetAddr("127.0.0.1", 5010); // beat send

	OSCdef.newMatching(
		\interpreter,
		{ arg msg;
			postf("\nnew cat: %", msg[1]);
			postf("\nnew count: %", msg[2]);
			~cat = msg[1];
			~totalUtts = ~totalUtts + 1;
			~uttDict[~cat] = ~uttDict[~cat] + 1;
			postf("\n~uttDict changed %\n", ~uttDict);
			//add volume to incoming cat Pattern
			~addVolume.value(~cat, 0.1, 0.99);
			~allocateSynth.value(msg[1], msg[2]);
			~setGlobal.value(~cat);

		},
		'/interpreter_input'
	);


	// CmdPeriod.add(s.freeAll);
	// https://composerprogrammer.com/teaching/supercollider/sctutorial/Technicalities/05%20Clocks%20and%20Scheduling.html
	// send beat
	t.schedAbs(t.nextTimeOnGrid, { m.sendMsg("/beat", (t.elapsedBeats.floor % 8).asInteger + 120); 1});

	~reset = (
		dissence: (
			instrument: 'dissence',
			scale: Pfunc({~sharedValues[\scale]}),
			degree: Pseq([0, 4, -2], inf),
			ctranspose: Pfunc({~sharedValues[\transpose]}),
			dur: t.tempo*5,
			atk:1.5,
			sus: 0.9,
			rls: 4.5,
			ampDist: 0.5,
			durDist: 1.0,
			minfreq: 400,
			maxfreq: 750,
			ffreq: 300,
			gendAmp: 0.1,
			rq: 0.9,
			pPhase: 0.0,
			width: 0.1,
			pulseMul: 0.2,
			amp: ~synthDict[\dissence][\patternVol],
			pan:0.0,
			sustain: 2.0,
			send: -30,
		),

		lecture: (
			instrument: 'lecture',
			scale: Pfunc({~sharedValues[\scale]}),
			ctranspose: Pfunc({~sharedValues[\transpose]}) -36,
			degree: 0,
			dur: t.tempo * 5,
			atk: 0.1,
			sus: 1.0,
			rls: 1.0,
			crv: -4.0,
			modRate: 1.2,
			det1: 0.99,
			det2: 1.01,
			filTime: 0.3,
			amp: 0.05,
			send: -30,
			sustain: 1.0
		),

		insinuation: (
			instrument: 'insinuation',
			scale: Pfunc({~sharedValues[\scale]}),
			ctranspose: Pfunc({~sharedValues[\transpose]}),
			degree: Pseq([[0,3], [4,9]], inf),
			dur: t.tempo*5,
			atk: 0.05,
			rls: 0.4,
			slideTime: 0.6,
			noisFreq: 0.1,
			maxF: 600,
			ffreq: 3.0,
			modWidth: 0.15,
			preamp: 0.3,
			amp: 0.4,
			fShift: 100,
			send: -30
		),

		concession: (
			instrument: 'concession',
			buf: Prand(~buffers[\tonal], inf),
			dur: t.tempo * 5,
	        rate: Pwhite(0.2, 1.8, inf),
	        pan: Pwhite(-0.5, 0.5, inf),
			lpf: Pseq((220, 270 .. 1270), inf),
	        outfx: ~fx1Bus,
	        send: Pseq((-35, -30 .. -10), inf)
		),

		praise: (
		  	instrument:'praise',
			ampHz: 0.2,
			pulWidth: 0.9,
			ampScale: 0.75,
			atk: 2.2,
			rls: 3.5,
			fRate: 0.2,
			degree: Pseq([[0, 4, 7], [2, 8, 11], [4, 2, 5]], inf),
			fMul: 1,
			rnd: 1.0,
			pulRate: 0.2,
			width: 0.2,
			ffreq: 300,
			rq: 1.0,
			bpf: 120,
			send: -30,
			dur: t.tempo *5,
			sustain: 1.2

		),
	);
	//
	// ~resetSynth = {
	// 	|cat|
	// 	var params;
	// 	params = List.new;
	// 	~reset[cat].keys.do({
	// 		|k|
	// 		params.addAll([k, ~reset[cat][k]])
	// 	});
	// 	Pbindef(\cat, params.asArray);
	// 	//Synth(cat, params.asArray);
	// };
	// // stop a List of Synths (Feedbacksounds)
	// ~stopList = {arg list;
	// 	postf("\nstopped list \t  % ", list);
	// 	list.do{|s| s.set(\gate, 0) };
	// 	list.clear;
	// };

~startAllPatterns = {
//start all Pbindefs with minimal volume and a 10 second delay
Routine.new({
			~categories.scramble.do({
				|cat| Pbindef(cat, *~reset[cat].asPairs).play(t, quant:1); postf("pattern % is playing % \n", cat, Pbindef(cat).isPlaying); 10.wait})
		}).play;
// continuousFadeOut(min, step)
t.schedAbs(t.nextTimeOnGrid, {~continuousFadeOut.value(0.01, 0.005); 1});
};


///basic patterns

Pbindef(\rausch,
	\instrument, \rauschen,
	\dur, t.tempo *5,
	\ffreq, Pseq([666, 150], inf),
	\pan, Pwhite(-1,1, inf),
	\amp, 0.3
);


// set functions
	~setDissence = {
		|s_name, count|
		var c, dura, now, amp;
		amp = ~synthDict[\dissence][\vol];
		postf("\nsetting %\t with count %\n and amp %\n", s_name, count, amp);
		dura = Env.new([1,0], [count], [-2]).asPseg;
		5.do({|i|
			Pbind(\instrument, \dissence,
				\width, Pwhite(0.4, 0.9, 1), \freq, Pxrand([200, (200 + (count + 10))], 1), \amp, amp, \atk, Pn(Pwhite(0.01, 0.05), 1), \rls, Pn(Pwhite(0.02, 0.59), 1), \sustain, 0.15).play});
		c = case
		{(count > 0) && (count <= 5)} {// 1. Feedback Sound
			//Pbindef(\dissence, *~reset[\dissence].asPairs);
			Pbindef(\dissence, \width, Pwhite(0.2, 0.5, inf), \degree, Pseq([0, 4, -2, (3 +count)], inf));

		}
		{(count > 5) && (count <=10)} {
			Pbindef(\dissence, \degree, Pseq([[0, 4], [4, 8], [-2, 2], [count%5, (count%5) +3]], inf), \dur, t.tempo*3, \amp, amp, \rls, (0.15 * count));
		}
		{(count > 10) && (count <=20)} {
			Pbindef(\dissence,
				\degree, Prand([[0, 4, 7], [4, 8, 12], [-2, 2, 6], [count%5, ((count%5) +3), ((count%5) + 5)]], inf),
				\dur, Pwrand([ 0.4, t.tempo *2, t.tempo*3], [0.05, 0.35, 0.6].normalizeSum, inf),
				\amp, amp,
				\rls, 1.5 - (count * 0.02),
				\sustain, Pkey(\rls),
				\atk, Pwhite(0.02, 0.1, inf)
			);
		}
		{(count > 20) && (count <= 30)} {

			Pbindef(\dissence, \degree, Pxrand([
				Pseq([[0, 1, 2], [0, 1, 3, 4], [0, 3, 8]], 1),
				Pseq([[2, 3, 5], [2, 4, 5], [2, 3, 4]], 1),
				Pseq([[7, 9, 10], [7, 8, 9], [7, 11, 13]], 1)],inf),
			\sustain, 0.3,
			\rls, Pwhite(0.05, 1.1, inf),
			\width, Pwhite(0.1, 0.5, inf),
			\amp, amp,
			\dur, Pwrand([0.8, 1.0, 1.5, 1.6, t.tempo], [0.3, 0.1, 0.05, 0.1, 0.4].normalizeSum, inf),
			);
		}
		{count > 30} {

			Pbindef(\dissence,
			\degree, Pseq((24, 22 .. (-12)), inf) ,
			\sustain, 0.3,
			\rls, Pwhite(0.05, 1.1, inf),
			\width, Pwhite(0.1, 0.5, inf),
		    \minFreq, Pwhite(100, 600, inf),
			\maxFreq, Pkey(\minFreq) *2,
			\amp, amp,
			\dur, 1
			);
		}
		{true} {"end of dissence reached".postln};
		~addVolume.value(s_name, 0.2, 0.98);

	};

~setInsinuation = {
	|s_name, count|
	var c, dura, now, amp;
	amp = ~synthDict[\insinuation][\vol];
	postf("\nsetting %\t with count %\n", s_name, count);
	//base = ~reset[\insinuation03].value;
	dura = Env.new([1,0], [count], [-2]).asPseg;
	5.do({|i|
		Pbind(\instrument, \insinuation,
			\lfreq, [exprand(100, 120 + i), exprand(200, (200 + i))],\amp, amp/2, \rls, Pn(1, 1)).play});
	c = case
	{(count > 0) && (count <= 5)} {}
	{(count > 5) && (count <= 10)} {}
	{(count > 10) && (count <= 20)} {}
	{(count > 20) && (count <= 30)} {}
	{count < 30} {
			Pbindef(\insinuation, \degree, Pseq([[0, 2, 4], [0, 4, 8], [2, 5, 9]], inf), \strum, Pseq([0.2, 0.4, 0.8], inf));
		}

{true} {"end of insinuation reached".postln};
~addVolume.value(s_name, 0.1, 0.98);

};
~setLecture = {
	|s_name, count|
	var c, dura, factor, amp;
	amp = ~synthDict[\lecture][\vol];
	postf("\nsetting %\t with count %\n", s_name, count);
	dura = Env.new([1,0], [count], [-2]).asPseg;
	factor = count%5;
    5.do({|i| Pbind(\instrument, \lecture,
				\freq, [exprand(80, 90 + i), exprand(160, (160 + i))], \amp, amp/3, \filTime, 0.8, \rls, Pn(1, 1)).play});
	c = case
	{(count > 0) && (count <= 5)} {Pbindef(\lecture, *~reset[\lecture].asPairs);
			Pbindef(\lecture, \degree, Pseq([Pn(0, 3), 12], inf));
		}
	{(count > 5) && (count <= 10)} {
			Pbindef(\lecture, \filTime, 0.3 + ((count -5) * 0.08), \degree, Pseq([Pn(0, 3), 12], inf));
		}
	{(count > 10) && (count <= 20)} {
			Pbindef(\lecture, \filTime, Pwhite(0.3, 0.65, inf), \modRate, 1.2 + ((count-10) * 0.1));
		}
	{(count > 20) && (count <= 30)} {
		Pbindef(\lecture, \sustain, 0.3, \rls, 1.0 - ((count-20) * 0.03), \degree, Pseq([Pn(12, 3), 10], inf), \dur, 2);
		}
	{count > 30} {
			Pbindef(\lecture, \ctranspose, 4);
		}
	{true} {"end of lecture reached".postln;};
	~addVolume.value(s_name, 0.1, 0.98);
	};
~setConcession = {
	|s_name, count|
	var c, dura, amp;
	amp = ~synthDict[\concession][\vol];
	postf("\nsetting %\t with count %\n", s_name, count);
	dura = Env.new([1,0], [count], [-2]).asPseg;
	c = case
	{count < 30} {
		Pbind(\instrument, \concession, \buf, Pxrand(~buffers[\tonal], 10), \dur, 0.1, \amp, amp * dura).play(t)}
	{ (count >= 30) && (count.odd) } {
		Pbind(\instrument, \concession, \buf, ~buffers[\tonal][9], \dur, Pseq((0.8,0.78 ..0.04), 1) /2, \rate, Pseries(1.3, 0.15, count), \send, Pseq((-30, -28 .. -20).mirror,inf), \amp, 0.7).play(t);
		~addVolume.value(s_name, 0.15, 0.98);
	}
	{true} {"end of insinuation reached".postln};

};
	~setPraise = {
		|s_name, count|
		var c, pat, dura, amp;
		postf("\nsetting %\t with count %\n", s_name, count);
		amp = ~synthDict[\praise][\vol];
		dura = Env.new([1,0], [count], [-2]).asPseg;
		5.do({|i|
			Pbind(\instrument, \praise,
				\freq, Pxrand([Pwhite(120, 240, 1), Pwhite(240, 480, 1)], 1), \amp, amp, \pulRate, 20, \bpf, 500, \rls, Pn(0.3, 1), \sustain, 0.3).play});
		c = case
		{(count > 0) && (count <= 5)} {
			Pbindef(\praise, *~reset[\praise].asPairs);
		}
		{(count > 5) && (count <= 10)} {
			Pbindef(\praise, \degree, Pseq([[0, 4, 7], [2, 8, 11], [4, 2, 5]], inf), \dur, t.tempo * (5.5 - count%5));
		}
		{(count > 10) && (count <= 20)} {
			Pbindef(\praise, \degree, Pseq([Pseq([-12, -10, -4, 0], 1), Pseq([[-12, -7], [-10, -10], [-4, -12], [0, 5]],1)], inf), \amp, amp,
				\ampHz, 1,
				\fRate, Pwrand([0.2, 4, 6], [0.8, 0.15, 0.05], inf),
				\pulRate, Pkey(\fRate) / 4,
				\dur, t.tempo *2

			);
		}
			{(count > 20) && (count <= 30)} {
			Pbindef(\praise,
				\degree, -12,
				\ampHz, Pwhite(2, 8, inf),
				\fRate, 3,
				\pulRate, Prand([ 2, 4, 8], inf),
				\fMul, Prand([1, 3.8, 4, 6.3], inf),
				\rnd, 1.0,
				\sustain, 0.2,
				\atk, 0.1,
				\rls, 0.23,
				\dur, t.tempo / 2
			);
		}
		{true} {"end of insinuation reached".postln;};
		~addVolume.value(s_name, 0.1, 0.98);

	};
~setRauschen = {
	|count|
	var c, dura, now;
	postf("\nsetting rauschen with count %\t", count);
	dura = Env.new([1,0], [count], [-2]).asPseg;
	c = case
	{(count > 1) && (count <= 10)}{Pbindef(\rausch, \ffreq, Pxrand([exprand(300, 666), 150], inf), \rq, Pxrand((0.05, 0.1 .. 2.0), inf), \rls, 0.3).trace;}
	{true} {"end of rauschen cases".postln};
};

~allocateSynth ={
	|s_name, count|
	var c;
	postf("\nallocating to Synth %\t as %   with count %\n", s_name, s_name.class, count);
	postf("\ntotalUtts %\t", ~totalUtts);
	c = case
	{s_name == \lecture} {~setLecture.value(s_name, count);}
	{s_name == \praise} {~setPraise.value(s_name, count)}
	{s_name == \dissence} {~setDissence.value(s_name, count)}
	{s_name == \concession} {~setConcession.value(s_name, count)}
	{s_name == \insinuation} {~setInsinuation.value(s_name, count)}
	{true}{"end of allocation".postln};
	c.postln;
	// ~setCommon.value(~commonNow, count)

};
	~setGlobal = {
		|s_name|
		var c;
		postf("\nglobal settings  %\t ", s_name);
		c = case
		/*{~totalUtts >= 30} {Scale.choose}
		{~totalUtts % 5 ==0} {Scale.choose}*/
		{~totalUtts >=20} {~sharedValues[\transpose] = -3}
		{~totalUtts >=15} {~sharedValues[\transpose] = 0}
		{~totalUtts >=10} { ~startAllPatterns.()}
		{~totalUtts >=5} {Pbindef(\rausch).play(t, quant:1); ~mic.set(\send, -15);}
		{~totalUtts > 0 } {~mic.set(\send, (-35 + (~totalUtts * 6)));  }
		{true} {"end of global settings".postln};

	};

	s.sync;
	"done".postln;
}
);
)


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/* Das Soundwesen


*/
///start////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//activate Mic
~mic = Synth(\mic, [\amp, 0.5, \ffreq, 500]);


(
// stop all patterns
~categories.do({|cat| Pbindef(cat).stop})
)
	OSCFunc.trace(true);


/// reset ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

currentEnvironment
// tests
~buffers[\bd][0].play;
// http://sc3howto.blogspot.com/2010/06/pfunc.html  beispiel für ein Fade
3.do({|item, i| Pbind(\instrument, \insinuation, \amp, 0.4, \lfreq, [exprand(100, (200 + (item * 5))), 50], \rls, Pn(3, 1)).play});
~setGlobal.("praise")
~totalUtts =5

(
var test;
test = ExpRand(40, 320).round(20);
~addVolume.value(\insinuation, 0.1, 0.98);
~addVolume.value(\praise, 0.1, 0.98);
~addVolume.value(\dissence, 0.1, 0.98);
~addVolume.value(\concession, 0.1, 0.98);
~addVolume.value(\lecture, 0.1, 0.98);

)
(
~pr = Pbindef(\praise, \dur, 2, \atk, 0.05);
~pr.play(t, quant:4);
Pbindef(\praise).isPlaying;
~dis = Pbindef(\dissence, \dur, 2, \atk, 0.05);
~dis.play(t, quant:4);
~dis.stop;
Pbindef(\dissence).isPlaying
~lec = Pbindef(\lecture, \dur, 2, \atk, 0.05);
~lec.play(t, quant:4)
~lec.stop
)
(
Pbindef(\praise).stop;
Pbindef(\praise, *~reset[\praise].asPairs).play(t, quant:20);
Pbindef(\praise, \dur, 2, \atk, 0.05);
Pbindef(\praise).isPlaying;
Pbindef(\dissence, *~reset[\dissence].asPairs).play(t, quant:20);
Pbindef(\dissence, \dur, 2, \atk, 0.05);
Pbindef(\dissence).stop;
Pbindef(\dissence).isPlaying
Pbindef(\lecture, *~reset[\lecture].asPairs).play(t, quant:20)
Pbindef(\lecture, \dur, 2, \atk, 0.05, \amp, 0.2)
Pbindef(\lecture).play
Pbindef(\lecture).clear
Pbindef(\insinuation, *~reset[\insinuation].asPairs).play(t, quant:4);
Pbindef(\insinuation).isPlaying;
Pbindef(\insinuation).stop
Pbindef(\concession).play(t, quant:1);
Pbindef(\concession).stop

Pbindef(\insinuation).play(t, quant:4);
Pbindef(\praise).play(t, quant:4);
Pbindef(\dissence).play(t, quant:4);
Pbindef(\lecture).play(t, quant:4);
Pbindef(\insinuation).play(t, quant:4);
)

(
~synthDict['dissence']
Pbindef(\concession).stop;
Pbindef(\rausch).play;
Pbindef(\rausch).stop;
~setDissence.value('dissence', 31);
~setInsinuation.value('insinuation',31);
~setLecture.value('lecture', 30);
~setConcession.value('concession', 3);
~setPraise.value('praise', 10);
)
Synth(\rauschen, [\ffreq, 1500])
~stopList.value(~synthDict[\dissence][\synth]);
~sharedValues[\transpose] = 12

(
/*
variablen liefern Arrays für Multichannel Expansion (akkorde)
nicht verallgemeinbar, wenn gewünscht müssen diese Arrays - besonders die Synth parameter - manuell bestimmt werden
*/
var freq, minfreq, maxfreq, lag;

freq = Array.exprand(8, 400, 600);
minfreq = Array.exprand(8, 200, 500);
maxfreq = Array.rand(8, 601, 800);
lag = Array.rand(8, 0.3, 1.9);


fork {
    [\freq, freq, \minfreq, minfreq, \maxfreq, maxfreq, \amp, 0.2, \lag, \pulseMul, 0.1].flop.do { |args|
        args.postln;
		~disSynth.add(Synth(\dissence, args));
		~disSynth.postln;
        // 1.wait;
    }
};
)