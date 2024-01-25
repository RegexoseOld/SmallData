{
	|catName, counter|
	var c, dura, patName, status, count, case_count, local_feedbackVol, numNotes;
	count = floor(counter * ~factor).asInteger;
	status = "";
	local_feedbackVol = 0.55;
	numNotes = 1;
	dura = Env.new([1,0], [count], [-2]).asPseg;
	patName = (catName.asString ++ "0").asSymbol;
	// feedback sound
	2.do{
		|n|
		Pbind(
			\instrument, \sampMon,
			\dur, Prand([0.25, 0.31], numNotes),
			\buf, ~melos[\slots][catName].normalize,
			\amp, ~fbVol * local_feedbackVol, \pan, 0,
			\rate, Prand([[1, 1.03], [1, 1.18], [0.97, 1.101], [0.83, 0.91]], numNotes),
			\atk, 0.05, \rls, Pkey(\dur), \crv, -4,
			\cgain, 1,
			\out, ~utt.inbus
		).play;
	};

	c = case
	{count <= 4}{
		patName = (catName.asString ++ "00").asSymbol;
		Pbindef(catName, *~states[catName][patName].asPairs).play(~t, quant:1);
        /* hier überschreibe ich den initial status, um einen smootheren Anfang
        zu bekommen, eben mit oktavierten tönen */
        Pbindef(catName, \index, count, \rls, 3 + (count*0.75), \cRatio, count, \mRatio, count).quant_(1);
		status = "State 0 notes increasing harmonies";
	}
	{(count >=5) && (count <= 9)}{
		case_count = count -4;
		patName = (catName.asString ++ "05").asSymbol;
		Pbindef(catName, *~states[catName][patName].asPairs).play(~t, quant:1);
		Pbindef(catName, \mRatio, case_count, \cRatio, 3, \index, case_count, \trmDep, 0.02 * case_count).quant_(1);

		status = "State1: HH longer decay, Notes increasing harmonies, increasing tremolo";
	}
	{(count >= 10) && (count <= 20)}{
		case_count = count -9 ;
		patName = (catName.asString ++ "10").asSymbol;
		//Pbindef(catName).clear;
		Pbindef(catName, *~states[catName][patName].asPairs).play(~t, quant:8);
		Pbindef(catName, \rls, 0.3 * case_count , \fratio0, case_count, \modInd0, case_count, \ffreq, 800 + (case_count * 100), \fmVol, Pif(count.odd, 50, 230)).quant_(8);
        // bass und beat werden ausgelagert in ~setGlobal
		status = "state 03 dotted notes, increasing harmonies & release, bass but no beat";
	}

/*	{(count >= 10) && (count <= 14)}{
		case_count = count -9 ;
		patName = (catName.asString ++ "10").asSymbol;
		//Pbindef(catName).clear;
		Pbindef(catName, *~states[catName][patName].asPairs).play(~t, quant:0);
		Pbindef(catName, \rls, 0.3 * case_count , \fratio0, case_count * 2.8, \modInd0, 0.5 * case_count , \modInd1, case_count , \modInd2, 2* case_count , \ffreq, 800 + Pxrand([-300, 0, 300, 1000, 200],inf), \fmVol, Pif(count.odd, 50, 230), \fmFreq, Pkey(\fmVol) * 15).quant_(4);
		Pbindef(\bass, *~states[\bass].asPairs).play(~t, quant:4);
		Pbindef(\bass,
			\midinote, Pif((count%3==0), ~melos.melo.bass11, ~melos.melo.bass10),
			\dur, Pif((count%3==0), ~melos.dur.bass11, ~melos.dur.bass10),
			\ipeak, 1 + (case_count * 0.5),
			\fmratio, Pif(count.odd, 1, 2),
			\fade, 1).quant_(8);
		Pbindef(\kik02, \freq, ~melos.melo.kik01, \amp, 0.39, \fade, 1).play(~t, quant:4);
		Pbindef(\hh01, *~states[\hh01].asPairs).play(~t, quant:4);
		Pbindef(\hh01, \fade, 0.1 * case_count).quant_(0);
		Pbindef(\sn01).stop;
		Pbindef(\snip01).stop;

		status = "state 03 dotted notes with beat";
	}*/








/*	{(count >= 15) && (count <= 19)} {
		case_count = count-14;
		patName = catName.asString ++ "15";
		Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(0);
		Pbindef(catName, \ffreq, 200 * case_count, \rq, 0.1).quant_(4);
		Pbindef(\kik02, \freq, ~melos.melo.kik02, \dur, ~melos.dur.kik02, \amp, 0.28, \timb1, Pwhite(0.05, 0.2, inf), \fade, 1).quant_(4);
		Pbindef(\bass, \midinote, Pif((count%3==0), ~melos.melo.bass03, ~melos.melo.bass10), \dur, Pif((count%3==0), ~melos.dur.bass03, ~melos.dur.bass10), \oscFB, 3*pi/8).quant_(8);
		Pbindef(\sn01, \freq, ~melos.melo.sn02 *3, \dur, ~melos.dur.sn02, \fade, 1).play(~t, quant:4);
		Pbindef(\hh01, \minRing, Pwhite(0.01, 0.07, inf), \maxRing, Pwhite(0.08, 0.18, inf), \dur, 0.25, \fade, 1).quant_(4);
		Pbindef(\snip01, \fade, 1).play(~t, quant:4);
		numNotes = 2;
		status = "state 04 snap groove ";
	}*/
	{(count >= 20) && (count <=23)} {
		case_count = count - 19;
		patName = catName ++ "20";
		[\kik02, \hh01, \bass, \snip, \sn01].do{|n|
			//Pbindef(n).isPlaying.postln;
			if (Pbindef(n).isPlaying == false, {Pbindef(n).play(~t, quant:4)})};
		Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(0);
		Pbindef(catName, \fratio0, case_count * 0.25, \fratio1, case_count * 4, \modInd1, case_count, \modInd1, case_count * 4).quant_(4);
		Pbindef(\kik02, \freq, ~melos.melo.kik10, \dur, ~melos.dur.kik10, \amp, 0.40, \fade, 0.9).quant_(4);
		Pbindef(\sn01, \freq, ~melos.melo.sn10 *3, \dur, ~melos.dur.sn10, \fade, 0.9).quant_(4);
		Pbindef(\hh01, \dur, Pif((count%3==0), 0.0625, 0.25), \decayScale, Pwhite(0.6, 1.2, inf),
			\carAmp, Pif((count%3==0), ~melos.melo.hh02, ~melos.melo.hh01)
		).quant_(4);
		Pbindef(\bass, \modRate, 1, \midinote, ~melos.melo.bass20, \dur, ~melos.dur.bass10,
			\rls, 0.3, \fmVol, Pif((count%3==0), 130, 60), \cgain, 2.2, \amp, 0.3, \fade, 0.8).quant_(4);
		numNotes = 3;
		status = "state 05 hectic deadline";
	}

	{(count > 23) && (count <=25)} {
		case_count = count - 22;
		patName = catName ++ "25";
		Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(4);
		[\kik02, \hh01, \bass, \snip, \sn01].do{|n|
			//Pbindef(n).isPlaying.postln;
			if (Pbindef(n).isPlaying == false, {Pbindef(n).play(~t, quant:4)})};
		Pbindef(\kik02, \freq, ~melos.melo.kik01, \amp, 0.43, \fade, 1).quant_(4);
		Pbindef(\hh01, \dur, Pif((count%3==0), 0.0625, 0.25), \decayScale, Pwhite(0.6, 1.2, inf),
			\carAmp, Pif((count%3==0), ~melos.melo.hh02, ~melos.melo.hh01), \fade, 1
		).quant_(4);
		Pbindef(\bass, \dur, Pif( (count%4==0), 0.5, 0.25), \modRate, 1,
			\midinote, Pif(case_count.even, ~melos.melo.bass06, ~melos.melo.bass07),
			\rls, 2, \fmVol, Pif((count%3==0), 130, 60), \cgain, 2.2, \fade, 1
		).quant_(4);
		numNotes = 2;
		status = "state 06 one-notes with downward glissando";
	}

	{true} { "end of attCat reached".postln};



	~addVolume.value(catName);
	defer{~status[1].string = catName ++ " : " ++ status};
	postf("\nsetting %  to status \t % with patname % \n", catName, status, patName);
};
