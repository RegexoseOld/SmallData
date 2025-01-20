
~setGlobal = {
    var lastMinute=0, elapsed=0;
    if (~upm >= ~upmMax, {
        var cat, buf;
        "upmMax reached upm %, switching to Mumbles".format(~upm).postln;
        Pbindef.all.do({|p| p.pause});
        cat = ~categorySymbols[~cat];
        ~mum.(cat, ~uttsPerMinute[cat], 0.25);
        if (~hitIsPlaying == false, {~hitPlay = Synth(\hitSt, [\buf, ~hitSample.normalize, \amp, 0.22, \start, 0, \end, 5 * s.sampleRate, \atk, 3, \rls, 10])},{"hit already playing".postln});
        ~hitIsPlaying = true;
    },{
        "upm %, switching to Patterns".format(~upm).postln;
        ~hitIsPlaying = false;
        Pbindef.all.do({|p| if (p.isPlaying == false, {p.resume})});
        ~allocate.(~categorySymbols[~cat], ~uttDict[~cat]);

    });
    c = case
    {~totalUtts > 300} {
        ~hitSample = ~buffers[\atmos][\rain];

    }
    {(~totalUtts > 130) && (~uttDict[~cat] >= 40)}{
        var count, case_count;
        count = ~uttDict[~cat];
        case_count = count -39;
        Pbindef(\kik02, \freq, ~melos.melo.kik02, \dist, case_count * 0.75).quant_(8);
        Pbindef(\sn01, \freq, ~melos.melo.sn02, \dist1, 13, \dist2, -4, \rls, 2 ).quant_(8);
        Pbindef(\hh01, \dur, Pif((count%3==0), 0.0625, 0.25), \decayScale, Pwhite(0.6, 1.2, inf),
            \carAmp, Pif((count%3==0), ~melos.melo.hh02, ~melos.melo.hh01), \fade, 1
        ).quant_(8);
        Pbindef(\bass, \dur, Pif(case_count.even, 0.25, 0.5), \modRate, 1.5,
            \midinote, Pif(case_count.even, ~melos.melo.bass36, ~melos.melo.bass37),
            \rls, 1.5, \fmratio, 3, \slide1, 0.5, \distort, 1.5).quant_(8);
    }
    {(~totalUtts > 100) && (~uttDict[~cat] >= 25)}{
        var count, case_count;
        count = ~uttDict[~cat] ;
        case_count = count -19;
        Pbindef(\kik02, \timb2, -28, \sweep, 0.1, \freq, ~melos.melo.kik02, \dur, ~melos.dur.kik02).quant_(4);
        Pbindef(\sn01, \freq, ~melos.melo.sn02, \dur, ~melos.dur.sn02).play(~t, quant:8);
        Pbindef(\bass,
            \midinote, Pif((count%4 == 0), ~melos.melo.bass23, ~melos.melo.bass24),
            \dur, Pif((count%4 ==0), ~melos.dur.bass23, ~melos.dur.bass24),
            \oscFB, pi/4,
        ).quant_(8);
    }
    {~totalUtts >= 90}{Pbindef(\snip01).play(~t, quant:8);}

    {(~totalUtts >= 80) && (~uttDict[~cat] >= 20)}{
        var count, case_count;
        count = ~uttDict[~cat];
        case_count = count -19;
        ~hitSample = ~buffers[\atmos][\dickerpott];
        Pbindef(\bass,
            \midinote, Pif((count%4 ==0), ~melos.melo.bass25, ~melos.melo.bass20),
            \dur, Pif((count%4 ==0), ~melos.dur.bass25, ~melos.dur.bass20)).quant_(8);
        Pbindef(\kik02, \timb2, -28 + (case_count *2), \sweep, 0.4 - (case_count * 0.05)).quant_(8);
        Pbindef(\hh01, \freq, 200, \maxFreq, 800 , \decayScale, 1, \maxRing, 1, \fade, 0.6).quant_(4);

    }
    {~totalUtts >= 70}{
        Pbindef(\kik02).play(~t, quant:8);
        Pbindef(\hh01, \decayScale, 1, \maxRing, 0.35, \fade, 0.35 ).quant_(4); }
    {~totalUtts >= 50}{Pbindef(\hh01, \dur, 0.25, \fade, 0.25, \decayScale, 0.5, \maxRing, 0.25).quant_(4);}

    {(~totalUtts >= 40) && (~uttDict[~cat] >= 10)}{
        var count = ~uttDict[~cat];
        var case_count = count -9;
        var bassmelo = ("bass" ++ count.asString).asSymbol;
        /* Bass und Beat auslagern, damit es sich nicht dauernd ändert.
        das sollte erst getriggert werden, wenn eine Kategorie 10 counts hat*/
        Pbindef(\bass, *~states[\bass].asPairs).play(~t, quant:8);
        Pbindef(\bass,
            \midinote, Pif((count%15==0), ~melos.melo.bass15, ~melos.melo.at(bassmelo)),
            \dur, Pif((count%15==0), ~melos.dur.bass15, ~melos.dur.bass10),
            \ipeak, 1 + (case_count * 0.3),
            \fmratio, Pif(count.odd, 1, 2),
            \fade, 0.8).quant_(8);
        Pbindef(\hh01, \freq, 900, \maxFreq, 1200, \fade, 0.25).quant_(0);

    }
    {(~totalUtts > 20) && (~uttDict[~cat] >= 5)}{
        var count = ~uttDict[~cat];
        var case_count = count -4;
        Pbindef(\hh01, \decayScale, 2 + (case_count * 1.5), \maxRing, case_count/2, \accent, 2 + (0.3 * case_count)).quant_(0);
    }
    {~totalUtts >= 18}{Pbindef(\hh01).play(~t, quant:4)}
    {~totalUtts >= 5}{
        //bird Atmosphere
        ~hitSample = ~buffers[\atmos][\birds];
        "10 utts".postln;
    }
    {(~totalUtts == 1)}{
        //"first utt".post=n;
        ~runFx.();
        ~activateFaders.();

        Pdefn(\melody).play(~t, quant:0);
        //[\kik02, \hh01, \bass].do{|n| Pbindef(n).play(~t, quant:4)};
        //init continuous Fadeout Function
        ~t.schedAbs(~t.nextTimeOnGrid, {
            if(~checkFadeVols.() >= ~thresCont, {
                ~continuousFadeOut.value(~fadingSynths); 1},
            {"not fading: fadeVols = %".format(~fadeVols).postln});

        });
        //initiate CategoriesPerMinute Counter EINMALIG, das funktioniert UNABHÄNGIG von einkommenden Utts
        ~t.schedAbs(~t.nextTimeOnGrid, {
            var upm=0;
            //"after % ".format((~t.beats/~t.tempo)).postln;
            if ((~t.beats/~t.tempo) >= ~uttTimeWindow, {
                lastMinute = (~t.beats/~t.tempo) - ~uttTimeWindow ;
                //scan all timestamp lists and only keep timestamps that are larger than lastMinute
                ~uttsPerMinute.keysValuesDo({|k,v|
                    v = v.select({|ts| ts >= lastMinute});
                    //"new opm % in %".format(v.size, k).postln;
                    ~uttsPerMinute[k] = v;
                });
                1;
            });
            ~uttsPerMinute.values.do({|l| upm = upm + l.size});
            ~upm = upm; // update ~upm
            //"updated upm %".format(upm).postln;
            1;
        });
    }
    {true} {"end of global settings".postln};

    //add new timestamp in respective category list
    ~uttsPerMinute[~categorySymbols[~cat]].add((~t.beats/~t.tempo));
};