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
~fx2Bus = Bus.audio(s,2);
~cat = "";
~out = 0;
~totalUtts = 0;
~categories = ['dissence', 'praise', 'insinuation', 'concession', 'lecture'];
~synthDict = Dictionary.new;
~categories.do({arg i; ~synthDict.add(i -> (synth: List.new,
	vol: 0.2))});
/*~synthDict.add(\dissence ->  List.new;);
~synthDict.add(\praise -> List.new);
~synthDict.add(\insinuation -> List.new);
~synthDict.add(\concession -> List.new);
~synthDict.add(\lecture ->  List.new);*/

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
		env = EnvGen.kr(Env.adsr(\atk.ir(3.1), 0.1, 0.9, \rls.ir(2.9), curve:\crv.kr(-10)), gate, doneAction:2);
		gend = BPF.ar(Gendy1.ar(\ampDist.kr(1.0), \durDist.kr(1.0), 1.0, 1.0, \minfreq.kr(400), \maxfreq.kr(1000), 0.3, 0.05, 5), \ffreq.kr(300), \rq.kr(0.9)) * \gendAmp.kr(0.3);
		sig = LFPulse.ar(\freq.kr(100).varlag(\lag.kr(0.3), \lagcrv.kr(5.0)), \pPhase.kr(0.0), \width.kr(0.4),\pulseMul.kr(0.15)) + gend ;
		sig = Pan2.ar(sig * env * \amp.kr(0.6), \pan.kr(0.0));
		Out.ar(\out.ir(~out), sig);
		Out.ar(\outfx.ir(~fx1Bus), sig * \send.ir(-30).dbamp);
	}).add;


	SynthDef.new('lecture', {
		|gate = 1|
		var detune, sig, env, mod, ampMod;
		env = EnvGen.kr(Env.adsr(\atk.kr(0.01), 0.2, \sus.kr(3.0), \rls.kr(1.0), curve:\crv.ir(-4.0)), gate, doneAction: 2);
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
		var  sig, env, frq;
		env = EnvGen.kr(Env([0,1,1,0], [\atk.kr(0.05), 0.3, \sustain.kr(0.5), \rls.kr(0.4)], \linear), gate, doneAction: 2) ;
		frq = Lag.kr(\freq.kr(220), \slideTime.kr(0.6));
		sig = PMOsc.ar(frq, LFNoise2.ar(\noisFreq.kr(0.1), \maxF.kr(600)), SinOsc.ar(\ffreq.kr(3.0)), pmindex:\modWidth.kr(0.15), mul:\preamp.kr(0.2)) * \amp.kr(0.4)
		* env ;
		sig = FreqShift.ar(sig, \fShift.kr(100));
		Out.ar(~out, sig ! 2);
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
		|gate=1, amp=0.7|
		var amp1, amp2, freq1, freq2, sig1, sig2, env1, env2;
		amp1 = LFPulse.kr(\ampHz.kr(4.0), 0, \pulWidth.kr(0.12)) * \ampScale.kr(0.01);
		amp2 = LFPulse.kr(\ampHz.kr(4.0), 0, \pulWidth.kr(0.12)) * \ampScale.kr(0.01);
		env1 = EnvGen.kr(Env.adsr(\atk.kr(0.5), 0.2, 0.7, \rls.kr(0.9)), gate, doneAction:2);
		env2 = EnvGen.kr(Env.adsr(\atk.kr(0.5), 0.1, 0.7, \rls.kr(0.9)), gate, doneAction:2);
		freq1 = LFNoise0.kr(\fRate.kr(4.0)).exprange(\freq.kr(40), \freq.kr(40) * \fMul.kr(80)).round(\freq.kr(40) * \rnd.kr(1.0));
		freq2 = LFNoise0.kr(\fRate.kr(4.0)).exprange(\freq.kr(40), \freq.kr(40) * \fMul.kr(80)).round(\freq.kr(40) * \rnd.kr(1.0));
		freq1 = freq1 * LFPulse.kr(\pulRate.kr(4.0));
		freq2 = freq2 * LFPulse.kr(\pulRate.kr(4.0));
		sig1 = RHPF.ar(Pulse.ar(freq1, \width.kr(0.4)), amp1, \ffreq.kr(90), \rq.kr(1.0)) * env1 * amp ;
		sig2 = RHPF.ar(Pulse.ar(freq2, \width.kr(0.4)), amp2, \ffreq.kr(90), \rq.kr(1.0)) * env2 * amp;
		sig1 = LPF.ar(sig1, \lpf.kr(120));
		sig2 = LPF.ar(sig2, \lpf.kr(120));
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

	SynthDef('delay', {
		var sig, wet;
		sig = In.ar(\in.ir(~fx2Bus), 2);
		sig = CombL.ar(sig, \maxdel.kr(0.6), \deltime.kr(0.8), \decayT.kr(3.0),\mul.kr(1.2));
		sig = LPF.ar(sig, 1200);
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
	s.options.numOutputBusChannels = 6;
	s.sync;

	t = TempoClock.new(90/60).permanent = true;

	/// Osc Section

	n = NetAddr("127.0.0.1", NetAddr.langPort); // local machine
	m = NetAddr("127.0.0.1", 5020); // beat send

	f = { |msg, time, addr|
		if(msg[0] != '/status.reply') {
			"time: % sender: %\nmessage: %\n".postf(time, addr, msg);
		}
	};
	//thisProcess.addOSCRecvFunc(f);
	// stop posting.
	thisProcess.removeOSCRecvFunc(f);
	OSCFunc.trace(false);

	~categories.do(
		{
			arg catName;
			OSCdef.new(
				catName.asSymbol,
				{ arg msg;
					var c;
					postf("\nnew cat: %", msg[1]);
					postf("\nnew count: %", msg[2]);
					~totalUtts = msg[3];
					postf("\n~totalUtts changed %\n", ~totalUtts);
					c = case
					{~totalUtts < 2} {~setRauschen.value(msg[3])}
					{~totalUtts >= 2} {~allocateSynth.value(msg[1], msg[2]); ~setRauschen.value(msg[3])}
					{true}{postf("\nend of cases %\n", ~totalUtts)};


				},
				catName
			);
	});

	OSCdef.new(
		\init,
		{arg msg;
			postf("\n init %\t", msg);
			msg[1].postln;
			Pbindef(\rausch).play(t, quant:1);
			~setRauschen.value(1)
		},
		'/init'
	);

	OSCdef.new(
		\common,
		{arg msg;
			postf("\n common % \t", msg);
			//~playCommon.value(msg[1]);
		},
		'/common'
	);

	CmdPeriod.add(s.freeAll);
	// https://composerprogrammer.com/teaching/supercollider/sctutorial/Technicalities/05%20Clocks%20and%20Scheduling.html
	// send beat
	t.schedAbs(t.nextTimeOnGrid, {m.sendMsg("/beat", (t.elapsedBeats.floor % 8).asInteger + 120); 1});


	~reset = (
		dissence: (
			instrument: 'dissence',
			atk:0.3,
			sus: 0.7,
			rls: 1.9,
			ampDist: 0.5,
			durDist: 1.0,
			minfreq: 400,
			maxfreq: 750,
			ffreq: 300,
			gendAmp: 0.2,
			rq: 0.9,
			freq:  110,
			pPhase: 0.0,
			width: 0.1,
			pulseMul: 0.2,
			amp: 0.3,
			pan:0.0,
			send: -30
		),

		lecture: (
			instrument: 'lecture',
			atk: 0.01,
			sus: 3.0,
			rls: 1.0,
			crv: -4.0,
			modRate: 1.2,
			det1: 0.99,
			det2: 1.01,
			freq: 41.2,
			filTime: 0.3,
			amp: 0.15,
			send: -30
		),

		insinuation: (
			instrument: 'insinuation',
			atk: 0.05,
			sustain: 0.5,
			rls: 0.4,
			freq: 220,
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
		freq: 440,
		bd: (buf: b[\bd][1], dur: 1),
		sn: (buf: b[\sn][0], dur: 3),
		dry: (buf: b[\dry][0], dur: 1),
		hh: (buf: Pxrand(b[\hh], inf), dur: 1.5),
		tonal: (buf: Pxrand(b[\tonal], inf), dur: Pwhite(0.1, 0.3, inf))
	)
);

~makeSynth = {
	|cat, count|
	var params, index;
	params = List.new;
	~reset[cat].keys.do({
		|k|
		params.addAll([k, ~reset[cat][k]])
	});
	params.asArray.postln;
	Synth(cat, params.asArray);
};


	Pbindef(\rausch,
		\instrument, \rauschen,
		\dur, t.tempo *4,
		\ffreq, Pseq([666, 150], inf),
		\pan, Pwhite(-1,1, inf),
		\amp, 0.8
	);
	Pbindef(\lecture,
		\instrument, \lecture,
		\dur, t.tempo *3,
		\midinote, 28,
		\filTime, 0.8,
		\sustain, Pseq((0.6, 0.58 .. 0.2).mirror, inf),
		\atk, 0.3,
		\rls, 2.5,
		\modRate, Pkey(\filTime) * 4,
		\amp, 0.4);


	Pbindef(\praise,
		\instrument, \praise,
		\dur, t.tempo /2,
		\ampHz , 0.1,
		\ampScale, 0.38,
		\midinote, Pwrand([20, 32, 22], [0.75, 0.15, 0.1], inf) + rrand(12, 24),
		\fMul, 2,
		\rnd, 0.999,
		\pulWidth, 0.9,
		\fRate, t.tempo *4.0,
		\width, Pwhite(0.05, 0.4, inf),
		\atk, 0.01,
		\rls, 0.36,
		\sustain, Pkey(\rls) + 0.1,
		\ffreq, 100,
		\rq, 0.9,
		\pulRate, 0.6,
		\lpf, Pn(Pseries(100, 80, 10), inf) +500,
		\outfx, ~fx1Bus,
		\send, -10,
		\amp, 0.1);

	Pbindef(\dissence,
		\instrument, \dissence,
		\dur, t.tempo /2,
		\freq, Pseq((1000,900 .. 100), inf),
		\pPhase, 0.3,
		\width, Pwhite(0.4, 1.7, inf),
		\pulseMul, 0.32,
		\atk, 0.03,
		\sus, 0.1,
		\rls, 0.08,
		\pan, Pwhite(-1, 1, inf),
		\ffreq, 200,
		\ampDist, Pxrand([0.2, 1.0, 1.9], inf),
		\durDist, Pwhite(0.1, 0.3, inf),
		\minfreq, Pkey(\freq),
		\maxfreq, Pkey(\minfreq) *2,
		\rq, 0.9,
		\gendmul, 0.9,
		\send, -12,
		\amp, 0.7);

	Pbindef(\insinuation,
		\instrument, \insinuation,
		\dur, Pxrand([2.0, 4.0, 6.0], inf),
		\amp, 0.4,
		\midinote, Pxrand([[37, 49, 61], [32, 45, 58]], inf) ,
		\ffreq, 10.0,
		\modWidth, 0.9,
		\preamp, 0.3,
		\noisFreq, Pwrand([0.05, 0.5, 0.9], [0.8, 0.15, 0.05], inf),
		\maxF, 600,
		\atk, 0.13,
		\rls, 0.2,
		\sustain, 1,
		\slideTime, 4.2,
		\fShift, Pkey(\midinote).midicps);

	Pbindef(\concession,
		\instrument, \concession,
		\buf, Prand(b[\tonal], inf),
		\dur, t.tempo,
		\rate, Pwhite(0.2, 1.8, inf),
		\pan, Pwhite(-0.5, 0.5, inf),
		\amp, 0.8,
		\lpf, Pseq((220, 270 .. 1270), inf),
		\outfx, ~fx1Bus,
		\send, Pseq((-35, -30 .. -10), inf));

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
// test
// http://sc3howto.blogspot.com/2010/06/pfunc.html  beispiel für ein Fade



Pbindef(\praise).trace.play(t, quant:1);
Pbindef(\praise, \amp, Pfunc({~fadeIn.value('praise', 1.1, 0.4)}));
Pbindef(\praise, \amp, Pfunc({~fadeOut.value('praise', 0.99, 0.03)}));


Pbindef(\praise).stop;
Pbindef(\praise, \amp, Pgeom(0.01, 1.01, inf));
Pbindef(\praise).stop
Pbindef(\dissence).play(t, quant:1);
Pbindef(\dissence, \amp, Pgeom(0.4, 0.99, inf));
Pbindef(\dissence, \freq, Pkey(\freq))
Pbindef(\dissence).stop
Pbindef(\lecture).play(t, quant:1);
Pbindef(\lecture, \amp, 0.3);
Pbindef(\lecture, \midinote, Pxrand([28, 35, 40, 52, 47], inf));
Pbindef(\lecture).stop
Pbindef(\insinuation).play(t, quant:1);
Pbindef(\insinuation, \amp, Pgeom(0.5, 0.93, inf), \rls, 3.3);
Pbindef(\insinuation).stop
Pbindef(\concession).play(t, quant:1);
Pbindef(\concession, \amp, 0.4);
Pbindef(\concession).stop



b[\dry][0].play;
~synthDict['dissence']

/// set functions
(
~setDissence = {
	|s_name, count|
	var c, dura, now, syn, sl, amp;
	amp = 0.03 * count;
	postf("\nsetting %\t with count %\n and amp %\n", s_name, count, amp);
	dura = Env.new([1,0], [count], [-2]).asPseg;
	sl = ~synthDict['dissence'];
	if (sl.size > 0, {~stopList.value(sl)});
	c = case
	{(count > 0) && (count < 10)} {
		count.do({
			sl.add(Synth(\dissence,
				[\width, exprand(0.4, 0.9), \freq, exprand(200, (200 + count)), \amp, amp, \rls, 10]))
		});
		~fadeOut.(sl, amp);
	}
	{count >= 10 } {
		var syn;
		now = Routine({
			5.do({
				var f =rrand(300, 666);
				sl.add(Synth(\dissence, [\freq, f, \minfreq, f *2,  \atk, 0.6, \rls, 2]));
				2.wait;
			})
	})}
	{true} {"end of dissence reached".postln};


};

~setInsinuation = {
	|s_name, count|
	var c, dura, now, base;
	postf("\nsetting %\t with count %\n", s_name, count);
	base = ~reset[\insinuation03].value;
	dura = Env.new([1,0], [count], [-2]).asPseg;
	c = case
	{(count > 0) && (count < 5)} {
		var syn;
		now = Routine.new({
			count.do({
				syn = Synth(\insinuation, [\freq, 60 * count, \modWidth, 0.2 * count.reciprocal, \fShift, 12 * count, \outfx, ~fx2Bus, \send, -10.dbamp]);
				0.8.wait;
		})})
	}
	{(count >= 5) && (count < 10) } {
			now = Pbind(\instrument, \insinuation, \dur, Pseq([3.0, 4.0], count), \rls, Pkey(\dur, count) *1.2, \atk, Pseq([0.1, 0.7], count), \amp, 0.4).trace}
	{(count >= 5) && (count < 10) } {
		now = Pbind(\instrument, \insinuation, \dur, Prand([2.0, 4.0], count ), \midinote, Pxrand([37, 49], count), \rls, Pkey(\dur) * 0.4, \atk, 0.8, \noisFreq, 9.0).trace}
	{count >= 10 } {
		now = Pbind(\instrument, \insinuation, \dur, 0.8, \rls,0.4, \midinote, Pseq([24,48], count), \atk, Pseq([0.1, 0.7], count)).trace}
	{true} {"end of insinuation reached".postln};
	if(~insinuationPlay.isPlaying, {~insinuationPlay.stop});
	//postf("\n% running after %\t \n", s_name, ~insinuationNow.isPlaying);
	~insinuationPlay = now.play(t, quant:1);

};
~setLecture = {
	|s_name, count|
	var c, dura, base, now;
	postf("\nsetting %\t with count %\n", s_name, count);
	dura = Env.new([1,0], [count], [-2]).asPseg;
	base = ~reset[\lecture02].value;
	c = case
	{(count > 0) && (count < 2)} {now = Pbindf(base, \amp, Pkey(\amp)*dura)}
	{(count >=2) && (count < 5)} {
		now = Pbindf(base, \dur, 0.5, \midinote, Pn([28, (28 + (12 * count))], count), \atk, Pkey(\dur) /4).trace;
		Pbindef(\lec, \modRate, 0.8 + count.reciprocal, \midinote, Pn([28, (28 + (12 * count))]), \amp, 0.4);
	}
	{(count >= 5) && (count < 10) } {
		now = Pbindf(base, \dur, Pwrand([0.25, 0.5], [0.8, 0.2], count), \midinote, Pseq([(28, 40 .. 100).mirror, 40], count),  \atk, Pkey(\dur) /4, \amp, 0.2).trace;
		Pbindef(\lec, \det1, 0.99 - (count /300), \det2, 1.01 + (count/300), \midinote, Pn([40, 52]));
	}
	{(count >= 10) && (count < 30) } {
		now = Pbindf(base, \dur, Pn(0.25, count), \midinote, Pn([Pxrand([28, 40, 52, 29, 41, 53]), 40], count), \atk, 0.1, \rls, 0.2, \amp, 0.6).trace;
		Pbindef(\lec, \det1, 0.99 - (count /300), \det2, 1.01 + (count/300), \amp, Pseq((0.4, 0.39 .. 0.15).mirror, inf) )
	}

	{true} {"end of lecture reached".postln;};
	if(~lecturePlay.isPlaying, {~lecturePlay.stop});
	~lecturePlay = now.play(t, quant:0);

};
~setConcession = {
	|s_name, count|
	var c, dura, now, basePats;
	postf("\nsetting %\t with count %\n", s_name, count);
	dura = Env.new([1,0], [count], [-2]).asPseg;
	basePats = ~reset[\concession04].value;
	c = case
	{count.even} {
		now = Pbindf(basePats[\tonal], \buf, Pseq([b[\tonal][6], Pn(b[\tonal][2], 7)], inf), \dur, t.tempo, \amp, 0.7 * dura)}
	{count.odd } {
			var tonal;
		tonal = Pbind(\instrument, \concession, \buf, b[\tonal][9], \dur, Pseq((0.8,0.78 ..0.04), 1), \rate, Pseries(1.3, 0.15, count), \send, Pseq((-30, -28 .. -12),inf), \amp, 0.7);
			now = Ppar([ tonal])}
	{true} {"end of insinuation reached".postln;};
	if(~concessionPlay.isPlaying, {~concessionPlay.stop});
	//postf("\n% running after %\t \n", s_name, ~concessionNow.isPlaying);
	~concessionPlay =  now.play(t, quant:1);

};
~setPraise = {
	|s_name, count|
	var c, sl, now, dura, amp;
	postf("\nsetting %\t with count %\n", s_name, count);
	amp = 0.03 * count;
	dura = Env.new([1,0], [count], [-2]).asPseg;
	sl = ~synthDict['praise'];
	c = case
	{(count > 0) && (count < 2)} {

	}

	{(count >= 2) && (count < 10)} {
		count.do({
			sl.add(Synth(\praise,
				[\freq, 40, \fMul, count, \amp, amp]))
		});
		~fadeOut.(sl, amp);
	}
	{(count >= 10) && (count < 20) } {
		now = Pbindf(base, \dur, Pn(4, count), \detune, Pseries(1.6, -0.3, inf), \lpf, Pseries(500, 50, count), \midinote, Prand([32,36, 24], count), \amp, Pkey(\amp) * dura);
		Pbindef(\praise, \fMul, 1+ count, \detune, Pseq((1.2 ,1.18 .. 0.8).mirror, inf), \rls, Pseq((0.36, 0.35 .. count.reciprocal).mirror, inf))
	}
	{(count >= 10) && (count < 30) } {
		now = Pbindf(base, \dur, Pseq((0.4, 0.38 .. 0.1).reverse.mirror, count), \detune, Pwhite(0.95, 1.05, inf), \midinote, Pseq([24, 36], count) + count, \lpf, Pseries(400, 80, count), \amp, Pkey(\amp) * dura, \outfx, ~fx2Bus, \send, Pseq((-35, -33 .. -5), count)).trace}
	{true} {"end of insinuation reached".postln;};
	//if(~praisePlay.isPlaying, {~praisePlay.stop});
	postf("\n% running after %\t \n", s_name, ~praiseNow.isPlaying);
	~praisePlay = now.play(t, quant:1);
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
~playCommon = {
	|s_name|
	var c;

	postf("\nallocation common  %\t ", s_name);
	c = case
	{s_name == \lecture} {Pbindef(\lecture).play(t, quant:3)}
	{s_name == \praise} {Pbindef(\praise).play(t, quant:3)}
	{s_name == \dissence} {Pbindef(\dissence).play(t, quant:3)}
	{s_name == \insinuation} {Pbindef(\insinuation).play(t, quant:3)}
	{s_name == \concession} {Pbindef(\concession).play(t, quant:3)}
	{true} {"end of play allocation".postln};
	if (s_name != ~commonNow, {Pbindef(~commonNow).stop;
		~commonNow = s_name
	});
};

~setCommon = {
	|s_name, count|
	var c;
	postf("\nset common  with name \t  % and count % ", s_name,count);
	//ausschliessen dass ~commonNow Pbindef(~commonNow) beschickt
	c = case
	{s_name == \lecture} {Pbindef(\lecture, \modRate, count )}
	{s_name == \praise} {Pbindef(\praise, \fMul, count )}
	{s_name == \dissence} {Pbindef(\dissence, \ffreq, 200 + (count * 30) )}
	{s_name == \insinuation} {Pbindef(\insinuation, \noisFreq, count.reciprocal)}
	{s_name == \concession} {Pbindef(\concession, \rate, Pwhite(0.2, 1.8, inf) * (count/15))}
	{true}{"end of setCommon".postln};
};

)

Synth(\rauschen, [\ffreq, 500])

currentEnvironment
Pbindef(\lec).play(t, quant:1);
Pbindef(\concession).stop;
Pbindef(\rausch).stop;
~setDissence.('dissence',2);
~setInsinuation.value('insinuation', 6);
~setLecture.value('lecture', 11);
~setConcession.value('concession', 17);
~setPraise.value('praise', 13);
(
~rauschenNow = ~reset[\rauschen].value;
~rauschenPlay = ~rauschenNow.play(t, quant:1)
)

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
(
~stopList = {arg list;
	postf("\nstopped list \t  % ", list);
	list.do{|s| s.set(\gate,0) };
	list.clear;
};
)
