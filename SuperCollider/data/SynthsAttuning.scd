(
~synthLoad = {

    SynthDef.new(\bell1, {
        // a long bell
        |gate=1|
        var sig, env, volMod, trem;
        env = EnvGen.kr(Env.linen(\atk.kr(3.1), \sus.kr(1), \rls.kr(3.1), curve:\crv.kr(10)), gate, doneAction:2);
        volMod = SinOsc.kr(\vibF.kr(1), 0, \vibVol.kr(1))  ; // vol modulation
        trem = Vibrato.kr(\trmF.kr(1), \trmRate.kr(2), \trmDep.kr(0.0), \trmDel.kr(1), \onset.kr(2), \rateVar.kr(0.5), \varDur.kr(1) );
        sig = SinOsc.ar(\freq.kr(100).varlag(\lag.kr(0)) * trem, 0, (\fade.kr(0.5) + volMod));
        sig = Pan2.ar(sig * env * \amp.kr(0.1) * \fade.kr(0.5), \pan.kr(0.0));
        Out.ar(\out.kr(0), sig);
    }).add;

    SynthDef.new(\bell2, {
        // a short bell
        var sig, env;
        env = EnvGen.kr(Env.perc(\atk.kr(0.04), \rls.kr(0.6), 1, \crv.kr(-8)), doneAction:2);
        sig = SinOsc.ar(\freq.kr(100), 0, \fade.kr(0.5));
        sig = Pan2.ar(sig * env * \amp.kr(0.1), \pan.kr(0.0));
        Out.ar(\out.kr(0), sig);
    }).add;

  SynthDef.new(\musar2, {
		|gate = 1|
		var detune, sig, env, mod, ampMod;
		env = EnvGen.kr(Env.adsr(\atk.kr(0.01), 0.2, \sus.kr(0.99), \rls.kr(1.0), curve:\crv.kr(-4.0)), gate, doneAction: 2);
		mod = SinOsc.kr(\modRate.kr(1.2));
		sig = VarSaw.ar(\freq.kr(100), 0, LFTri.kr(\filTime.kr(0.3)));
		sig = (sig * \distort.kr(1.5)).tanh;
		sig = sig * env * mod ;
		sig = Compander.ar(sig, sig, \thr.kr(0.35), 1, 0.3, 0.3, 0.4, \cgain.kr(0));
		sig = Pan2.ar(sig * (\amp.kr(0.1) * \fade.kr(1)), \pan.kr(1));
		Out.ar(0, sig );
		Out.ar(\outfx.kr(~fx1Bus), sig * \send.kr(-30).dbamp);
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