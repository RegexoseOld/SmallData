(
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

)