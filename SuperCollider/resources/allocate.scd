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
		Pbindef(\bass, *~states[\bass].asPairs).quant_(4);
		Pbindef(\kik01, \freq, ~melos.melo.kik01, \amp, 0.43).quant_(4);
	    Pbindef(\sn01).stop;
		Pbindef(\hh01).stop;
		status = "state 00 init";
	}
    {(count >= 5) && (count <= 10)} {
        in_count = count-4;
        patName = catName.asString ++ "05";
		patName.postln;
		Pbindef(catName, *~states[catName][patName.asSymbol].asPairs);
		Pbindef(catName, \dur, Pif((in_count%3 == 0), 1, 0.25, 0.25 )).quant_(4);
		Pbindef(\kik01, \freq, ~melos.melo.kik02, \amp, 0.43, \shaper1, Pwhite(0.05, 0.2, inf)).quant_(4);
		Pbindef(\bass, \amp, (0.055 * in_count), \midinote, ~melos.melo.bass1).quant_(4);
		Pbindef(\sn01, \freq, Pif((count %3==0), ~melos.melo.sn03, ~melos.melo.sn02, ~melos.melo.sn01)).play(~t, quant:1);
		Pbindef(\hh01).stop;
        numNotes = 2;
        status = "state 01 instrument changed \n bass line increases ";
    }
    {(count > 10) && (count <=20)} {
        in_count = count - 10;
        patName = catName ++ "10";
		Pbindef(\kik01, \freq, ~melos.melo.kik01, \amp, 0.43).quant_(4);
		Pbindef(\hh01, \decayScale, Pwhite(0.1, 0.3, inf)).play(~t, quant:1);
        Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(4);
	    Pbindef(\bass, \amp, Pif((in_count%3 == 0), 0, 0.25, 0.25 ),
			\midinote, Pif(in_count.even, ~melos.melo.bass1 -3.midicps, ~melos.melo.bass2, ~melos.melo.bass0);
		).quant_(4);
		Pbindef(\sn01, \freq, Pif((count%3 ==0), ~melos.melo.sn03, ~melos.melo.sn01, ~melos.melo.sn01)).quant_(1);
        numNotes = 3;
        status = "state 02 Hihat"
	}
    {(count > 20) && (count <=25)} {
        in_count = count - 10;
        patName = catName ++ "20";
		Pbindef(\kik01, \freq, ~melos.melo.kik01, \amp, 0.43).quant_(4);
		Pbindef(\hh01, \decayScale, Pwhite(0.6, 1.2, inf),
			\carAmp, Pxrand([0.23, 0.33, 0.5], inf)
		).play(~t, quant:1);
        Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(4);
	    Pbindef(\bass, \amp, Pif((in_count%3 == 0), 0, 0.25, 0.25 )).quant_(4);
        numNotes = 3;
        status = "state 03 glissando";
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
