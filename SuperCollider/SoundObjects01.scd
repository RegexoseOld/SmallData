/*
SoundObjects kombiniert in Mix UGEns

Bug bei ~totalUtts = 30 gibt es "late" -messages. hier gucken
https://scsynth.org/t/what-are-those-late-messages-in-the-post-window/5718

*/

SynthDescLib.global.browse;
ServerOptions.device;
ServerOptions.inDevices;
ServerOptions.outDevices;
~fxGroup = nil
(
Server.default.options.numInputBusChannels_(2);
//Server.default.options.outDevice_("BeatsSolo Wireless");
//Server.default.options.outDevice_("SuperCollider");
s.options.sampleRate = 48000;
//Server.default.options.inDevice_("Fireface 400 (BEF)");
//Server.default.options.outDevice_("SoundFlower (2ch)");
//Server.default.options.outDevice_("Fireface 400 (BEF)");
Server.default.options.outDevice_("Built-in Output");

Server.default.options.outDevice.postln;
Server.default.options.memSize_(8192 * 2);
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
~fbVol = 0.4;
~volPlus = 0.009;
~volMax = 0.2;
~volMin = 0.001;
~fadeThres = 0.07;
// wird später in ServerTree angemeldetn
~makeNodes = {
	s.bind(
		~fxGroup = Group.new;
		//später: Fx Synth machen und hier instantiieren zB ....
		~delay = Synth('delay', [\in, ~fx2Bus], ~fxGroup);
		~reverb = Synth('reverb', [\in, ~fx1Bus], ~fxGroup);
		~grain = Synth('grain', [\in, ~fx3Bus], ~fxGroup);

)};


// wenn gebooted wird, passiert alles folgende, Synthdefs etc
s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	s.sync;
	~clk01 = TempoClock.new(110/60).permanent_(true);
	~clk02 = TempoClock.new(110/60).permanent_(true);
	~clk03 = TempoClock.new(110/60).permanent_(true);
	~clk04 = TempoClock.new(110/60).permanent_(true);
	~clk05 = TempoClock.new(110/60).permanent_(true);
	~totalUtts = 0;

	~uttDict = Dictionary.new;
	['dissent', 'praise', 'insinuation', 'concession', 'lecture'].do({
		|cat|
		var c;
		//cat.postln;
		c = case
		{cat=='dissent'}{~uttDict.add(cat-> \dis)}
		{cat=='praise'}{~uttDict.add(cat-> \pr)}
		{cat=='insinuation'}{~uttDict.add(cat-> \ins)}
		{cat=='concession'}{~uttDict.add(cat-> \con)}
		{cat=='lecture'}{~uttDict.add(cat-> \lec)}
		{true}{"end of catDict".postln};
	});
	~synthDict = Dictionary.new;
	~patternDict = Dictionary.new;

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
		env = EnvGen.kr(Env.adsr(\atk.ir(1.5), releaseTime:\rls.kr(0.2), curve:\crv.kr(-10)), gate, doneAction:2);
		mod = SinOsc.kr(\modF.kr(1.0));
		gend = BPF.ar(Gendy1.ar(\ampDist.kr(0.5), \durDist.kr(1), 1.0, 1.0, \minfreq.kr(100), \maxfreq.kr(1000), \gendScale.kr(0.5), 0.05, 5), \ffreq.kr(300), \rq.kr(0.9)) * \gendAmp.kr(0.4);
		sig = LFPulse.ar(\freq.kr(100).varlag(\lag.kr(0.01), \lagcrv.kr(5.0)), 0.0, \width.kr(0.4),\pulseMul.kr(0.45), \add.kr(0)) ;
		sig = RLPF.ar(sig, \resoFreq.kr(900) ) + gend;
		sig = Compander.ar(sig, sig, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(3));
		sig = Pan2.ar(sig * env * (\amp.kr(0.1) * mod), \pan.kr(0.0));
		Out.ar(\out.ir(~out), sig * \fade.kr(1));
		Out.ar(\outfx.kr(~fx1Bus), sig * \send.ir(-30).dbamp);
	}).add;


	SynthDef.new('lecture', {
		|gate = 1|
		var detune, sig, env, mod, ampMod;
		env = EnvGen.kr(Env.adsr(\atk.kr(0.01), 0.2, \sus.kr(0.8), \rls.kr(1.0), curve:\crv.kr(-4.0)), gate, doneAction: 2);
		mod = SinOsc.kr(\modRate.kr(1.2));
		sig = VarSaw.ar(\freq.kr(100), 0, LFTri.kr(\filTime.kr(0.3)));
		sig = (sig * \distort.kr(1.5)).tanh;
		sig = sig * env * mod ;
		sig = Compander.ar(sig, sig, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(3));
		sig = Pan2.ar(sig * (\amp.kr(0.1) * \fade.kr(0)), \pan.kr(1));
		Out.ar(~out, sig );
		Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-30).dbamp);
	}).add;

	SynthDef.new(\bizz, {
		|gate = 1|
		var sig, trig, env, amp, fade;
		env = EnvGen.kr(Env.adsr(\atk.kr(0.01), \dec.kr(0.2), \sus.kr(0.8), \rls.kr(1.0), curve:\crv.kr(-4.0)), gate, doneAction: 2);
		trig = SinOsc.kr(\tRate.kr(3)).exprange(\pulseL.kr(80), \pulseH.kr(1000));
		sig = Impulse.ar(trig, \phs.kr(0.0)) * env;
		sig = sig * \distort.kr(1.0).tanh ;
		sig = Compander.ar(sig, sig, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(5));
		sig = sig * \amp.kr(0.1) * \fade.kr(1) ;
		Out.ar(~out, sig)
	}).add;

	SynthDef.new(\attack, {
		|gate = 1|
		var channels, temp, env, vol, sig, sweep;
		env = EnvGen.kr(Env.adsr(\atk.kr(0.01), \dec.kr(0.2), \sus.kr(0.1), \rls.kr(0.4), curve:\crv.kr(-1.0)), gate, doneAction: 2);
		vol = \amp.kr(0.1) * \fade.kr(1);
		channels = {
			sweep = XLine.ar({ExpRand(\freq.kr(1200), \freq2.kr(80))}, \ef.kr(40), \fdur.kr(0.08));
			temp = Select.ar(\which.kr(0), [
				WhiteNoise.ar(),
				Blip.ar(sweep, \harm.kr(100)),
				SinOsc.ar(sweep), // kickdrum
				Impulse.ar(\dens.kr(1), 0.0, \knk.kr(1.0) ) // Ich suche einen klicksound
			]) * env ;
			temp = FreqShift.ar(temp, \shift.kr(0));
			temp = BPF.ar(temp, \eqfr1.kr(2300) ,\boost.kr(1.6));
			temp = Compander.ar(temp, temp, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(2.3));
		}!2 ;
		sig = Splay.ar(channels, center: \cent.kr(0.0), level:vol);
		Out.ar(~out, sig);
		Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-32).dbamp);
	}).add;

	SynthDef.new(\fmBass, {
		var sig, car, mod, env;
		env = EnvGen.kr(Env.perc(\atk.kr(0.04), \rls.kr(0.2),  \crv.kr(-4.0)), 1, doneAction:2);
		mod = SinOsc.ar(\freq.kr(100)/5,  mul: \modAmp.kr(20));
		car = SinOsc.ar(\freq.kr(100));
		sig = (car + mod) * env * \amp.kr(0.1);
		sig = (sig * \distort.kr(1.5)).tanh;
		sig = sig * \fade.kr(1);
		sig = Splay.ar(sig, \spread.kr(1), center: \center.kr(0.0));
		Out.ar(~out, sig);
		Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-30).dbamp);
	}).add;

	SynthDef('insinuation', {
		| gate = 1|
		var  sig, env, lagfrq;
		env = EnvGen.kr(Env([0,1,1,0], [\atk.kr(0.05), \sus.kr(0.05), \rls.kr(0.25)], [\c1.kr(-2.0), \c2.kr(1), \c3.kr(-4)]), gate, doneAction: 2);
		lagfrq = Lag.kr(\freq.kr(220), \slideTime.kr(0.6));
		sig = PMOsc.ar(lagfrq, LFNoise2.ar(\noisFreq.kr(0.1), \maxF.kr(600)), SinOsc.ar(\ffreq.kr(3.0)), pmindex:\modWidth.kr(0.15), mul:\preamp.kr(0.2)) * \amp.kr(0.2)
		* env ;
		sig = FreqShift.ar(sig, \fShift.kr(100));
		Out.ar(~out, sig * \fade.kr(1));
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.kr(-30).dbamp);
	}).add;
	//Synth(\insinuation, [\slideTime, 1.6, \freq, 300, \c1, -10.0, \sus, 4, \noiseFreq, 5.5, \maxF, 500, \modWidth, 1.3, \ffreq, 20, \fShift, 470])


	SynthDef('concession', {
		var sig, shift, env;
		sig = PlayBuf.ar(2, \buf.kr(0), \rate.kr(1) *BufRateScale.kr(\buf.kr(0)), \trig.kr(1), \spos.kr(0));
		//die Env muss wohl .ar sein, um bufnums austauschen zu können
		env = Env([0, 1, 1, 0], [\atk.kr(0), 0.2,  \sus.kr(0), \rls.kr(1)], [0, 0, 0]).kr(2);
		shift = FreqShift.ar(sig, \fShift.kr(20) );
		sig = XFade2.ar(sig, shift, \mix.kr(0.0));
		sig = BPF.ar(sig, \bpf.kr(440), \rq.kr(1.0));
		sig = sig * env * \amp.kr(0.2);
		sig = Compander.ar(sig, sig, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(5));
		sig = LinPan2.ar(sig, \pos.kr(0.0));
		Out.ar(\out.kr(~out), sig* \fade.kr(1)) ;
		Out.ar(\outfx.kr(~fx2Bus), sig * \send.ir(-30).dbamp);
	}).add;


	SynthDef('praise', {
		|gate=1|
		var channels;
		channels = {
			var amp1, freq1, sig1, env1;
			amp1 = LFPulse.kr(\ampHz.kr(0.2), 0, \pulWidth.kr(0.9)) * \ampScale.kr(0.75);
			env1 = EnvGen.kr(Env.adsr(\atk.kr(1.0), 0.2, 0.9, \rls.kr(2)), gate, doneAction:2);
			freq1 = LFNoise0.kr(\fRate.kr(0.2)).exprange(\freq.kr(120), \freq.kr(120) * \fMul.kr(4)).round(\freq.kr(120) * \rnd.kr(1.0)) ;
			freq1 = freq1 * LFPulse.kr(\pulRate.kr(0.2));
			sig1 = RHPF.ar(Pulse.ar(freq1, \width.kr(0.2)), \ffreq.kr(300), \rq.kr(1.0)) * amp1 * env1 ;
			sig1 = BPF.ar(sig1, \bpf.kr(120));
		} * \amp.kr(0.4) * \fade.kr(0.75);
		channels = Splay.ar(channels, center: \center.kr(0.0));
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
		sig = FreeVerb2.ar(sig[0], sig[1], mix:\mx.kr(0.5), room:\room.kr(0.99), damp:\damp.kr(0.99));
		sig = BPF.ar(sig, SinOsc.kr(\bpf.kr(0.0001), 0, 600, 900));
		sig = Compander.ar(sig, sig, \thr.kr(0.65), 1, 0.3, 0.3, 0.4, \cgain.kr(2));
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

	"/Users/borisjoens/Documents/IchProjekte/Meinung/SmallData_GitHub/SuperCollider/data/Looper.scd".load.add;
	"synthdefs".postln;
	//////////////////////////////////////////////////////////////////////////////

	~buffers= Dictionary.new;
	/*~path = "/Volumes/Macintosh HD 2/projekte/Meinung/Instruments/SuperCollider/percSamples01";*/
	~path = "/Users/borisjoens/Desktop/Soundwesen/percSamples01/";
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

	//~buffers.add(\rec1 -> Buffer.alloc(s, s.sampleRate * (8 * clk02.tempo), 2));
	"buffers".postln;
	//////////////////////////////////////////////////////////////////////////////

	s.sync;
	// Funktionen, die bei jedem cmd-. oder freeAll Aufruf automatisch neu gestartet werden
	ServerTree.add(~makeNodes);
	ServerTree.run;
	//Server.default.options.device_("Fireface 400 (BEF)");
	s.options.numOutputBusChannels = 6;
	s.sync;

	/// Osc Section
	//n = NetAddr("127.0.0.1", 57120); // local machine
	~updateUtts = {
		|cat|
		postf("updating % ", cat);
		if (cat == 'dissence', {~cat = 'dissent'},{~cat = cat});
		// for circular performance, reset counter values
		if(~uttDict[~cat] >= 30, {~uttDict[~cat] = 0}, {~uttDict[~cat] = ~uttDict[~cat] + 1} );
	};

	OSCdef.newMatching(
		\interpreter,
		{ arg msg;
			postf("\nnew utt: %", msg[1]);
			postf("\nnew cat: %\n", msg[2]);
			~updateUtts.(msg[2]);
			0.1.wait;
			~allocateSynth.value(~cat, ~uttDict[~cat]);
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
	"network".postln;
	//////////////////////////////////////////////////////////////////////////////
	// laod reset patterns from external file 'pattern_objects.sc'

	~patPath = PathName(thisProcess.nowExecutingPath).parentPath ++ "data/patterns_objects.sc";
	~reset = ~reset ? ();
	~reset = thisProcess.interpreter.compileFile(~patPath.absolutePath).value;
	"compiled resets".postln;

	~makePatterns = {
		~objects = Dictionary.new;
		~reset.keys.do({
			|ob|
			var oP = Dictionary.new /*objectPatterns*/, melo = ~reset[ob][\melo][\a];
			ob.postln;
			~reset[ob].keys.do({
				|k|
				var current;
				k.postln;
				if (k != 'melo', {
					current = Pbindef(k, *~reset[ob][k].asPairs);
					current = Pbindef(k, \midinote, Pseq(melo, inf));
					~patternDict.add(k -> current); // can be deleted if ~startAllPatterns isn't used anymore
					oP.add(k -> current);
					~synthDict.add(k -> (synth: List.new, vol: 0.5, patternVol: 0.1)); // wird das noch gebraucht?
				});
			});
			~objects.add(ob -> oP);
		});
		"made patterns".postln;

		//~objects[\obj1][\atak].postln;
	/*	Pbindef(\metronom, \instrument, \concession, \buf, ~buffers[\hi][2],
			\dur, 1, \rate, Pseq([1.5, 0.7, 0.7, 0.7], inf), \amp, Pseq([0.4, 0.15, 0.15, 0.15], inf) * 0.3);
		Pbindef(\rausch, \instrument, \rauschen, \dur, 5, \ffreq, Pseq([666, 150], inf), \pan, Pwhite(-1,1, inf), \amp, 0.1);*/

	};
	Pbindef.all.do(_.clear);
	~makePatterns.();

	~startObjects = {
		~reset.keys.do({
			|ob|
			var clock, c;
			ob.postln;
			c = case
			{ob == 'obj1'}{clock = ~clk01}
			{ob == 'obj2'}{clock = ~clk02}
			{ob == 'obj3'}{clock = ~clk03}
			{true}{"end of clocks".postln};

			~objects[ob].keys.do({|k|

				Pbindef.all[k].quant_(8);
				Pbindef.all[k].play(clock);
				postf("starting %\n   isPlaying?  %\n ", k, Pbindef.all[k].isPlaying);
			});

			postf("started object %\n", ob);
		});
		// Pbindef(\metronom).quant_(4);
		//Pbindef(\metronom).play(t);
	};

	~startAllPatterns = {
		//start all Pbindefs with minimal volume and a 10 second delay
		Routine.new({
			~reset[\patternDict].keys.asList.scramble.do({
				|cat|
				~patternDict[cat].quant_(8);
				~patternDict[cat].play(t);
				postf("pattern % is playing % \n", cat, ~patternDict[cat].isPlaying);
				//(t.tempo*5).wait
			})
		}).play;
		// continuousFadeOut(min, step)
		t.schedAbs(t.nextTimeOnGrid, {~continuousFadeOut.value(0.001, 0.0003); 1});
	};

	"reset & patterns".postln;
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
		////////// TODO auf ~objects anwenden
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

	// solo funktion, um einzelne Patterns zu präsentieren. mit Pbindef().pause und resume arbeiten. Idealerweise mit Tasten oder MIDI
	~soloPattern = {
		|name|
		Pbindef.all.keysDo{|p|
			p.postln;
			if (name != p, {Pbindef.all[p].pause}, {Pbindef.all[p].resume})
		}
	};


	// set functions

	//relative Path...? ~setDissent = PathName(thisProcess.nowExecutingPath).parentPath ++"data/setDissent.scd";

/*	~setObj01 = "/Volumes/Macintosh HD 2/projekte/Meinung/SmallData_GitHub/SuperCollider/data/setObj_01.scd".load;
	~setObj02 = "/Volumes/Macintosh HD 2/projekte/Meinung/SmallData_GitHub/SuperCollider/data/setObj_02.scd".load;
	~setObj04 = "/Volumes/Macintosh HD 2/projekte/Meinung/SmallData_GitHub/SuperCollider/data/setObj_04.scd".load;
	~setObj03 = "/Volumes/Macintosh HD 2/projekte/Meinung/SmallData_GitHub/SuperCollider/data/setObj_03.scd".load;*/


	~setObj01 = "/Users/borisjoens/Documents/IchProjekte/Meinung/SmallData_GitHub/SuperCollider/data/setObj_01.scd".load;
	~setObj02 = "/Users/borisjoens/Documents/IchProjekte/Meinung/SmallData_GitHub/SuperCollider/data//setObj_02.scd".load;
	~setObj04 = "/Users/borisjoens/Documents/IchProjekte/Meinung/SmallData_GitHub/SuperCollider/data//setObj_04.scd".load;
	~setObj03 = "/Users/borisjoens/Documents/IchProjekte/Meinung/SmallData_GitHub/SuperCollider/data//setObj_03.scd".load;
	~setPraise = "/Users/borisjoens/Documents/IchProjekte/Meinung/SmallData_GitHub/SuperCollider/data//setPraise.scd".load;
	~setDissent = "/Users/borisjoens/Documents/IchProjekte/Meinung/SmallData_GitHub/SuperCollider/data//setDissent.scd".load;

	~allocateSynth = {
		|s_name, count|
		var c;
		// nur bei simulation ohne OSC benutzen
		~updateUtts.(s_name);
		~totalUtts = ~totalUtts + 1;
		~setGlobal.value();


		postf("\n \n+++ ++++ ++++ \n\nnew UTT %\t \n", s_name);
		postf("\ntotalUtts %\n", ~totalUtts);
		postf("\nuttDict: %\t", ~uttDict);
		c = case
		{s_name == \lecture} {~setObj01.value(count);}
		{s_name == \praise} {~setPraise.value(count)} // reverb
		{s_name == \dissent} {~setDissent.value(count)} // granular distortion
		{s_name == \concession} {~setObj02.value(count)}
		{s_name == \insinuation} {~setObj03.value(count)}
		{true}{"end of allocation".postln};
	};

	~setGlobal = {
		var c;
		c = case
		{(~totalUtts % 21 == 0)} {~setObj04.value(~totalUtts) ; "started knacks".postln;}
		{~totalUtts ==10} {~uttDict.keys.do({|k| ~uttDict[k]= 1}); ~startObjects.();}
		{~totalUtts >=1} {~setObj04.(~totalUtts);
		}
		{true} {"end of global settings".postln};

	};

	s.sync;

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


/// reset ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// tests
~buffers[\klics][0].play;
~buffers[\zahlen][6].play;
~reset.clear;
{ Impulse.ar(2,0.5,0.8) }.play;
//~sharedValues[\scale] = Scale.choose
(
var notes;
notes = ~reset[\obj1][\melo][\a].asStream;
notes.nextN(32).postln;
)
~objects[\obj2].keys
~objects[\obj1][\atak].play
Pmono(\attack, \dur, 0.5, \which, Prand([0, 1, 2, 3], inf), \lag, Pwhite(0.002, 0.3, inf)).play
Pbindef(\atak).play
Env.adsr(0.01, 0.5,0.5, 1.0, curve:0).plot
Pbindef(\atak).isPlaying
Pbindef(\org2, \atk, 1, \fRate, 0.2, \dur, 2).play;
Pbindef(\org2).isPlaying;
Synth(\praise)



t.beatsPerBar
(
r = Routine.new({
	~startObjects.();
	loop{
		5.wait;
	/*	~setObj03.value(30.rand);
		2.wait;
		~setObj01.value(30.rand);
		2.wait;
		~setDissent.value(30.rand);
		2.wait;
		~setObj02.value(30.rand);
		2.wait;
		~setPraise.value(30.rand);*/
		~allocateSynth.value('praise', ~uttDict['praise']);
		3.wait;
		~allocateSynth.value('dissent', ~uttDict['dissent']);
		3.wait;
		~allocateSynth.value('concession',~uttDict['concession']);
		3.wait;
		~allocateSynth.value('insinuation', ~uttDict['insinuation']);
		3.wait;
		~allocateSynth.value('lecture',~uttDict['lecture']);

	}
}).play;
);

(
~factor = 2
;
postf("\nset factor % \n", ~factor);
)
//t.tempo = 0.2

(
~setObj01.value('lecture', 9);
)
(
~allocateSynth.value('praise', ~uttDict['praise']);
~allocateSynth.value('dissent', ~uttDict['dissent']);
~allocateSynth.value('concession',~uttDict['concession']);
~allocateSynth.value('insinuation', ~uttDict['insinuation']);
~allocateSynth.value('lecture',~uttDict['lecture']);
)

(
~soloPattern.(\atag);
~soloPattern.(\biz);
~soloPattern.(\con);
~soloPattern.(\lec);
~soloPattern.(\fm);
~soloPattern.(\ins);
)


