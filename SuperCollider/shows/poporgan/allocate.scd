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
		Pbindef(\bass, \rls, Pif(count.even, 0.2, 0.9), \fmVol, Pif((count%3==0), 120, 200) );
		Pbindef(\kik02, \freq, ~melos.melo.kik01, \amp, 0.39).quant_(4);
	    Pbindef(\sn01).stop;
		Pbindef(\hh01).stop;
		status = "state 00 layered chords";
	}
    {(count >= 5) && (count <= 10)} {
        in_count = count-4;
        patName = catName.asString ++ "05";
		patName.postln;
		Pbindef(catName, *~states[catName][patName.asSymbol].asPairs);
		Pbindef(catName, \dur, Pif((in_count%3 == 0), 1, 0.25, 0.25 )).quant_(4);
		Pbindef(\kik02, \freq, ~melos.melo.kik02, \amp, 0.28, \timb1, Pwhite(0.05, 0.2, inf)).quant_(4);
		Pbindef(\bass, \rls, 0.3, \amp, (0.055 * in_count), \midinote, ~melos.melo.bass1).quant_(4);
		Pbindef(\sn01, \freq, Pif((count %3==0), ~melos.melo.sn03, ~melos.melo.sn02)).play(~t, quant:1);
		Pbindef(\hh01).stop;
        numNotes = 2;
        status = "state 01 instrument changed \n bass line increases, switching beats ";
    }
    {(count > 10) && (count <=16)} {
        in_count = count - 10;
        patName = catName ++ "10";
		Pbindef(\kik02, \freq, ~melos.melo.kik01, \amp, 0.43).quant_(4);
		Pbindef(\hh01, \decayScale, Pwhite(0.1, 0.3, inf), \dur, 0.25).play(~t, quant:1);
        Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(4);
	    Pbindef(\bass, \fmVol, Pif((in_count%3 == 0), 30, 150), \rls, Pif((count%4==0), 0.9, 0.18),
			\midinote, Pif(in_count.even, ~melos.melo.bass1 +12, ~melos.melo.bass2);
		).quant_(4);
		Pbindef(\sn01, \freq, Pif((count%3==0), ~melos.melo.sn03, ~melos.melo.sn01), \shaper1, Pif((counter%3==0), 2.2, 0.7), \shaper2, Pif((counter%3==0), 3.3, 1), \pan, Pif((counter%3==0), Pwhite(-1, 1, inf), Pwhite(-0.3, 0.3, inf))  ).quant_(1);
        numNotes = 3;
        status = "state 02 changing bass lines \n longer notes"
	}
    {(count > 16) && (count <=25)} {
        in_count = count - 15;
        patName = catName ++ "20";
		Pbindef(\kik02, \freq, ~melos.melo.kik01, \amp, 0.43).quant_(4);
		Pbindef(\hh01, \dur, Pif((count%3==0), 0.0625, 0.25), \decayScale, Pwhite(0.6, 1.2, inf),
			\carAmp, Pif((count%3==0), ~melos.meloPoporgan.hh02, ~melos.meloPoporgan.hh01)
		).play(~t, quant:4);
        Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(4);
	    Pbindef(\bass, \modRate, 1, \midinote, Pif(in_count.even, ~melos.melo.bass5, ~melos.melo.bass6),
			\rls, 2, \fmVol, Pif((count%3==0), 130, 60), \cgain, 2.2,
		).quant_(4);
        numNotes = 4;
        status = "state 03 one-notes with downward glissando";
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
