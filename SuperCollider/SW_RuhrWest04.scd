/*
So Simpel wie möglich, damit die Änderungen an der Musik erfasst werden können. Stumpf statt subtil, weil man sonst einfach keine Chance hat, die Entwicklung zu erkennen.

Begrüßung: Mic an

Rauschen beginnt+ Feedbacks
Synth insinuation evtl BufRd mit dem text-to-speech engine
Patterns bekommen ~addVolume message
Patterns verdünnen oder verdicken sich, werden schneller/langsamer, bekommen Effekte



Utts > 5, 8: Patterns ctranspose(-2, 2).choose
Utts = 10: Feedback variieren + Patterns randomize

*/

SynthDescLib.global.browse;
ServerOptions.devices;
ServerOptions.inDevices;
ServerOptions.outDevices;
~fxGroup = nil
(
Server.default.options.numInputBusChannels_(2);
//Server.default.options.outDevice_("BeatsSolo Wireless");
s.options.sampleRate;
s.options.sampleRate = 48000;
Server.default.options.inDevice_("Fireface 400 (BEF)");
//Server.default.options.outDevice_("SoundFlower (64ch)");
Server.default.options.outDevice_("Fireface 400 (BEF)");
Server.default.options.outDevice.postln;
// Server.default.options.outDevice.postln;


ServerTree.removeAll; // löscht alle funktionen
OSCFunc.trace(false);
s.newBusAllocators; // Busse machen
~fx1Bus = Bus.audio(s,2);
~fx2Bus = Bus.audio(s,2);
~fx3Bus = Bus.audio(s,2);
~cat = "";
~out = 0;

// wird später in ServerTree angemeldetn
~makeNodes = {
	s.bind(
		~fxGroup = Group.new;
		//später: Fx Synth machen und hier instantiieren zB ....
		~delay = Synth('delay', [\in, ~fx2Bus], ~fxGroup);
		~reverb = Synth('reverb', [\in, ~fx1Bus], ~fxGroup);
		~grain = Synth('grain', [\in, ~fx3Bus], ~fxGroup );

)};

~addVolume = {
	|cat, add, max|
	var c;
	c = case
	{~synthDict[cat][\patternVol] <= 0.1}{~synthDict[cat][\patternVol] = ~synthDict[cat][\patternVol] + (add *2) }
	{(~synthDict[cat][\patternVol] <= max) && (~synthDict[cat][\patternVol] >= 0.1)}{~synthDict[cat][\patternVol] = ~synthDict[cat][\patternVol] + add}
	{~synthDict[cat][\patternVol] >= max}{~synthDict[cat][\patternVol] = max}
	{true}{"end of addVolume".postln};

	postf("new vol of %  is % \n", cat, (~synthDict[cat][\patternVol]) );

};

// wenn gebooted wird, passiert alles folgende, Synthdefs etc
s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	s.sync;
	t = TempoClock.new(80/60).permanent_(true);
	~totalUtts = 0;
	~sharedValues = (
		key: 60,
		tempo: 1,
		transpose: 0,
		scale: Scale.chromatic,
		vol: 0.2
	);
	~uttDict = Dictionary.new;
	~catDict = Dictionary.new;
	['dissent', 'praise', 'insinuation', 'concession', 'lecture'].do({
		|cat|
		var c;
		cat.postln;
		c = case
		{cat=='dissent'}{~catDict.add(cat-> \dis)}
		{cat=='praise'}{~catDict.add(cat-> \pr)}
		{cat=='insinuation'}{~catDict.add(cat-> \ins)}
		{cat=='concession'}{~catDict.add(cat-> \con)}
		{cat=='lecture'}{~catDict.add(cat-> \lec)}
		{true}{"end of catDict".postln};
		 });
	~synthDict = Dictionary.new;
	~patternDict = Dictionary.new;
	~catDict.keys.do({arg cat;
		~uttDict.add(cat -> 0);
	});
	s.sync;
	SynthDef.new(\rauschen, {
		var sig, env;
		env = EnvGen.kr(Env([0, 1, 1, 0], [\atk.kr(1.5), 0.2, \sus.kr(0.2), \rls.kr(2.0)], [1, 0, -2, 3]), doneAction:2);
		sig = BPF.ar(BrownNoise.ar(\mul.kr(0.4)), \ffreq.kr(666), \rq.kr(0.6));
		sig = Pan2.ar(sig * env * \amp.kr(0.1), \pan.kr(0));
		Out.ar(\out.kr(~out), sig);
		Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-30).dbamp);

	}).add;

	SynthDef.new('dissent', {
		|gate=1|
		var sig, gend, env, mod;
		env = EnvGen.kr(Env.adsr(\atk.ir(0.1), releaseTime:\rls.kr(1), curve:\crv.kr(-10)), gate, doneAction:2);
		mod = SinOsc.kr(\modF.kr(1.0));
		gend = BPF.ar(Gendy1.ar(\ampDist.kr(1), \durDist.kr(1), 1.0, 1.0, \minfreq.kr(100), \maxfreq.kr(1000), \gendScale.kr(0.5), 0.05, 5), \ffreq.kr(300), \rq.kr(0.9)) * \gendAmp.kr(0.3);
		sig = LFPulse.ar(\freq.kr(100).varlag(\lag.kr(0.3), \lagcrv.kr(5.0)), 0.0, \width.kr(0.4),\pulseMul.kr(0.15), \add.kr(0)) ;
		sig = RLPF.ar(sig, \resoFreq.kr(900) ) + gend;
		sig = Compander.ar(sig, sig, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(3));
		sig = Pan2.ar(sig * env * (\amp.kr(0.1) * mod), \pan.kr(0.0));
		Out.ar(\out.ir(~out), sig);
		Out.ar(\outfx.kr(~fx1Bus), sig * \send.ir(-30).dbamp);
	}).add;


	SynthDef.new('lecture', {
		|gate = 1|
		var detune, sig, env, mod, ampMod;
		env = EnvGen.kr(Env.adsr(\atk.kr(0.01), 0.2, \sus.kr(0.8), \rls.kr(1.0), curve:\crv.kr(-4.0)), gate, doneAction: 2);
		mod = SinOsc.kr(\modRate.kr(1.2));
		detune = {ExpRand(\det1.kr(0.99), \det2.kr(1.01))}!4;
		sig = VarSaw.ar(\freq.kr(100)!4 * detune, 0, LFTri.kr(\filTime.kr(0.3)));
		sig = (sig * \distort.kr(1.5)).tanh;
		sig = sig * env * mod;
		sig = Compander.ar(sig, sig, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(3));
		sig = Splay.ar(sig * \amp.kr(0.04) * \fade.kr(1));
		Out.ar(~out, sig);
		Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-30).dbamp);
	}).add;


	SynthDef.new(\fmBass, {
		var sig, car, mod, env;
		env = EnvGen.kr(Env.perc(\atk.kr(0.04), \rls.kr(0.2),  \crv.kr(-4.0)), 1, doneAction:2);
		mod = SinOsc.ar(\freq.kr(100)/5,  mul: \modAmp.kr(20));
		car = SinOsc.ar(\freq.kr(100));
		sig = (car + mod) * env * \amp.kr(0.1);
		sig = (sig * \distort.kr(1.5)).tanh;
		sig = sig * \fade.kr(1);
		sig = Splay.ar(sig);
		Out.ar(~out, sig);
		Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-30).dbamp);
	}).add;

	SynthDef('insinuation', {
		| gate = 1|
		var  sig, env, lagfrq;
		env = EnvGen.kr(Env([0,1,1,0], [\atk.kr(0.05), \sus.kr(0.05), \rls.kr(0.4)], [\c1.kr(-2.0), \c2.kr(1), \c3.kr(-4)]), gate, doneAction: 2);
		lagfrq = Lag.kr(\freq.kr(220), \slideTime.kr(0.6));
		sig = PMOsc.ar(lagfrq, LFNoise2.ar(\noisFreq.kr(0.1), \maxF.kr(600)), SinOsc.ar(\ffreq.kr(3.0)), pmindex:\modWidth.kr(0.15), mul:\preamp.kr(0.2)) * \amp.kr(0.2)
		* env ;
		sig = FreqShift.ar(sig, \fShift.kr(100))!2;
		Out.ar(~out, sig * \fade.kr(1));
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.kr(-30).dbamp);
	}).add;
	//Synth(\insinuation, [\slideTime, 1.6, \freq, 300, \c1, -10.0, \sus, 4, \noiseFreq, 5.5, \maxF, 500, \modWidth, 1.3, \ffreq, 20, \fShift, 470])


	SynthDef('concession', {
		var sig, shift, env;
		sig = PlayBuf.ar(2, \buf.kr(0), \rate.kr(1)*BufRateScale.kr(\buf.kr(0)), \trig.kr(1), \spos.kr(0));
		//die Env muss wohl .ar sein, um bufnums austauschen zu können
		env = Env([0, 1, 1, 0], [\atk.kr(0), 0.2,  \sus.kr(0), \rls.kr(1)], [0, 0, 0]).kr(2);
		shift = FreqShift.ar(sig, LFNoise0.kr(\fShift.kr(0.45), 1000), 0, 1 );
		sig = XFade2.ar(sig, shift, \mix.kr(0.0));
		sig = BPF.ar(sig, \bpf.kr(440), \rq.kr(1.0));
		sig = sig * env * \amp.kr(0.2);
		sig = Compander.ar(sig, sig, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(5));
		sig = sig * \fade.kr(1);
		sig = Pan2.ar(sig, \pan.kr(0));
		Out.ar(\out.kr(~out), sig) ;
		Out.ar(\outfx.kr(~fx2Bus), sig * \send.ir(-30).dbamp);
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
			sig1 = RHPF.ar(Pulse.ar(freq1, \width.kr(0.2)), \ffreq.kr(300),  \rq.kr(1.0)) * amp1 * env1 ;
			sig1 = BPF.ar(sig1, \bpf.kr(120));
		}!2 * \amp.kr(0.1) *\fade.kr(0.75);
		Out.ar(~out, channels);
		Out.ar(\outfx.kr(~fx1Bus), channels * \send.kr(-30).dbamp);
	}).add;

	SynthDef(\mic, {
		var sig, verb;
		sig = SoundIn.ar(1) * \amp.kr(0.3);
		sig = LPF.ar(sig, \ffreq.kr(1200));
		sig = Compander.ar(sig, sig, \thr.kr(0.65), 1, 0.3, 0.3, 0.4, \cgain.kr(4));
		Out.ar(~out, sig!2);
		Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-40).dbamp);
	}).add;

	SynthDef('reverb', {
		var sig, wet;
		sig = In.ar(\in.ir(~fx1Bus), 2);
		sig = FreeVerb2.ar(sig[0], sig[1], mix:1, room:\room.kr(0.99), damp:\damp.kr(0.99));
		sig = BPF.ar(sig, SinOsc.kr(\bpf.kr(0.0001), 0, 600, 900));
		sig = LPF.ar(sig, 500);
		Out.ar(\out.ir(~out), sig);
	}).add;

	SynthDef('delay', {
		var sig, wet;
		sig = In.ar(\in.ir(~fx2Bus), 2);
		wet = CombL.ar(sig, \maxdel.kr(0.1), \deltime.kr(0.1), \decayT.kr(0.2), \mul.kr(1.2));
		wet = BPF.ar(wet, Line.kr(\start.kr(100), \end.kr(1300), \sweep.kr(1.5)));
		sig = XFade2.ar(sig, wet, \mix.kr(0.8));
		Out.ar(\out.ir(~out), sig);
	}).add;

	SynthDef('grain', {
		//https://www.youtube.com/watch?v=MnD8stNB5tE&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=27
		var sig, grain;
		sig = In.ar(\in.kr(~fx3Bus), 2);
		sig = GrainIn.ar(2, Dust.ar(20), \gDur.kr(0.1), sig, mul:2.0);
		sig = BPF.ar(sig, Line.kr(\start.kr(100), \end.kr(1300), \sweep.kr(1.5)));
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
	~percArray = Array.fill(16, {Rest()});
	~percArray.put(0, ~buffers[\low][2]);
	~percArray.put(4, ~buffers[\hi][2]);
	~percArray.put(8, ~buffers[\hi][3]);
	~percArray.put(12, ~buffers[\hi][2]);
	//Server wartet, bis dieser Block fertig ist
	s.sync;

	// ~postBeats = {t.beats.postln; 1};
	//t.schedAbs(t.nextBar, {~postBeats.value});
	// Funktionen, die bei jedem cmd-. oder freeAll Aufruf automatisch neu gestartet werden
	ServerTree.add(~makeNodes);
	ServerTree.run;
	//Server.default.options.device_("Fireface 400 (BEF)");
	s.options.numOutputBusChannels = 6;
	s.sync;


	/// Osc Section
	// n = NetAddr("127.0.0.1", NetAddr.langPort); // local machine
	n = NetAddr("127.0.0.1", 57120); // local machine
	m = NetAddr("127.0.0.1", 5010); // beat send
	~updateUtts = {
		|cat|
		cat.postln;
		if (cat == 'dissence', {~cat = 'dissent'},{~cat = cat});
        ~uttDict[cat].postln;
		// for circular performance, reset counter values
		if(~uttDict[~cat] >= 30, {~uttDict[~cat] = 0}, {~uttDict[~cat] = ~uttDict[~cat] + 1} );
			//add volume to incoming cat Pattern
			//~addVolume.value(~catDict[~cat], 0.1, 0.99);
		postf("\nupdated UttDict %\t", ~uttDict);
	};


	OSCdef.newMatching(
		\interpreter,
		{ arg msg;
			postf("\nnew utt: %", msg[1]);
			postf("\nnew cat: %\n", msg[2]);
			~updateUtts.(msg[2]);
			//~totalUtts = ~totalUtts + 1;
			//postf("\n~uttDict changed %\n", ~uttDict);

			~allocateSynth.value(~cat, ~uttDict[~cat]);
			//~setGlobal.value();

		},
		'/interpreter_input'
	);


	~reset = (
		dis: (
			instrument: 'dissent',
			scale: Pfunc({~sharedValues[\scale]}),
			degree: Pseq([0, Pseq([\], 7)], inf),
			ctranspose: Pfunc({~sharedValues[\transpose]}),
			dur: 1,
			atk:1.5,
			sus: 0.9,
			rls: 4.5,
			ampDist: 0.5,
			durDist: 1.0,
			minfreq: 200,
			maxfreq: 750,
			ffreq: 300,
			gendAmp: 0.4,
			resoFreq: 800,
			modF: 0.8,
			width: 0.8,
			pulseMul: 0.61,
			amp: Pfunc({~sharedValues[\vol]}),
			pan: 0.0,
			sustain: 2.0,
			send: -30,
		),

	lec: (
			instrument: 'lecture',
			scale: Pfunc({~sharedValues[\scale]}),
			ctranspose: Pfunc({~sharedValues[\transpose]}) -12,
			degree: -6,
			dur: 4,
			atk: 0.05,
			sus: 0.9,
			rls: 1.2,
			crv: -3.0,
			modRate: 0.8,
			det1: 0.98,
			det2: 1.02,
			filTime: 0.6,
			amp: 0.5,
			distort: 2.5,
			fade: 1,
			send: -30,
			sustain: 0.2
		),

		fm: (
			instrument: \fmBass,
			scale: Pfunc({~sharedValues[\scale]}),
			ctranspose: Pfunc({~sharedValues[\transpose]}),
			degree: Pseq([0, \r, \r, \r,
				-6, Pseq([\r], 3),
			    -5, Pseq([\r], 3),
			    -6, Pseq([\r], 3),
			], inf),
			dur: 1,
			atk: 0.04,
			rls: 0.4,
			crv: -4.0,
			distort: 1,
			amp: Pfunc({~sharedValues[\vol]}) /2,
			send: -40,
			sustain: 0.3,
			fade:0

		),

		ins: (
			instrument: 'insinuation',
			scale: Pfunc({~sharedValues[\scale]}),
			ctranspose: Pfunc({~sharedValues[\transpose]}) +12,
			degree: Pseq([
				Pseq([-5],5), Pseq([\r],13),
					[-8, 0], Pseq([\r], 15),
					[-5, 3], Pseq([\r],15),
					Pseq([\r], 16)
		], inf),
			dur: 1/8,
			atk: 0.01,
			sus: 0.05,
			rls: 0.05,
			slideTime: 0.02,
			noisFreq: 0.1,
			maxF: 600,
			ffreq: 3.0,
			modWidth: 0.15,
			preamp: 0.3,
			amp: Pfunc({~sharedValues[\vol]}),
			fShift: 100,
			sustain: 0.1,
			send: -30
		),

		con: (
			instrument: 'concession',
	    	buf: Pseq(~percArray,inf),
			dur: 1 ,
			rate: Pwhite(0.9, 1.1, inf),
			pan: Pwhite(-0.5, 0.5, inf),
			bpf: 400,
			fShift: 0.5,
			outfx: ~fx2Bus,
			amp: 0.2,
			send: -35
		),

		pr: (
			instrument:'praise',
			ampHz: 0.2,
			pulWidth: 0.9,
			ampScale: 0.75,
			atk: 0.01,
			rls: 3.5,
			fRate: 0.2,
			//degree: Pseq([[0, 4, 7], [2, 8, 11], [4, 2, 5]], inf),
			degree: Pwrand(
				[
					Pseq([12, \r, \r, \r,
						Prand([9, 6, 10],1), \r, \r, \r,
						Prand([10, 9, 6], 1), \r, \r, \r,
						Pseq([\], 4)],1),
					Pseq([[12, 9 ,4], \r, \r, \r,
						[9, 12], \r, \r, \r,
						4, \r, \r, \r,
						Pseq([\], 4)],1),
					Pseq([\r],16)
			], [0.1, 0.5, 0.1, 0.2].normalizeSum, inf),
			fMul: 1,
			rnd: 1.0,
			pulRate: Pwrand([Pn(Pseq([0.2], 11), Pseq([5], 5), 1), Pseq([0.2], 16)], [0.1, 0.9], inf),
			width: 0.2,
			ffreq: 300,
			rq: 1.0,
			bpf: Prand([120, 130, 220, 330], inf),
			send: -30,
			dur: 1,
			amp: Pfunc({~sharedValues[\vol]}),
			sustain: 1.2

		),
	);

	//makePatterns
	~makePatterns = {
		~reset.keys.do({
			|name|
			//name.postln;
			~patternDict.add(name -> Pbindef(name, *~reset[name].asPairs));
		    ~synthDict.add(name -> (synth: List.new, vol: 0.5, patternVol: 0.2));
		}

			//Pbindef(cat, \amp, 0.2);
		);
	};
	~makePatterns.();
	~fadeThres = 0.15;

~continuousFadeOut = {
	|min, step|
		//logarithmisch erst schnell, dann immer langsamer leiser

	~patternDict.keys.do({
			|cat|
		var vol, c;
		vol = ~synthDict[cat][\patternVol];
		//postf("\nthe vol %  of the pattern   %\n", vol, cat);
		c = case
		{(vol > min) && (vol >= ~fadeThres)} {~synthDict[cat][\patternVol] = vol - (step*3); vol = vol-(step*3)}
		{(vol <= ~fadeThres) && (vol >= min)} { ~synthDict[cat][\patternVol] = vol - step ; vol = vol- step} // slower fade when below thres
		{(vol <= min) && (Pbindef(cat).isPlaying)} {~synthDict[cat][\patternVol] = min; vol = min}
		{true}{"end of fade Cases"};
		//if (vol > min, {~synthDict[cat][\pattern] = vol - step; vol = vol-step}, {~synthDict[cat][\pattern] = min; vol = min});
		Pbindef(cat, \amp, vol);
	});
		/*"+++ ++++\t \t +++ ++++".postln;
		("tempo = " + t.tempo).postln;*/
};


	~startAllPatterns = {
		//start all Pbindefs with minimal volume and a 10 second delay
		Routine.new({
			~reset.keys.asList.scramble.do({
				|cat|
				~patternDict[cat].play(t, quant:4);
				//postf("pattern % is playing % \n", cat, ~patternDict[cat].isPlaying);
				//(t.tempo*5).wait
			})
		}).play;
		// continuousFadeOut(min, step)
		t.schedAbs(t.nextTimeOnGrid, {~continuousFadeOut.value(0.01, 0.002); 1});
	};
	// solo funktion, um einzelne Patterns zu präsentieren. mit Pbindef().pause und resume arbeiten. Idealerweise mit Tasten oder MIDI
	~soloPattern = {
		|name|
		Pbindef.all.do(_.quant_(0));
		~patternDict.keys.do({
			|k|
			if (name != k, {Pbindef(k).pause}, {Pbindef(k).resume})
		})
		};

	///basic patterns

	Pbindef(\rausch,
		\instrument, \rauschen,
		\dur, 5,
		\ffreq, Pseq([666, 150], inf),
		\pan, Pwhite(-1,1, inf),
		\amp, 0.3
	);


	// set functions
	~setDissent = {
		|s_name, count|
		var c, dura, now, amp, status;
		amp = ~synthDict[\dis][\vol];
		dura = Env.new([1,0], [count], [-2]).asPseg;
		5.do({|i|
			Pbind(\instrument, \dissent,
				\width, Pwhite(0.4, 0.9, 1), \freq, Pxrand([200, 300], 1), \amp, 0.8, \atk, Pn(Pwhite(0.01, 0.05), 1), \rls, Pn(Pwhite(0.02, 0.59), 1), \sustain, 0.15, \pulseMul, 0.35, \resoFreq, 3000).play});
		c = case
		{(count > 0) && (count <= 5)} {// 1. Feedback Sound
			~dis = Pbindef(\dis, *~reset[\dis].asPairs);
			~dis = Pbindef(\dis, \resoFreq, 1200 + (100*count), \modF, 0.8  + (count * 0.22));
			status = "Modulation wird schneller";

		}
		{(count > 5) && (count <=10)} {
			~dis = Pbindef(\dis, \dur, 1, \amp, 0.6, \rls, (0.35 * count), \sustain, Pkey(\rls), \pulseMul, count.reciprocal, \gendAmp, 0.9, \ampDist, 6, \durDist, 4, \modF, 0.4, \maxfreq, 120 *count, \ffreq, count*160);
			status = "Weirder Ton schleicht sich ein";
		}
		{(count > 10) && (count <=20)} {
			~dis = Pbindef(\dis,
				\degree, Prand([[0, 4, 7], [0, 3, 7]], inf) * Pif(count.even, 2, 1, 1),
				\dur, Pif(count.even, 2, 0.25, 1),
				\rls, Pif(count.even, 2.5, 0.1, 0.5),
				\sustain, Pkey(\rls),
				\atk, 0.02,
				\minfreq, 200 * (count.linlin(0, count, 1.1, 1.9)),
				\maxfreq, Pkey(\minfreq) * 4,
				\gendAmp, 0.9,
				\pulseMul, Pif(count.even, 0.45, 1.3, 0.4),
			    \modF, Pif(count.even, 0.5 + (count * 0.02), 0.9, 0.5),
				\outfx, ~fx3Bus,
				\send, Pif(count.even, -25 + (count * 0.8), -40, -35)
			);
			status = "Abwechselnd stottern und manisches Fegen";
		}
		{(count > 20) && (count <= 30)} {
			~dis = Pbindef(\dis, *~reset[\dis].asPairs);
			~dis = Pbindef(\dis, \degree, Pseq([
				0, \, \, \,
				0, 4, 2, \,
				-1, \, -1, 2,
				0, \, -4, \,
				\, \, \, -4,
				-1, -1, \, -3,
				\, \, \, \
				], inf),
			\atk, 0.3,
			\rls, 1.3,
			\sustain, Pkey(\rls),
			\width, Pif(count.even, 0.1, Pwhite(0.4, 0.9, inf), 2000),
			\dur, 1,
			\pulseMul, 0.8,
			\add, (count -20) * 0.05,
			\lag, 0.4,
			\gendAmp, 0.8,
			\gendScale, 0.3,
			\ffreq, Pif(count.even, Pwhite(800, 2000, inf), 2000, 800),
			\resoFreq, Pif(count.even, 200, 2000, 2000),
			\outfx, ~fx1Bus,
			\send, -22
			);
			status = "traurige Melodei, abwechselnd hell oder dunkel ";
		}
		{true} {~dis = ~patternDict[\dis]; "end of dissent reached".postln};
		~addVolume.value(\dis, 0.2, 0.65);
		~dis.quant_(4);
		postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);

	};

	~setInsinuation = {
		|s_name, count|
		var c, dura, oneShot, amp, status;
		postf("\nsetting %\t with count %\n", s_name, count);
		dura = Env.new([1,0], [count], [-2]).asPseg;
		5.do({|i|
			Pbind(\instrument, \insinuation,
				\freq, [exprand(100, 250), exprand(1700, 2300)], \amp, 0.25, \rls, Pn(3, 1)).play});
		c = case
		{(count > 0) && (count <= 5)} {
			~ins = Pbindef(\ins,  *~reset[\ins].asPairs);
			~ins = Pbindef(\ins, \fShift, 100 + (50 *count));
			status = "Figur wird höher";
		}
		{(count > 5) && (count <= 10)} {~ins = Pbindef(\ins, \slideTime, count * 0.7, \dur, 4, \atk, 0.8 , \rls, 4.0, \sustain, 4.0, \preamp, 0.9, \degree, Pseq([(0 -count),-5, 0, (2 -count)], inf) );
			status = "Schlierenfigur";
		}
		{(count > 10) && (count <= 20) && (count% 4 == 0)}{oneShot = Pbindef(\ins2, *~reset[\ins].asPairs);
			oneShot = Pbindef(\ins2, \degree, Pseq([
				Pseq([-5],5), Pseq([\r],13),
					[-8, 0], Pseq([\r], 15),
					[-5, 3], Pseq([\r],15),
					Pseq([\r], 16)
		], 2) + count, \amp, 0.4, \dur, 1/16).play(t);
			"one shot Modulo 4".postln;
		}
		{(count > 10) && (count <= 20)} {
			~ins = Pbindef(\ins, \slideTime, 3.5 - (count* 0.02), \maxF, 600 + (count * 10), \dur, 4,
				\atk, 0.8 - (count * 0.04), \rls, 4.0 - (count * 0.16), \sustain, Pkey(\rls),
				\preamp, 0.9,
				\degree, Pseq([(10 - count),-5, 0, (2 -count)], inf) );
			status = "Noten werden immer kürzer und tiefer";
		}
		{(count > 20) && (count <= 30)} {
			~ins = Pbindef(\ins, \ctranspose, 14, \dur, 2,
				\degree, Pseq([[-5, 0], [0,5], [-5, 0], [-9,-5]], inf) -2,
				\sus, 2, \c1, Pxrand([7, -7], inf),
				\modWidth, Pxrand([0.3, 2.4], inf),
				\preamp, 0.22,
				\fShift, 150 + ((count-20) * 80), \noiseFreq, 3.5
			);
			status = "Akkordschleier wird immer höher";
		}

		{true} {~ins = ~patternDict[\ins]; "end of insinuation reached".postln};
		~addVolume.value(\ins, 0.15, 0.65);
		~ins.quant_(4);
		postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);

	};

	~setLecture = {
		|s_name, count|
		var c, dura, pat, status;
		postf("\nsetting %\t with count %\n", s_name, count);
		dura = Env.new([1,0], [count], [-2]).asPseg;
		~lec = Pbindef(\lec, *~reset[\lec].asPairs);
		~fmbass = Pbindef(\fm, *~reset[\fm].asPairs);
		5.do({|i| Pbind(\instrument, \lecture,
			\freq, [exprand(80, 90 + i), exprand(160, (160 + i))], \amp, 0.05, \filTime, 0.02, \rls, Pn(0.5, 1)).play});
		c = case
		{count ==1}	{
			~lec = Pbindef(\lec, \dur, 1,
			\degree, Pseq([0, \r, \r, \r,
				-6, Pseq([\r], 3),
			    -5, Pseq([\r], 3),
			    -6, Pseq([\r], 3),
			], inf)); status = "Bassfigur 1";}
		{count ==2}	{~lec = Pbindef(\lec, \dur, 1, \degree, Pseq([0, Pseq([\r], 7), -5, Pseq([\r], 7)], inf)); status = "Bassfigur 2";}
		{count ==3}	{~lec = Pbindef(\lec, \dur, 1,\degree, Pseq([0, \, \, \, -6, \, \, \, -5,Pseq([\r], 7)], inf)); status = "Bassfigur 3";}
		{count ==4}	{~lec = Pbindef(\lec, \dur, 1,\degree, Pseq([0, \, \, \, -6, \, \, \, -5, \, \, \, -6, \, \, \], inf)); status = "Bassfigur 4";}
		{count ==5}	{~lec = Pbindef(\lec, \dur, 1,\degree, Pseq([0, \, \, \, -6, \, \, \, -5, \, \, \, -7, \, \, \], inf)); status = "Bassfigur 5";}


		{(count > 5) && (count <= 10)} {
			~lec = Pbindef(\lec,
				\dur, 1,
				\degree, Pseq([0, -6, -5, -7], inf),
				\fade, 0.4 - (count * 0.02), \distort, 1.4, \filTime, 0.6 -((count -5) * 0.05));
			~fmbass = Pbindef(\fm, \dur, 1, \degree, Pseq([0, -6, -5, -7], inf), \fade, (count-5) * 0.05 , \atk, (count-4).reciprocal);
			status = "Schnellere Figur und anderer Synth dazu";
		}
		{(count > 10) && (count <= 12)} {
			~lec = Pbindef(\lec, \fade, 0);
			~fmbass = Pbindef(\fm, \dur, 1/4, \degree, Pseq([0, \, \, \, -6, \, \, \, -5, \, \, \, -7, \, \, \], inf), \fade, 0.4);
			status = "FM Bass Figur 1";
		}
		{(count > 12) && (count <= 14)}{
			~lec = Pbindef(\lec, \fade, 0);
			~fmbass = Pbindef(\fm, \dur, 1/4, \degree, Pseq([0, \, \, \, -6, \, \, \, \, \, \, \, 6, \, \, \], inf), \fade, 0.4);
			status = "FM Bass Figur 2";
		}
		{(count > 14) && (count <= 16)}{
			~lec = Pbindef(\lec, \dur, 1, \degree, Pseq([0, -6, -5, -7], inf), \distort, 1.4, \filTime, 0.6 -((count -5) * 0.05));
			~fmbass = Pbindef(\fm,\dur, 1/4, \degree, Pseq([0, \, \, \, -6, \, \, \, \, \, 6, \, 11, \, \, \], inf), \fade, 0.4);
			status = "FM Bass Figur 3";
		}
		{(count > 16) && (count <= 18)}{
			~lec = Pbindef(\lec, \fade, 0);
			~fmbass = Pbindef(\fm,\dur, 1/4, \degree, Pseq([0, \, \, \, -6, \, -6, \, -6, \, 6, \, 11, \, \, \], inf), \fade, 0.4);
			status = "FM Bass Figur 4";
		}
		{(count > 18) && (count <= 20)}{
			~fmbass = Pbindef(\fm,  \dur, Pseq([Pseq([1/4], 4), 6/4, Pseq([1/4], 6) ], inf), \degree, Pseq([0, \, 0, \, 0,  6, \, 11, \, \, \], inf), \fade, 0.4); status = "FM Bass Figur 5";}

		{(count > 20) && (count <= 30)} {
			//~fmbass.pause;
			~reverb.set(\bpf, 0.002);
			~lec = Pbindef(\lec, \degree, Pseq([0, -1],inf) -12, \dur, 3, \filTime, 0.85, \cgain, 5, \distort, 1.5, \fade, (count -20) * 0.13, \outfx, ~fx1Bus, \send, -5);
			pat = Pbind(\instrument, \lecture, \sus, 0.3, \rls, 1.0 - ((count-20) * 0.03),
				\degree, Pif(count.even, Pseq([12, 11, 11, 8, 8, \r, 6, Pseq([\], 24)], inf), Pseq([1, \, -3, \, -5, \, -8, \], inf), Pseq([-12],1)),
				\dur, Pif(count.even, 1, 2, 1/8),
				\distort, 1.3,
				\det1, 1.0 - (count * 0.007), \det2, 1.0 + (count * 0.007),
				\filTime, Pif(count.even, 0.6, 0.8, 0.4 ),
				\amp, Prand([0.4, 0.3, 0.2, 0.1], 9),
				\outfx, Pif(count.even,~fx2Bus, ~fx3Bus, ~fx1Bus ),
				\send, Pif(count.even, -35+ ((count-20)* 2), -40 + ((count-20)* 2), -40),
			).play(t, quant:4);

			~delay.set(\decayT, 0.1 * (count-15));
			~fmbass = Pbindef(\fm, \dur, Pif((count%3==0), 1/4, Pseq([1/8], 15), 1/4),
				\degree, Pif((count%3 == 0),
				Pseq([14, \, \, \, 7, \, \, -2, 0, \, 0, \, \, \, \, 4], inf),
				Pseq([6, \, 0, \, \, 6, \, 0, \, \, 0, \, 4, 14, \, \], inf),

				6),
				\modAmp, 5,
				\fade, 0.6- ((count-20)* 0.059)
			);
			status = "FM Bass faded, Menace Bass rises";

		}
		{true} {~fmbass = ~patternDict[\fm]; ~lec = ~patternDict[\lec]; "end of lecture reached".postln;};
		~addVolume.value(\lec, 0.1, 0.65);
		~addVolume.value(\fm, 0.1, 0.65);
		postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);
		~lec.quant_(4);
		~fmbass.quant_(4);
	};


	~setConcession = {
		|s_name, count|
		var c, dura, pat, status;
		postf("\nsetting %\t with count %\n", s_name, count);
		dura = Env.new([1,0], [count], [-2]).asPseg;
		Pbind(\instrument, \concession, \buf, Pxrand(~buffers[\tonal], 10), \dur, 0.1, \fShift, 0.1,  \amp, 0.14).play(t);
		c = case
		{count ==1}{
			~percArray.put(6, ~buffers[\himid][2]);
			~percArray.put(10, ~buffers[\himid][3]);
			~percArray.put(14, ~buffers[\low][2]);
			~con = Pbindef(\con,\buf, Pseq(~percArray,inf));
			status = "percArray startet";

		}
		{(count > 1) && (count <=5)}{
			~delay.set(\maxdel, 0.9, \deltime, 0.1, \lpf, 1200, \decayT, 3.6, \mul, 0.8, \sweep, count/2);
			~percArray.do({|n, i| if (n == ~buffers[\low][2], {[i + "  "+ n].postln; ~percArray[i] = ~buffers[\bd][1]})});
			~con = Pbindef(\con, \buf, Pseq(~percArray, inf), \send, -35 + (count * 6), \bpf, 100);
			status = "percArray mit delay";
		}
		{(count > 5) && (count <= 10)}{
			~delay.set(\maxdel, 0.9, \deltime, count.reciprocal, \sweep, 3.2, \decayT, 0.3 * count, \mul, 0.99);
			~percArray.do({|n, i| if (n == ~buffers[\low][2], { ~percArray[i] = ~buffers[\bd][1]})});
			~con = Pbindef(\con, \dur, 1/4, \buf, Pseq(~percArray, inf), \send, -30 + (count * 2.5), \rate, [0.51, 0.85, 1.54, 2.34, 3.5].choose, \fade, Prand([0.7, 0.9, 0.99], inf));
			status = "random percArray mit delay";
		}
		{(count > 10) && (count <= 20)}{
			~delay.set(\maxdel, 0.1, \deltime, 0.1, \sweep, 1.5, \decayT, 0.2, \mul, 1);
			~con = Pbindef(\con,
			\buf, Pseq([
				Pn(Prand(~buffers[\low], 1), 3),
				Pn(Prand(~buffers[\himid], 1), 1),
				Pn(Prand(~buffers[\mid],1), 2),
				Prand(~buffers[\hi], 1),
				Pn(Prand(~buffers[\mid],1), 1)], inf),
			\rate, Pwhite(0.9, 1.11, inf),
		    \dur, 1,
			\outfx, ~fx1Bus,
			\send, -30 + ((count%11) * 4)
		);
		~reverb.set(\bpf, (count * 0.3));
			status = "random percbuffers mit wachsendem Hall";
		}

		{(count > 20) && (count <= 30)}{
			~reverb.set(\bpf, 0.0001);
			~percArray2 = Array.fill(32, {~buffers[\dry][4]});
			~percArray2.put(0, ~buffers[\sn][9]);
			~percArray2.put(1, ~buffers[\bd][8]);
			~percArray2.put(3, ~buffers[\bd][9]);
			~percArray2.put(6, ~buffers[\sweep][0]);
			~percArray2.put(12, ~buffers[\sn][1]);
			~percArray2.put(16, ~buffers[\stakkato][0]);
			//~percArray2.replace((16..26), ~buffers[\bd][9]);
			pat = Pseq([~buffers[\sn][9], ~buffers[\bd][8], \, ~buffers[\bd][9],
				\, \,  ~buffers[\sweep][0], \,
				\, \, \, \,
				~buffers[\sn][1], \, \, \,
				~buffers[\stakkato][0], \, \, \,
				Pseq([\], 12)
			], inf);
            if (count >= 25, {pat.stop; pat.isPlaying.postln;});
			if (count%3 ==0, {~percArray2.do({|n, i| if (n == ~buffers[\dry][4], { ~percArray2[i] = ~buffers[\dry].choose})})},
				{~percArray2.do({|n, i| if (n == ~buffers[\dry][4], {~percArray2[i] = ~buffers[\tonal].choose})})});

			~con = Pbindef(\con, \dur, 1/4, \buf, Pif(count <=25, pat, Pseq(~percArray2, inf), ~buffers[\dry][4]), \send, -30, \rate, 1.0, \rls, 4, \sus, Pkey(\rls), \bpf, 800, \rq, 2.0, \fShift, 0.01, \mix, -0.9, \thr, 0.25, \cgain, 3.4, \outfx, ~fx3Bus, \send, -35 + ((count -20) * 3));
			status = "drum 'n bass figurs";
		}
		{true}{	~con = ~patternDict[\con]; "end of setconcession reached".postln};
		~addVolume.value(\con, 0.15, 0.65);
		postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);
		~con.quant_(4);
	};

	~setPraise = {
		|s_name, count|
		var c, pat, dura, status;

		postf("\nsetting %\t with count %\n", s_name, count);
		dura = Env.new([1,0], [count], [-2]).asPseg;
		5.do({|i|
			Pbind(\instrument, \praise,
				\freq, Pxrand([Pwhite(120, 240, 1), Pwhite(240, 480, 1)], 1), \amp, 0.6, \pulRate, 20, \bpf, 500, \rls, Pn(0.3, 1), \sustain, 0.3).play});
		c = case
		{(count > 0) && (count <= 5)} {
			~pr = Pbindef(\pr, *~reset[\pr].asPairs);
			~pr = Pbindef(\pr, \ffreq, 800, \degree, Pif(
				count.even, Pseq([[0, 12], \r, \r, \r,
						[9, 12], \r, \r, \r,
					Pseq([\], [-4, 8])], inf),
				Pseq([[12, 9 ,4], \r, \r, \r,
						[9, 12], \r, \r, \r,
					[12, 4, 10], \r, \r, \r], inf)),
			\ampScale, 0.75 + (count * 0.15),
			\send, -40 + (count * 8)
			);
			status = "Abwechselnde Notenfolgen wachsender Hall";
		}
		{(count > 5) && (count <= 10)} {
			~pr = Pbindef(\pr, \degree, Pseq([[0, 4, 7], [1, 3, 7], [4, 2, 5], [1, 3, 6]], inf) * Pwrand([1, (1 - count.reciprocal)], [0.9, 0.1].normalizeSum, inf), \dur, 3, \ampHz, count -4, \bpf, 120 + (count * 100), \send, -40);
			status = "stottern schneller, random verstimmung wird weniger";
		}
		{(count > 10) && (count <= 20)} {
			~pr = Pbindef(\pr,
			\degree, Pseq([[count]], inf),
			\dur, 1,
			\ampHz, 4,
			\fRate, 8,
			\pulRate, 2,
			\fade, 0.8
			);
			status = "statische Figur wird höher";
		}
		{(count > 20) && (count <= 30)} {
			~pr = Pbindef(\pr,
				\degree, -8 + Pif(count.even, 24, 0, 1),
				\ampHz, Pif(count.even, 0.25, (count-20)*2, 1),
				\pulWidth, 0.75,
				\ampScale, Pif(count.even, 0.3, Pwhite(0.6, 3.9, inf), 1),
				\fRate, 0.25,
				\pulRate, Pif(count.even, 0.125, (count-20)*0.25, 1),
				\fMul, Pif(count.even, 0.25, (count-20)*2, 1),
				\sustain, Pif(count.even, 0.1, 0.5, 1),
				\atk,  Pif(count.even, 0.02, 0.09, 1),
				\rls, Pif(count.even, 0.15, 0.5, 1),
				\dur, Pif(count.even, 1/8, 1/4, 1),
				\width, Pif(count.even, 1.1, 0.5, 1),
				\ffreq, Pn(Pgeom(100, 1.1, count), inf),
				\rq, Pif(count.even, 0.2, 0.8, 1),
				\fade, Pif(count.even, 0.6, 0.8, 0.9)
			);
			status = "heavy Arpeggio, Wechselt bei gerade/ungeraden Counts";
		}
		{true} {~pr = ~patternDict[\pr];"end of insinuation reached".postln;};
		~addVolume.value(\pr, 0.2, 0.65);
		~pr.quant_(4);
		postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);

	};

	~setRauschen = {
		|count|
		var c, dura, now;
		postf("\nsetting rauschen with count %\t", count);
		dura = Env.new([1,0], [count], [-2]).asPseg;
		c = case
		{(count > 5) && (count <= 10)}{Pbindef(\rausch, \ffreq, Pxrand([300, 666, 760], inf) , \rq, Pxrand((0.05, 0.1 .. 2.0), inf), \rls, 0.3).trace;}
		{true} {"end of rauschen cases".postln};
		Pbindef(\rausch).quant_(4);
	};

	~allocateSynth = {
		|s_name, count|
		var c;
		~totalUtts = ~totalUtts + 1; // unbedingt wieder löschen, ist nur test
		~setGlobal.value();
		~updateUtts.(s_name);
		postf("\nallocating to Synth %\t as %   with count %\n", s_name, s_name.class, count);
		postf("\ntotalUtts %\t", ~totalUtts);
		postf("\nuttDict States %\t", ~uttDict);
		c = case
		{s_name == \lecture} {~setLecture.value(s_name, count);}
		{s_name == \praise} {~setPraise.value(s_name, count)}
		{s_name == \dissent} {~setDissent.value(s_name, count)}
		{s_name == \concession} {~setConcession.value(s_name, count)}
		{s_name == \insinuation} {~setInsinuation.value(s_name, count)}
		{true}{"end of allocation".postln};
	};

	~setGlobal = {
		var c;
		c = case
		/*{~totalUtts >= 30} {Scale.choose}
		{~totalUtts % 5 ==0} {Scale.choose}*/
		{~totalUtts ==10} {~uttDict.keys.do({|k| k.postln; ~uttDict[k]= 0});~startAllPatterns.()}
		{~totalUtts >=6} {~setRauschen.(~totalUtts)}
		{~totalUtts >=5} {Pbindef(\rausch).play(t, quant:1); ~mic.set(\send, -20);}
		{~totalUtts > 0 } {~mic.set(\send, (-35 + (~totalUtts * 6)));  }
		{true} {"end of global settings".postln};

	};

	s.sync;
	Pbindef.all.do(_.stop);
	//Server.default.options.outDevice.postln;
	"done".postln;

});
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
~mic = Synth(\mic, [\amp, 0.35, \ffreq, 1500, \outfx, ~fx3Bus, \send, -25]);
~mic.set(\send, -10, \amp, 0.32, \outfx, ~fx1Bus, \cgain, 2.5, \thr, 0.8, \ffreq, 2000);
~mic.set(\send, -5, \amp, 0.22, \outfx, ~fx1Bus, \ffreq, 1500, \thr, 0.2);
~mic.free



(
// stop all patterns
~catDict.do({|cat| Pbindef(cat).stop})
)
	OSCFunc.trace(true);

/// reset ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

currentEnvironment
// tests
~buffers[\sweep][0].play;
// http://sc3howto.blogspot.com/2010/06/pfunc.html  beispiel für ein Fade
3.do({|item, i| Pbind(\instrument, \insinuation, \amp, 0.4, \lfreq, [exprand(100, (200 + (item * 5))), 50], \rls, Pn(3, 1)).play});
~setGlobal.("praise")
~totalUtts =5

(
~delay.set(\maxdel, 0.9, \deltime, 0.8, \sweep, 3.0, \decayT, 10.6, \mul, 0.6);
~reverb.set(\room, 0.1, \damp, 1.1);
)
(
// reset patterns and play the3
~patternDict.keys.do({|k| ~patternDict[k].postln; ~patternDict[k].clear});
~makePatterns.();
~con = ~patternDict[\con];
~fmbass = ~patternDict[\fm];
~lec = ~patternDict[\lec];
~pr = ~patternDict[\pr];
~dis = ~patternDict[\dis];
~ins = ~patternDict[\ins];
Pbindef.all.do(_.stop);
~con.quant_(4).play(t);
~fmbass.quant_(4).play(t);
~lec.quant_(4).play(t);
~pr.quant_(4).play(t);
~dis.quant_(4).play(t);
~ins.quant_(4).play(t);
t.schedAbs(t.nextBar, {~continuousFadeOut.value(0.01, 0.002); 4;});
)

(
Pbindef.all.do(_.postln; "\n".postln);
Pbindef.all.do(_.stop);
Pbindef.all.do(_.resume);
Pbindef.all.do(_.quant_(4));
Pbindef.all.do(_.clear);
~continuousFadeOut = {}
)
(
~setDissent.value('dissent', 30);
~setInsinuation.value('insinuation', 28);
~setLecture.value('lecture', 28);
~setConcession.value('concession', 11);
~setPraise.value('praise', 29 );
)

(
~setDissent.value('dissent', 30.rand);
~setInsinuation.value('insinuation', 30.rand);
~setLecture.value('lecture', 30.rand);
~setConcession.value('concession', 30.rand);
~setPraise.value('praise', 30.rand);
)
(
~allocateSynth.value('praise', ~uttDict['praise']);
~allocateSynth.value('dissent', ~uttDict['dissent']);
~allocateSynth.value('concession',~uttDict['concession']);
~allocateSynth.value('insinuation', ~uttDict['insinuation']);
~allocateSynth.value('lecture',~uttDict['lecture']);
)
(
~soloPattern.(\dis);
~soloPattern.(\pr);
~soloPattern.(\con);
~soloPattern.(\lec);
~soloPattern.(\fm);
~soloPattern.(\ins);
)


(
~postinfo = {
	("beats: "+ ((t.beats.floor) %t.beatsPerBar +1)).postln;
	("bar: "+ (t.bar)).postln;
	"".postln;
	1;
};
t.schedAbs(t.nextBar, {{Blip.ar(500) * EnvGen.kr(Env.perc(0.01, 0.1),doneAction:2)}.play(); ~postinfo.(); });
)




