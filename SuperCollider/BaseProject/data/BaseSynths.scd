

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
    |gate=1, freq=100, index=1, mRatio=1, cRatio=1, atk=0.4, rls=2, crv= 5, bpf=100|
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

SynthDef.new(\bell2, {
    // a short bell.
    var sig, env;
    env = EnvGen.kr(Env.perc(\atk.kr(0.04), \rls.kr(0.6), 1, \crv.kr(-8)), doneAction:2);
    sig = SinOsc.ar(\freq.kr(100), 0, \fade.kr(0.5));
    sig = Pan2.ar(sig * env * \amp.kr(0.1), \pan.kr(0.0));
    Out.ar(\out.kr(0), sig);
}).add;

SynthDef.new(\quitt, {
    var sig, gend, env;
    env = EnvGen.kr(Env.perc(\atk.ir(0.1), \rls.kr(1)), doneAction:2);
    gend = Gendy1.ar(\ampDist.kr(1), \durDist.kr(1), 1.0, 1.0, \minfreq.kr(100), \maxfreq.kr(1000), 1.0, 0.05, 5);
    gend = BPF.ar(gend, \ffreq.kr(300), \rq.kr(0.9), \gendAmp.kr(1))  ;
    sig = LFPulse.ar(\freq.kr(100).varlag(\lag.kr(0.3), \lagcrv.kr(5.0)), 0.0, \width.kr(0.4),\pulseMul.kr(0.15), \add.kr(0)) ;
    sig = sig + gend;
    sig = Compander.ar(sig, sig, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(3));
    sig = Pan2.ar(sig * env * (\amp.kr(0.1)), \pan.kr(0.0));
    Out.ar(\out.ir(0), sig);
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
    Out.ar(0, sig);

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
    Out.ar(0, sig!2);

}).add;
SynthDef.new(\musar2, {
    |gate = 1|
    var detune, sig, env, mod, ampMod;
    env = EnvGen.kr(Env.adsr(\atk.kr(0.01), 0.2, \sus.kr(0.99), \rls.kr(1.0), curve:\crv.kr(-4.0)), gate, doneAction: 2);
    mod = SinOsc.kr(\modRate.kr(1.2));
    sig = VarSaw.ar(\freq.kr(100), 0, LFCub.kr(\filTime.kr(0.3)));
    sig = (sig * \distort.kr(1.5)).tanh;
    sig = sig * env * mod ;
    sig = Compander.ar(sig, sig, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(0));
    sig = Pan2.ar(sig * (\amp.kr(0.1) * \fade.kr(1)), \pan.kr(1));
    Out.ar(0, sig );
    //Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-30).dbamp);
}).add;

SynthDef.new(\impulse, {
    var channels, temp, env, vol, sig, sweep;
    env = EnvGen.kr(Env.perc(\atk.kr(0.01), \rls.kr(0.4), 1.0, \crv.kr(-1.0)));
    vol = \amp.kr(0.1) * \fade.kr(1);
    channels = {
        temp = Impulse.ar(\dens.kr(1), 0.0, \knk.kr(1.0) );
        temp = FreqShift.ar(temp, \shift.kr(0));
        temp = BPF.ar(temp, \eqfr1.kr(2300) , 1.0, \boost.kr(1.6));
        temp = Compander.ar(temp, temp, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(2.3));
    }!2 ;
    sig = Splay.ar(channels, center: \cent.kr(0.0), level:vol);
    Out.ar(0, sig);
    Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-32).dbamp);
}).add;

SynthDef(\sampSt, {
    var sig, env;
    sig = PlayBuf.ar(2, \buf.kr(0), \rate.kr(1) *BufRateScale.kr(\buf.kr(0)), \trig.kr(1), \spos.kr(0), loop:0);
    //die Env muss wohl .ar sein, um bufnums austauschen zu können
    env = EnvGen.kr(Env.linen(\atk.kr(0.01), \sus.kr(1), \rls.kr(1), level: \amp.kr(0.2)), doneAction: 2);
    sig = Compander.ar(sig, sig, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(1));
    sig = BPF.ar(sig, \bpf1.kr(100), \bpfQ.kr(0.3));
    sig = sig * \amp.kr(0.2) * \fade.kr(1);
    Out.ar(\out.kr(0), sig) ;
    Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-30).dbamp);
}).add;

SynthDef(\sampMon, {
    var sig, env;
    sig = PlayBuf.ar(1, \buf.kr(0), \rate.kr(1) *BufRateScale.kr(\buf.kr(0)), \trig.kr(1), \spos.kr(0));
    env = EnvGen.kr(Env.linen(\atk.kr(0.01), \sus.kr(1), \rls.kr(1), level: \amp.kr(0.2)), doneAction: 2);
    sig = sig * env * \fade.kr(1);
    sig = Pan2.ar(sig, \pan.kr(0));
    Out.ar(\out.kr(0), sig) ;
    Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-30).dbamp);
}).add;

SynthDef(\brPhsr, {
    arg buf, rate=1, start, end, out=0, freq=1;
    var sig, ptr, env;
    ptr = Phasor.ar(0, BufRateScale.kr(buf)* rate, start, end);
    env = EnvGen.kr(Env.linen(\atk.kr(0.01), \sus.kr(1), \rls.kr(1), level: \amp.kr(0.6)), doneAction: 2);
    sig = BufRd.ar(1, buf, ptr);
    sig = sig * env;
    Out.ar(out, sig!2);
}).add;

SynthDef(\percImp, { |out, accent=0, decayScale=1|
    var exc = PinkNoise.ar(\carAmp.kr(0.1))
    * Decay2.kr(Impulse.kr(0), 0.01, 0.05),
    sig = Klank.ar(`[
        { ExpRand(\minfrq.kr(80), 1600) } ! 2,
        1 ! 2,
        { ExpRand(0.1, 0.4) } ! 2
    ], exc, accent + 1, \frqOff.kr(0.0), decayScale); // accent ist die höhe, decayScale die Länge des Sounds
    DetectSilence.ar(sig, doneAction: Done.freeSelf);
    sig = Pan2.ar(sig * \amp.kr(0.1) * \fade.kr(1.0), \pan.kr(0.0));
    Out.ar(out, sig);
    Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-32).dbamp);
}).add;

SynthDef('reverb', {
    var sig, wet;
    sig = In.ar(\in.ir(~fx1Bus), 2);
    sig = FreeVerb2.ar(sig[0], sig[1], mix:\mx.kr(0.5), room:\room.kr(0.99), damp:\damp.kr(0.99));
    sig = BPF.ar(sig, SinOsc.kr(\bpf.kr(0.001), 0, \lofr.kr(100), \hifr.kr(250)));
    sig = Compander.ar(sig, sig, \thr.kr(0.65), 1, 0.3, 0.3, 0.4, \cgain.kr(2));
    Out.ar(\out.ir(0), sig);
}).add;

