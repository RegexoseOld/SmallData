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
//s.options.sampleRate = 48000;
Server.default.options.inDevice_("Fireface 400 (BEF)");
//Server.default.options.outDevice_("SoundFlower (2ch)");
Server.default.options.outDevice_("Fireface 400 (BEF)");
//Server.default.options.outDevice_("SuperCollider");

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
~factor = 1;
~volPlus = 0.009;
~volMax = 0.2;
~volMin = 0.001;
~fadeThres = 0.07;
~patPath = PathName(thisProcess.nowExecutingPath).parentPath ++"data/patterns_live.sc";

// wird später in ServerTree angemeldetn
~makeNodes = {
	s.bind(
		~fxGroup = Group.new;
		//später: Fx Synth machen und hier instantiieren zB ....
		~delay = Synth('delay', [\in, ~fx2Bus], ~fxGroup);
		~reverb = Synth('reverb', [\in, ~fx1Bus], ~fxGroup);
		~grain = Synth('grain', [\in, ~fx3Bus], ~fxGroup );

)};



// wenn gebooted wird, passiert alles folgende, Synthdefs etc
s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	s.sync;
	t = TempoClock.new(110/60).permanent_(true);
	~totalUtts = 0;
	~sharedValues = (
		key: 60,
		tempo: 1,
		transpose: 0,
		scale: Scale.chromatic,
		vol: 0.1
	);
	~uttDict = Dictionary.new;
	~catDict = Dictionary.new;
	['dissent', 'praise', 'insinuation', 'concession', 'lecture'].do({
		|cat|
		var c;
		//cat.postln;
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
		sig = PlayBuf.ar(2, \buf.kr(0), \rate.kr(1) *BufRateScale.kr(\buf.kr(0)), \trig.kr(1), \spos.kr(0));
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

	"/Volumes/Macintosh HD 2/projekte/Meinung/Instruments/SuperCollider/data/Looper.scd".load.add;
	//"synthdefs".postln;
	//////////////////////////////////////////////////////////////////////////////

	~buffers= Dictionary.new;
	~path = "/Volumes/Macintosh HD 2/projekte/Meinung/Instruments/SuperCollider/percSamples01";
	//~path = "/Users/borisjoens/Desktop/Soundwesen/percSamples01/";
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

	~buffers.add(\rec1 -> Buffer.alloc(s, s.sampleRate * (8 * t.tempo), 2));
	~percArray = Array.fill(16, {Rest()});
	~percArray.put(0, ~buffers[\low][2]);
	~percArray.put(4, ~buffers[\hi][2]);
	~percArray.put(8, ~buffers[\hi][3]);
	~percArray.put(12, ~buffers[\hi][2]);
	//Server wartet, bis dieser Block fertig ist
	//"buffers".postln;
	//~buffers.keysValuesDo{|k, v| postf("key %  value; % \n", k, v)};
/*	SynthDef(\recBuf, {
		var sig;
		sig = SoundIn.ar(0) * \amp.kr(0.2);
		RecordBuf.ar(sig, ~buffers[\rec1], 0, 1.0, 0.0, loop:1);
	}).add;

	SynthDef(\playBuf, {
		var sig;
		sig = PlayBuf.ar(1,\buf.kr(~buffers[\rec1]), loop:1);
		Out.ar(~out, sig!2);
	}).add;*/
	//////////////////////////////////////////////////////////////////////////////

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
		if (cat == 'dissence', {~cat = 'dissent'},{~cat = cat});
		// for circular performance, reset counter values
		if(~uttDict[~cat] >= 30, {~uttDict[~cat] = 0}, {~uttDict[~cat] = ~uttDict[~cat] + 1} );
			//add volume to incoming cat Pattern
			//~addVolume.value(~catDict[~cat], 0.1, 0.99);
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

	MIDIClient.init;
	MIDIIn.connectAll;
	MIDIFunc.noteOn({ |veloc, num, chan, src|
		var c, startTime, recTime, bpm;
		// start synth
		c = case
		{num == 48} {"making Synth".postln;
			~looper = Synth('kaoslooper', ['in', 0, 'buf', ~buffers[\rec1]]);
			NodeWatcher.register(~looper);}
		{num == 49}{"start/stop and play".postln; ~looper.set(\t_rec, 1) }/*stop recording, start looping*/
		{num == 50}{"overdub".postln; ~looper.set( \t_trig, 1) }/*overdub*/
		{num == 51}{"new sample".postln; ~looper.set( \t_reset, 1) }/*new sample*/
		{num == 52}{"erase sample. for new loop press 48".postln; ~buffers[\rec1].zero }/*erase sample*/
		{true}{"end of MIDIFunc".postln; ~looper.release};
		num.postln;

	});
	//~buffers[\rec1].numFrames/s.sampleRate/4

//////////////////////////////////////////////////////////////////////////////
	// laod reset patterns from external file 'patterns.sc'
	~reset = ~reset ? ();
	~reset[\patternDict] = thisProcess.interpreter.compileFile(~patPath.absolutePath).value;

	//makePatterns
	~makePatterns = {
		~reset[\patternDict].keys.do({
			|name|
			//name.postln;
			~patternDict.add(name -> Pbindef(name, *~reset[\patternDict][name].asPairs));
		    ~synthDict.add(name -> (synth: List.new, vol: 0.5, patternVol: 0.1));
		}

		);
		~metro = Pbindef(\metronom, \instrument, \concession, \buf, ~buffers[\hi][2],
			\dur, 1, \rate, Pseq([1.2, 0.8, 0.8, 0.8], inf), \amp, Pseq([0.4, 0.2, 0.2, 0.2], inf), \send, Prand([Pseq([-35], 64), Pseq([-20], 16)], inf));
		Pbindef(\rausch, \instrument, \rauschen, \dur, 5, \ffreq, Pseq([666, 150], inf), \pan, Pwhite(-1,1, inf), \amp, 0.1	);

	};
	~makePatterns.();
	~addVolume = {
	|cat, add, max|
	var c;
	postf("\nupdating volume of %  from % \n", cat, (~synthDict[cat][\patternVol]) );
	c = case
	{~synthDict[cat][\patternVol] <= ~fadeThres}{~synthDict[cat][\patternVol] = ~synthDict[cat][\patternVol] + (add *3) }// triple enhance when pattern is very quiet
	{(~synthDict[cat][\patternVol] <= max) && (~synthDict[cat][\patternVol] >= ~fadeThres)}{~synthDict[cat][\patternVol] = ~synthDict[cat][\patternVol] + add}
	{~synthDict[cat][\patternVol] >= max}{~synthDict[cat][\patternVol] = max}
	{true}{"end of addVolume".postln};

	postf("new vol of %  is % \n", cat, (~synthDict[cat][\patternVol]) );

};

	~continuousFadeOut = {
		|min, step|
		//logarithmisch erst schnell, dann immer langsamer leiser
		// remove constants that should not fade out
		~toFade = ~patternDict.keys - Set['hh01', 'bd01', 'sn01', 'bass01', 'zahl'];
		~toFade.do({
			|cat|
			var vol, c;
			vol = ~synthDict[cat][\patternVol];
			//postf("\nthe vol %  of the pattern   %\n", vol, cat);
			c = case
			{(vol > min) && (vol >= ~fadeThres)} {~synthDict[cat][\patternVol] = vol - (step*4); vol = vol-(step*4)}
			{(vol <= ~fadeThres) && (vol >= min)} { ~synthDict[cat][\patternVol] = vol - step ; vol = vol- step} // slower fade when below thres
			{vol <= min} {~synthDict[cat][\patternVol] = min; vol = min}
			{true}{"end of fade Cases"};
			//if (vol > min, {~synthDict[cat][\pattern] = vol - step; vol = vol-step}, {~synthDict[cat][\pattern] = min; vol = min});
			Pbindef(cat, \amp, vol);
		});
		//"+++ ++++\t \t +++ ++++".postln;/*
		//("tempo = " + t.tempo).postln;*/
	};


	~startAllPatterns = {
		//start all Pbindefs with minimal volume and a 10 second delay
		Routine.new({
			~reset[\patternDict].keys.asList.scramble.do({
				|cat|

				~patternDict[cat].play(t, quant:-4);
				postf("pattern % is playing % \n", cat, ~patternDict[cat].isPlaying);
				//(t.tempo*5).wait
			})
		}).play;
		// continuousFadeOut(min, step)
		t.schedAbs(t.nextTimeOnGrid, {~continuousFadeOut.value(0.001, 0.0003); 1});
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


	// set functions
	//~set = ~set ? ();
	//~setDissent = PathName(thisProcess.nowExecutingPath).parentPath ++"data/setDissent.scd";

	~setInsinuation = "/Volumes/Macintosh HD 2/projekte/Meinung/Instruments/SuperCollider/data/setInsinuation.scd".load;
	~setDissent = "/Volumes/Macintosh HD 2/projekte/Meinung/Instruments/SuperCollider/data/setDissent.scd".load;
	~setLecture = "/Volumes/Macintosh HD 2/projekte/Meinung/Instruments/SuperCollider/data/bass01.scd".load;
	~setConcession = "/Volumes/Macintosh HD 2/projekte/Meinung/Instruments/SuperCollider/data/perc01.scd".load;
	~setPraise = "/Volumes/Macintosh HD 2/projekte/Meinung/Instruments/SuperCollider/data/setPraise.scd".load;

	~setRauschen = {
		|count|
		var c, dura, now;
		postf("\nsetting rauschen with count %\t", count);
		dura = Env.new([1,0], [count], [-2]).asPseg;
		c = case
		{(count > 5) && (count <= 10)}{Pbindef(\rausch, \ffreq, Pxrand([300, 666, 760], inf) , \rq, Pxrand((0.05, 0.1 .. 2.0), inf), \rls, 0.3, \amp, 0.1);}
		{true} {"end of rauschen cases".postln};
		Pbindef(\rausch).quant_(4);
	};

	~allocateSynth = {
		|s_name, count|
		var c;
		~totalUtts = ~totalUtts + 1;
		~setGlobal.value();
		~updateUtts.(s_name);
		postf("\n \n+++ ++++ ++++ \n\nnew UTT %\t \n", s_name);
		postf("\ntotalUtts %\n", ~totalUtts);
		postf("\nuttDict: %\t", ~uttDict);
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
		{~totalUtts >= 40} {"changed Scale".postln; Scale.choose}
		{~totalUtts >= 25} {"mic ohne hall".postln; ~mic.set(\send, -38);}
		{~totalUtts == 20} {"mic mit hall".postln; ~mic.set(\send, -12);}
		{~totalUtts ==10} {~uttDict.keys.do({|k| ~uttDict[k]= 0}); ~startAllPatterns.()}
		{~totalUtts >=6} {~setRauschen.(~totalUtts)}
		{~totalUtts >=5} {Pbindef(\rausch).play(t, quant:1); ~mic.set(\send, -20); ~metro.play(t, quant:1);}
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

/* Das Soundwesen*/

//activate Mic
~mic = Synth(\mic, [\amp, 0.45, \ffreq, 1500, \outfx, ~fx3Bus, \send, -25]);
~mic.set(\send, -40, \amp, 0.4, \outfx, ~fx1Bus, \cgain, 2.5, \thr, 0.8, \ffreq, 2000);
~mic.set(\send, -5, \amp, 0.22, \outfx, ~fx1Bus, \ffreq, 1500, \thr, 0.2);
~mic.free
~rec = Synth(\recBuf, [\amp, 0.4]);
~rec.free;
~play = Synth(\playBuf);
~play.isPlaying
~play.free;


/// reset ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// tests
~buffers[\sweep][0].play;
~buffers[\zahlen][6].play;
~reset.clear
t.beatsPerBar




(
~delay.set(\maxdel, 0.9, \deltime, 0.8, \sweep, 3.0, \decayT, 10.6, \mul, 0.6);
~reverb.set(\room, 0.1, \damp, 1.1);
)
(
~factor = 1.3;
postf("\nset factor % \n", ~factor);
)

(
//Pbindef.all.do(_.postln; "\n".postln);
Pbindef.all.do(_.play(t, quant:-4));
Pbindef.all.do(_.stop);
Pbindef.all.do(_.resume);
Pbindef.all.do(_.quant_(4));
Pbindef.all.do(_.clear);
~continuousFadeOut = {}
)
(
~setDissent.value('dissent', 4);
~setInsinuation.value('insinuation', 21);
~setLecture.value('lecture', 8);
~setConcession.value('concession', 0);
~setPraise.value('praise', 29 );
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

(
~setDissent.value('dissent', 30.rand);
~setInsinuation.value('insinuation', 30.rand);
~setLecture.value('lecture', 30.rand);
~setConcession.value('concession', 30.rand);
~setPraise.value('praise', 30.rand);
)

(
// reset patterns and play the3
~patternDict.keys.do({|k| ~patternDict[k].postln; ~patternDict[k].clear});
~makePatterns.();
~con = ~patternDict[\con];
~fmbass = ~patternDict[\fm];
~lec = ~lec ? ~patternDict[\lec];
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


