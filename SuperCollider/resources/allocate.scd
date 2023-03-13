~allocate = {
    |catName, counter|
    var c, dura, patName, status, count, in_count, local_feedbackVol, numNotes;
    count = floor(counter * ~factor).asInteger;
    status = "state 00";
    local_feedbackVol = 0.4;
    numNotes = 1;
    dura = Env.new([1,0], [count], [-2]).asPseg;
    patName = catName.asString ++ "0";
    c = case
	{count < 5}{
		~states[catName][patName.asSymbol].postln;
	}
    {(count >= 5) && (count <= 10)} {
        in_count = count;
        patName = catName.asString ++ "1";
        Pbindef(catName.asSymbol, *~states[catName][patName.asSymbol].asPairs);
		~states[catName.asSymbol][patName.asSymbol].postln;
        numNotes = 2;
        status = "state 01";
    }
    {(count > 11) && (count <=20)} {
        var add_send;
        in_count = count - 10;
        patName = catName ++ "2";
        Pbindef(catName, ~states[catName][patName.asSymbol].asPairs);
        numNotes = 3;
        status = "state 02";
    }
    {true} { "end of attCat reached".postln};

// feedback sound

    1.do{
        |n|
        Pbind(
            \instrument, \quitt,
            \dur, Prand([0.25, 0.31], inf),
            \midinote, ~melos[\melo][catName][0],
            \detune, Pwhite(-6, 6, numNotes),
            \amp, ~fbVol * local_feedbackVol, \pan, Pwhite(-1.0, 1.0, numNotes),
            \ampDist, 2, \durDist, 0.2,
            \gendAmp, Pwrand([0.05, 0.14, 0.33], [0.6, 0.3, 0.1], inf),
            \ffreq, Pwhite( 300, 800, inf),
            \minFreq, 600, \maxFreq, 1400,
            \atk, 0.05, \rls, Pkey(\dur), \crv, -4
        ).play;
    };
   // ~addVolume.value(catName, ~volPlus, ~volMax, ~volThres);
    postf("\nsetting %\t with count %\n at status \t %\n", catName, count, status);

};
