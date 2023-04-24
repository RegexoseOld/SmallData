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
		patName = (catName.asString ++ "1").asSymbol;
		Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(4);
		Pbindef(\metronom, \amp, (0.05 * count), \midinote, ~melos.melo.bass0).play(~t);
		Pbindef(\bass, *~states[\bass].asPairs).play(~t, quant:4);
		Pbindef(\kik02, \amp, 0.43).play(~t, quant:1);
	    Pbindef(\sn02).stop;
		Pbindef(\hh01).stop;
		status = "state 00 init";
	}
    {(count >= 5) && (count <= 10)} {
        in_count = count-4;
        patName = catName.asString ++ "05";
		patName.postln;
		Pbindef(catName, *~states[catName][patName.asSymbol].asPairs);
		Pbindef(catName, \dur, Pif((in_count%3 == 0), 1, 0.25, 0.25 )).quant_(4);
		Pbindef(\metronom).stop;
		Pbindef(\bass, \amp, (0.055 * in_count), \midinote, ~melos.melo.bass1).play(~t);
		Pbindef(\sn02).play(~t, quant:1);
		Pbindef(\hh01).stop;
        numNotes = 2;
        status = "state 01 instrument changed \n bass line increases ";
    }
    {(count > 10) && (count <=20)} {
        in_count = count - 10;
        patName = catName ++ "10";
		Pbindef(\kik02, \amp, 0.23).play(~t, quant:1);
		Pbindef(\hh01).play(~t, quant:1);
        Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(4);
	    Pbindef(\bass, \amp, Pif((in_count%3 == 0), 0, 0.25, 0.25 )).stop;
        numNotes = 3;
        status = "state 02 Hihat";
    }
    {true} { "end of attCat reached".postln};

// feedback sound

    2.do{
        |n|
        Pbind(
            \instrument, \sampMon,
            \dur, Prand([0.25, 0.31], numNotes),
			\buf, ~melos[\slots][catName],
            \amp, ~fbVol * local_feedbackVol, \pan, Pwhite(-1.0, 1.0, numNotes),
			\rate, [1, (numNotes * 1.33)],
            \atk, 0.05, \rls, Pkey(\dur), \crv, -4,
			\out, ~utt.inbus
        ).play;
    };

   ~addVolume.value(catName);
	defer{~status[1].string = catName ++ " : " ++ status};
   //postf("\nsetting %\to status \t %\n", catName, status);

};
