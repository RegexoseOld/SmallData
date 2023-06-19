
~allocate = {
    |catName, counter|
    var c, dura, patName, status, count, in_count, local_feedbackVol, numNotes;
    count = floor(counter * ~factor).asInteger;
    status = "";
    local_feedbackVol = 0.9;
    numNotes = 1;
    dura = Env.new([1,0], [count], [-2]).asPseg;
    patName = catName.asString ++ "0";

    c = case
	{count < 5}{
		in_count = count;
		Pbindef(\metronom).stop;
		Pbindef(\bass, *~states[\bass].asPairs).quant_(1);
		Pbindef(\kik02, \timb2, Pif(count.even, -12, -20), \freq, ~melos.meloBase.kik01).play(~t, quant:4);
		Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(4);
	    Pbindef(\sn01).stop;
	    Pbindef(\hh01).stop;
		status = "initial values, basic bass drum";
	}
    {(count >= 5) && (count <= 10)} {
        in_count = count-4;
        patName = catName.asString ++ "10";
		Pbindef(\metronom, \amp, (0.033 * in_count)).play(~t);
		Pbindef(\bass, *~states[\bass1].asPairs).play(~t, quant:1);
		Pbindef(\kik02, \freq, Pif((count%3==0), ~melos.meloBase.kik02, ~melos.meloBase.kik01));
		Pbindef(\sn01, \ghosts, ~melos.meloBase.sn01).play(~t, quant:1);
		Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(4);
        numNotes = 2;
        status = "a cadence and a sizzling snare";
    }
    {(count >= 11) && (count <=20)} {
        in_count = count - 10;
        patName = catName ++ "11";
		Pbindef(\kik02, \freq, ~melos.meloBase.kik04, \dur, Pif((count%3==0), 0.25, 0.5)).quant_(4);
		Pbindef(\hh01).play(~t, quant:1);
		Pbindef(\sn01, \numharm, Pif((count%4==0), 60, 100), \ghosts, Pif((count%3==0), ~melos.meloBase.sn02, ~melos.meloBase.sn01)).quant_(4);
        Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(4);
	    Pbindef(\bass, \midinote, ~melos.melo.bass5).quant_(1);
		Pbindef(\metronom).stop;
        numNotes = 3;
        status = "telephone peeps";
    }
    {true} { "end of attCat reached".postln};

// feedback sound

    2.do{
        |n|
        Pbind(
            \instrument, \quitt,
            \dur, Prand([0.25, 0.31], numNotes),
			\midinote, ~melos[\feedbacks][catName],
            \detune, Pwhite(-6, 6, numNotes),
            \amp, ~fbVol * local_feedbackVol, \pan, Pwhite(-1.0, 1.0, numNotes),
            \ampDist, 2, \durDist, 0.2,
            \gendAmp, Pwrand([0.05, 0.14, 0.33], [0.4, 0.38, 0.26].normalizeSum, numNotes),
            \ffreq, Pwhite( 300, 800, numNotes),
            \minFreq, 600, \maxFreq, 1400,
            \atk, 0.15, \rls, 3, \crv, -8,
			\out, ~utt.inbus
        ).play;
    };

   ~addVolume.value(catName);
	defer{~status[1].string = catName ++ " : " ++ status};
    postf("\nsetting %\to status \t %\n", catName, status);

};
