
~allocate = {
    |catName, counter|
    var c, dura, patName, status, count, in_count, local_feedbackVol, numNotes;
    count = floor(counter * ~factor).asInteger;
    status = "";
    local_feedbackVol = 0.4;
    numNotes = 1;
    dura = Env.new([1,0], [count], [-2]).asPseg;
    patName = catName.asString ++ "0";

    c = case
	{count < 5}{
		in_count = count;
		Pbindef(\metronom).stop;
		Pbindef(\bass, *~states[\bass].asPairs).quant_(1);
		Pbindef(\kik01).play(~t, quant:4);
		Pbindef(catName, \index, 0.27 * in_count).quant_(4);
	    Pbindef(\sn01).stop;
	    Pbindef(\hh01).stop;
		status = "state 00";
	}
    {(count >= 5) && (count <= 10)} {
        in_count = count-4;
        patName = catName.asString ++ "10";
		Pbindef(\metronom, \amp, (0.033 * in_count)).play(~t);
		Pbindef(\bass, *~states[\bass1].asPairs).play(~t, quant:1);
		//Pbindef(\kik01).stop;
		Pbindef(\sn01).play(~t, quant:4);
		Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(4);
		//Pbindef(catName, \harmonic, [in_count, count]);
        numNotes = 2;
        status = "state 01";
    }
    {(count > 11) && (count <=20)} {
        in_count = count - 10;
        patName = catName ++ "10";
		Pbindef(\kik01).play(~t, quant:1);
		Pbindef(\hh01).play(~t, quant:1);
		Pbindef(\sn01, \numharm, ~melos.melo.sn03);
        Pbindef(catName, ~states[catName][patName.asSymbol].asPairs).quant_(4);
	    Pbindef(\bass, \midinote, ~melos.melo.bass5).quant_(1);
		Pbindef(\metronom).stop;
        numNotes = 3;
        status = "state 02";
    }
    {true} { "end of attCat reached".postln};

// feedback sound

    2.do{
        |n|
        Pbind(
            \instrument, \quitt,
            \dur, Prand([0.25, 0.31], numNotes),
            \midinote, ~melos[\melo][catName],
            \detune, Pwhite(-6, 6, numNotes),
            \amp, ~fbVol * local_feedbackVol, \pan, Pwhite(-1.0, 1.0, numNotes),
            \ampDist, 2, \durDist, 0.2,
            \gendAmp, Pwrand([0.05, 0.14, 0.33], [0.6, 0.3, 0.1], numNotes),
            \ffreq, Pwhite( 300, 800, numNotes),
            \minFreq, 600, \maxFreq, 1400,
            \atk, 0.05, \rls, Pkey(\dur), \crv, -4
        ).play;
    };

   ~addVolume.value(catName);
    postf("\nsetting %\to status \t %\n", catName, status);

};
