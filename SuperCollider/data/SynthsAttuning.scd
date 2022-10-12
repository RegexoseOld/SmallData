(
~synthLoad = {
	    SynthDef.new(\bell1, {
        // a long bell
        |gate=1|
        var sig, env, volMod, trem;
        env = EnvGen.kr(Env.adsr(\atk.kr(3.1), 0.2, 1, \rls.kr(3.1), curve:\crv.kr(10)), gate, doneAction:2);
        volMod = SinOsc.kr(\modF.kr(1), 0, 0.5)  ; // vol modulation
        trem = Vibrato.kr(\vibF.kr(1), \vibRate.kr(2), \dep.kr(0.0), \del.kr(1), \onset.kr(2), \rateVar.kr(0.5), \varDur.kr(1) );
        sig = SinOsc.ar(\freq.kr(100) * trem, 0, 0.5 + volMod );
        sig = Pan2.ar(sig * env * \amp.kr(0.1), \pan.kr(0.0));
        Out.ar(\out.ir(0), sig);
    }).add;
}

)