SynthDef.new(\bell1, {
    // a long bell
    // ist es möglich eine rückwärts sound über Patterns zu erreichen?
    //
    |gate=1|
    var sig, sig2, env, volMod, trem;
    env = EnvGen.kr(Env.linen(\atk.kr(0.4), \sus.kr(1), \rls.kr(1), curve:\crv.kr(10)), gate, doneAction:2);
    volMod = SinOsc.kr(\vibF.kr(1), 0, \vibVol.kr(1))  ; // vol modulation
    trem = Vibrato.kr(\trmF.kr(1), \trmRate.kr(2), \trmDep.kr(0.0), \trmDel.kr(1), \onset.kr(2), \rateVar.kr(0.5), \varDur.kr(1));
    sig2 =  LFSaw.ar(\freq.kr(100).varlag(\lag.kr(0)) , 0,  volMod);
    sig = SinOsc.ar(\freq.kr(100).varlag(\lag.kr(0)), 0,  volMod);
    sig = (sig * \fade.kr(0.5)) + (sig2 * \sig2Fade.kr(0.2));
    sig = Compander.ar(sig, sig, \thr.kr(0.65), 1, 0.3, 0.3, 0.4, \cgain.kr(1));
    sig = BPF.ar(sig, XLine.kr(\bpf1.kr(100), \bpf1.kr(100) * 8, \bpf3.kr(0.5)), \bpfQ.kr(0.3));
    //sig = BPF.ar(sig, \bpf1.kr(100), \bpfQ.kr(0.3));
    sig = Pan2.ar(sig * env * \amp.kr(0.1) , \pan.kr(0.0));
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef.new(\bellFm, {
    // Fm so wie https://www.youtube.com/watch?v=dLMSR2Kjq6Y -> 11:30
    //
    |freq=100, index=1, mRatio=1, cRatio=1, atk=0.4, rls=2, crv= 5, bpf=100|
    var sig, sig2, env, volMod, trem;
    env = EnvGen.kr(Env.perc(atk, rls, curve: crv), doneAction:2);
    volMod = SinOsc.kr(\vibF.kr(0.2), 0, \vibVol.kr(30))  ; // vol modulation
    trem = Vibrato.kr(\trmF.kr(1), \trmRate.kr(2), \trmDep.kr(0.0), \trmDel.kr(1), \onset.kr(2), \rateVar.kr(0.5), \varDur.kr(1));

    sig2 =  SinOsc.ar(freq * mRatio, mul:freq * mRatio * index);
    sig = SinOsc.ar(freq * cRatio  + sig2 , mul: volMod);
    sig = sig * \fade.kr(1) ;
    sig = Compander.ar(sig, sig, \thr.kr(0.65), 1, 0.3, 0.3, 0.4, \cgain.kr(1));
    sig = BPF.ar(sig, XLine.kr(bpf, bpf * \bpf2.kr(5), \bpf3.kr(0.2)), \bpfQ.kr(0.9), \bpfMul.kr(2));
    //sig = BPF.ar(sig, \bpf1.kr(1000), \bpfQ.kr(0.9));
    sig = Pan2.ar(sig * env * \amp.kr(0.1) ,\pan.kr(0.0));
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef.new(\quitt, {
    var sig, gend, env;
    env = EnvGen.kr(Env.perc(\atk.ir(0.1), \rls.kr(1)), doneAction:2);
    gend = Gendy1.ar(2, \durDist.kr(1), 1.0, 1.0, \minfreq.kr(100), \maxfreq.kr(1000), 1.0, 0.05, 5);
    gend = BPF.ar(gend, \ffreq.kr(300), \rq.kr(0.9), \gendAmp.kr(1))  ;
    sig = LFPulse.ar(\freq.kr(100).varlag(\lag.kr(0.3), \lagcrv.kr(5.0)), 0.0, \width.kr(0.4),\pulseMul.kr(0.15), \add.kr(0)) ;
    sig = sig + gend;
    sig = Compander.ar(sig, sig, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(3));
    sig = Pan2.ar(sig * env * (\amp.kr(0.1)), \pan.kr(0.0));
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef.new(\bwack, {
    var sig, mod, env, dura, part;
    dura = \dura.kr(1);
    part = \part.kr(0.05);
    mod = EnvGen.kr(Env.perc(dura-part, part, 1.0, 4), doneAction:0);
    sig = LFSaw.ar(\freq.kr(100)) + BrownNoise.ar(\noiseLev.kr(0.8));
    env = EnvGen.kr(Env.perc(part, dura - part, 1, \crv.kr(2)), doneAction:2);
    //sig = Compander.ar(sig, sig, \thr.kr(0.65), mul:\cgain.kr(1));
    sig = BPF.ar(sig, \bpfFactor.kr(3000) * mod);
    sig = Pan2.ar(sig * env * \amp.kr(0.2), \pan.kr(0));
    Out.ar(\out.kr(0), sig);

}).add;

SynthDef.new(\bwawack, {
    var sig, mod, env, dura, part;
    dura = \dura.kr(1);
    part = \part.kr(0.05);
    mod = SinOsc.kr(\freqMod.kr(2), 0.0, 0.9, 1);
    sig = LFSaw.ar(\freq.kr(100)) + WhiteNoise.ar(\noiseLev.kr(0.8));
    env = EnvGen.kr(Env.perc(part, dura - part, 1, \crv.kr(8)), doneAction:2);
    sig = Compander.ar(sig, sig, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(1));
    sig = BPF.ar(sig, \freq.kr(100) + (\bpfFactor.kr(100) * mod) );
    sig = Pan2.ar(sig * env * \amp.kr(0.2), \pan.kr(0));
    Out.ar(\out.kr(0), sig!2);

}).add;
SynthDef.new(\bass, {
    |gate = 1|
    var detune, sig, env, mod, ampMod;
    env = EnvGen.kr(Env.adsr(\atk.kr(0.01), 0.2, \sus.kr(0.99), \rls.kr(1.0), curve:\crv.kr(-4.0)), gate, doneAction: 2);
    mod = SinOsc.kr(\modRate.kr(1.2));
    sig = VarSaw.ar(\freq.kr(100), 0, LFCub.kr(\filTime.kr(0.3)));
    sig = (sig * \distort.kr(1.5)).tanh;
    sig = sig * env * mod ;
    sig = Compander.ar(sig, sig, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(0));
    sig = Pan2.ar(sig * (\amp.kr(0.1) * \fade.kr(1)), \pan.kr(1));
    Out.ar(\out.kr(0), sig );
    //Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-30).dbamp);
}).add;

// simple electro kick drum
SynthDef(\kik, { |basefreq = 50, envratio = 3, freqdecay = 0.02, ampdecay = 0.5, outbus = 0|
   var   fenv = EnvGen.kr(Env([envratio, 1], [freqdecay], \exp)) * basefreq,
      aenv = EnvGen.kr(Env.perc(0.005, ampdecay), doneAction:2);
   Out.ar(outbus, SinOsc.ar(fenv, 0.5pi, aenv));
}).add;

SynthDef.new(\impulse, {
    var channels, temp, env, vol, sig, sweep;
    env = EnvGen.kr(Env.perc(\atk.kr(0.01), \rls.kr(0.4), 1.0, \crv.kr(-1.0)));
    vol = \amp.kr(0.1) * \fade.kr(0.5);
    channels = {
        temp = Impulse.ar(\dens.kr(1), 0.0, \knk.kr(1.0) );
        temp = FreqShift.ar(temp, \shift.kr(0));
        temp = BPF.ar(temp, \eqfr1.kr(2300) , 1.0, \boost.kr(1.6));
        temp = Compander.ar(temp, temp, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(2.3));
    }!2 ;
    sig = Splay.ar(channels, center: \cent.kr(0.0), level:vol);
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\sampSt, {
    var sig, env;
    sig = PlayBuf.ar(2, \buf.kr(0), \rate.kr(1) *BufRateScale.kr(\buf.kr(0)), \trig.kr(1), \spos.kr(0), loop:0);
    //die Env muss wohl .ar sein, um bufnums austauschen zu können
    env = EnvGen.kr(Env.linen(\atk.kr(0.01), \sus.kr(1), \rls.kr(1)), doneAction: 2);
    sig = Compander.ar(sig, sig, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(1));
    sig = BPF.ar(sig, \bpf1.kr(100), \bpfQ.kr(0.3));
    sig = sig * \amp.kr(0.2) * \fade.kr(1);
    Out.ar(\out.kr(0), sig) ;
}).add;

SynthDef(\sampMon, {
    var sig, env;
    sig = PlayBuf.ar(1, \buf.kr(0), \rate.kr(1) *BufRateScale.kr(\buf.kr(0)), \trig.kr(1), \spos.kr(0), \loop.kr(0.0));
    env = EnvGen.kr(Env.linen(\atk.kr(0.01), \sus.kr(1), \rls.kr(1), level: \amp.kr(0.2)), doneAction: 2);
    sig = sig * env * \fade.kr(1);
    sig = Pan2.ar(sig, \pan.kr(0));
    Out.ar(\out.kr(0), sig) ;
}).add;

SynthDef(\brPhsr, {
    arg buf, rate=1, start, end, freq=1;
    var sig, ptr, env;
    ptr = Phasor.ar(0, BufRateScale.kr(buf)* rate, start, end);
    env = EnvGen.kr(Env.linen(\atk.kr(0.01), \sus.kr(1), \rls.kr(1), level: \amp.kr(0.6)), doneAction: 2);
    sig = BufRd.ar(1, buf, ptr);
    sig = sig * env;
    Out.ar(\out.kr(0), sig!2);
}).add;

SynthDef(\percImp, { |accent=0, decayScale=1|
    var exc = PinkNoise.ar(\carAmp.kr(0.1))
    * Decay2.kr(Impulse.kr(0), 0.01, 0.05),
    sig = Klank.ar(`[
        { ExpRand(\minfrq.kr(80), 1600) } ! 2,
        1 ! 2,
        { ExpRand(0.1, 0.4) } ! 2
    ], exc, accent + 1, \frqOff.kr(0.0), decayScale); // accent ist die höhe, decayScale die Länge des Sounds
    DetectSilence.ar(sig, doneAction: Done.freeSelf);
    sig = Pan2.ar(sig * \amp.kr(0.1) * \fade.kr(1.0), \pan.kr(0.0));
    Out.ar(\out.kr(0), sig);
}).add;

// wavetable https://www.youtube.com/watch?v=5krJVMxCr8s&t=810s ab 31:00 (für Feedback) und 46:30 für pad sound



// building Effect Instruments
// http://www.dewdrop-world.net/sc3/tutorials/index.php?id=5
//Spec.specs.asSortedArray.do(_.postcs)

Instr(#[\busfx, \ring1], { arg bus, numChan, freq, mod_amp, xfade;
   var sig, new;
   sig = In.ar(bus, numChan);
   new = sig * SinOsc.ar(freq, 0, mod_amp);
   XFade2.ar(sig, new, xfade * 2 - 1)
}, [\audiobus, ObjectSpec(2), \freq, \amp, \amp]
);

Instr(#[\busfx, \chorus], { arg bus, numChan, predelay, speed, depth, ph_diff, xfade;
   var in, sig;
   in = In.ar(bus, numChan);
   in.isKindOf(Collection).if({
      sig = in.collect({ arg ch, i;   // ch is one channel
         DelayL.ar(ch, 0.5, SinOsc.kr(speed, ph_diff * i, depth, predelay));
      });
   }, {
      sig = DelayL.ar(in, 0.5, SinOsc.kr(speed, ph_diff, depth, predelay));
   });
   XFade2.ar(in, sig, xfade * 2 - 1);
//   xf.value(in, sig, xfade)      // when felix has XOut working, this can be better
}, [\audiobus, ObjectSpec(1), #[0.0001, 0.4, \linear, 0, 0.1],
   #[0.001, 20, \exponential], #[0.0001, 0.25, \exponential], #[0, 2pi], #[0, 1]]);


Instr(#[\busfx, \companderd], { arg bus, numChannels, thresh, slopeBelow, slopeAbove,
      clampTime, relaxTime, postGain;
   var sig;
   sig = In.ar(bus, numChannels);
   CompanderD.ar(sig, thresh, slopeBelow, slopeAbove, clampTime, relaxTime, postGain);
}, [\audiobus, ObjectSpec(2), #[0, 1, \linear, 0, 0.5], #[0.1, 10, \exponential, 0, 1],
   #[0.1, 10, \exponential, 0, 1], #[0.001, 5, \exponential], #[0.001, 5, \exponential],
   #[0.1, 10, \exponential, 0, 1]]);

Instr(#[\busfx, \singleDelay], { arg bus, numChan, delayClass, maxTime, time, mul, add;
   delayClass.ar(In.ar(bus, numChan), maxTime, time, mul, add)
}, [\audiobus, ObjectSpec(1), ObjectSpec(DelayL), #[0.25, 20], #[0.0001, 20]]
);

//more a delay than reverb
Instr(#[\busfx, \rvb_allpass], { arg bus, numChan, maxDelay, preDelay, decay,
      numRefl, random;
   var sig, new;
   sig = In.ar(bus, numChan);
   new = sig;
   numRefl.do({
      new = AllpassN.ar(new, maxDelay, Array.fill(numChan, { random.rand }) + preDelay, decay);
   });
   new
}, [\audiobus, ObjectSpec(2), #[0.25, 2], #[0.4, 1.5, \exponential, 0, 0.05],
   #[0.01, 10, \exponential, 0, 0.25], ObjectSpec(4), #[0.001, 1, \exponential, 0, 0.03]]
);
 // specifications are ControlSpecs, which can be defined in a shortcut syntax using an array: [low value, high value, warp style, step size, default]
Instr(#[\busfx, \vrb1], { arg bus, numChan, room, damp, mult;
   var sig, new;
   sig = In.ar(bus, numChan);
   sig = FreeVerb.ar(sig, 1, room, damp, mult);
}, [\audiobus, ObjectSpec(2), #[0.1, 1.0, \linear, 0, 0.85], #[0.1, 1.0, \exponential, 0, 0.5],  #[1, 10, \exponential, 0, 7.5]]
);

Instr(#[\busfx, \limiter], { arg bus, numChannels, level, lookAhead, gain;
   Limiter.ar(In.ar(bus, numChannels), level, lookAhead) * gain;
}, [\mybuf, ObjectSpec(2), #[0, 1, \linear, 0, 1], #[0.001, 0.2],
   #[0.1, 4, \exponential, 0, 1]]
);

