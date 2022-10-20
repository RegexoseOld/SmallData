(
~synthLoad = {

    SynthDef.new(\bell1, {
        // a long bell
        |gate=1|
        var sig, env, volMod, trem;
        env = EnvGen.kr(Env.linen(\atk.kr(3.1), \sus.kr(1), \rls.kr(3.1), curve:\crv.kr(10)), gate, doneAction:2);
        volMod = SinOsc.kr(\modF.kr(1), 0, 0.5)  ; // vol modulation
        trem = Vibrato.kr(\vibF.kr(1), \vibRate.kr(2), \dep.kr(0.0), \del.kr(1), \onset.kr(2), \rateVar.kr(0.5), \varDur.kr(1) );
        sig = SinOsc.ar(\freq.kr(100) * trem, 0, 0.5 + volMod );
        sig = Pan2.ar(sig * env * \amp.kr(0.1), \pan.kr(0.0));
        Out.ar(\out.ir(0), sig);
    }).add;

    SynthDef(\sampSt, {
        var sig, env;
        sig = PlayBuf.ar(2, \buf.kr(0), \rate.kr(1) *BufRateScale.kr(\buf.kr(0)), \trig.kr(1), \spos.kr(0), loop:0);
        //die Env muss wohl .ar sein, um bufnums austauschen zu können
        env = EnvGen.kr(Env.linen(\atk.kr(0.01), \sus.kr(1), \rls.kr(1), level: \amp.kr(0.2)), doneAction: 2);
        sig = sig * \fade.kr(1);
        Out.ar(\out.kr(0), sig) ;
    }).add;

    SynthDef(\sampMon, {
        var sig, env;
        sig = PlayBuf.ar(1, \buf.kr(0), \rate.kr(1) *BufRateScale.kr(\buf.kr(0)), \trig.kr(1), \spos.kr(0));
        env = EnvGen.kr(Env.linen(\atk.kr(0.01), \sus.kr(1), \rls.kr(1), level: \amp.kr(0.2)), doneAction: 2);
        sig = sig * env * \fade.kr(1);
        sig = Pan2.ar(sig, \pan.kr(0));
        Out.ar(\out.kr(0), sig) ;
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

}

)