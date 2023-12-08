{
	|catName, counter|
	var c, dura, patName, status, count, in_count, local_feedbackVol, numNotes;
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
		patName = (catName.asString ++ "0").asSymbol;
		Pbindef(catName, *~states[catName][patName].asPairs).play(~t, quant:1);
		Pbindef(catName, \midinote, 60 + [0, 12, -12, 24, -24].choose, \index, Pn(count, inf), \rls, 3 + (count*0.75), \dev, [0.1, 0.4, 1.0, 1.5, 1.9].choose).quant_(1);
		[\kik02, \hh01, \bass, \snip, \sn01].do{|n| Pbindef(n).stop};
		status = "friendly beginnings";
	}
	{(count >=5) && (count <= 9)}{
		in_count = count -4;
		patName = (catName.asString ++ "05").asSymbol;
		Pbindef(catName, *~states[catName][patName].asPairs).play(~t, quant:1);
		Pbindef(catName, \fmDur, 0.1 * count, \mRatio, count, \cRatio, Pif(count.odd, 1, 4), \index, 9 - count, \trmDep, 0.02 * in_count).quant_(1);
		[\kik02, \hh01, \sn01].do{|n| Pbindef(n).stop };
		status = "weird developments";
	}
	{(count >= 10) && (count <= 14)}{
		in_count = count -9 ;
		patName = (catName.asString ++ "10").asSymbol;
		//Pbindef(catName).clear;
		Pbindef(catName, *~states[catName][patName].asPairs).play(~t, quant:0);
		Pbindef(catName, \rls, 0.3 * in_count , \fratio0, in_count * 2.8, \modInd0, 0.5 * in_count , \modInd1, in_count , \modInd2, 2* in_count , \ffreq, 800 + Pxrand([-300, 0, 300, 1000, 200],inf), \fmVol, Pif(count.odd, 50, 230), \fmFreq, Pkey(\fmVol) * 15).quant_(4);
		Pbindef(\bass, *~states[\bass].asPairs).play(~t, quant:4);
		Pbindef(\bass,
			\midinote, Pif((count%3==0), ~melos.meloEdge.edgeBass01, ~melos.meloEdge.edgeBass00),
			\dur, Pif((count%3==0), ~melos.durEdge.edgeBass01, ~melos.durEdge.edgeBass00),
			\ipeak, 1 + (in_count * 0.5),
			\fmratio, Pif(count.odd, 1, 2),
			\fade, 1).quant_(8);
		Pbindef(\kik02, \freq, ~melos.melo.kik01, \amp, 0.39, \fade, 1).play(~t, quant:4);
		Pbindef(\hh01, *~states[\hh01].asPairs).play(~t, quant:4);
		Pbindef(\hh01, \fade, 0.1 * in_count).quant_(0);
		Pbindef(\sn01).stop;
		Pbindef(\snip01).stop;

		status = "state 03 dotted notes";
	}
	{(count >= 15) && (count <= 19)} {
		in_count = count-14;
		patName = catName.asString ++ "15";
		Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(0);
		Pbindef(catName, \ffreq, 200 * in_count, \rq, 0.1).quant_(4);
		Pbindef(\kik02, \freq, ~melos.meloEdge.kik02, \dur, ~melos.durEdge.kik02, \amp, 0.28, \timb1, Pwhite(0.05, 0.2, inf), \fade, 1).quant_(4);
		Pbindef(\bass, \midinote, Pif((count%3==0), ~melos.meloEdge.edgeBass03, ~melos.meloEdge.edgeBass00), \dur, Pif((count%3==0), ~melos.durEdge.edgeBass03, ~melos.durEdge.edgeBass00), \oscFB, 3*pi/8).quant_(8);
		Pbindef(\sn01, \freq, ~melos.meloEdge.sn02 *3, \dur, ~melos.durEdge.sn02, \fade, 1).play(~t, quant:4);
		Pbindef(\hh01, \minRing, Pwhite(0.01, 0.07, inf), \maxRing, Pwhite(0.08, 0.18, inf), \dur, 0.25, \fade, 1).quant_(4);
		Pbindef(\snip01, \fade, 1).play(~t, quant:4);
		numNotes = 2;
		status = "state 04 snap groove ";
	}
	{(count >= 20) && (count <=23)} {
		in_count = count - 19;
		patName = catName ++ "20";
		[\kik02, \hh01, \bass, \snip, \sn01].do{|n|
			//Pbindef(n).isPlaying.postln;
			if (Pbindef(n).isPlaying == false, {Pbindef(n).play(~t, quant:4)})};
		Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(0);
		Pbindef(catName, \fratio0, in_count * 0.25, \fratio1, in_count * 4, \modInd1, in_count, \modInd1, in_count * 4).quant_(4);
		Pbindef(\kik02, \freq, ~melos.meloEdge.kik10, \dur, ~melos.durEdge.kik10, \amp, 0.40, \fade, 0.9).quant_(4);
		Pbindef(\sn01, \freq, ~melos.meloEdge.sn10 *3, \dur, ~melos.durEdge.sn10, \fade, 0.9).quant_(4);
		Pbindef(\hh01, \dur, Pif((count%3==0), 0.0625, 0.25), \decayScale, Pwhite(0.6, 1.2, inf),
			\carAmp, Pif((count%3==0), ~melos.meloPoporgan.hh02, ~melos.meloPoporgan.hh01)
		).quant_(4);
		Pbindef(\bass, \modRate, 1, \midinote, ~melos.meloEdge.bass10, \dur, ~melos.durEdge.bass10,
			\rls, 0.3, \fmVol, Pif((count%3==0), 130, 60), \cgain, 2.2, \amp, 0.3, \fade, 0.8).quant_(4);
		numNotes = 3;
		status = "state 05 hectic deadline";
	}

	{(count > 23) && (count <=25)} {
		in_count = count - 22;
		patName = catName ++ "25";
		Pbindef(catName, *~states[catName][patName.asSymbol].asPairs).quant_(4);
		[\kik02, \hh01, \bass, \snip, \sn01].do{|n|
			//Pbindef(n).isPlaying.postln;
			if (Pbindef(n).isPlaying == false, {Pbindef(n).play(~t, quant:4)})};
		Pbindef(\kik02, \freq, ~melos.melo.kik01, \amp, 0.43, \fade, 1).quant_(4);
		Pbindef(\hh01, \dur, Pif((count%3==0), 0.0625, 0.25), \decayScale, Pwhite(0.6, 1.2, inf),
			\carAmp, Pif((count%3==0), ~melos.meloPoporgan.hh02, ~melos.meloPoporgan.hh01), \fade, 1
		).quant_(4);
		Pbindef(\bass, \dur, Pif( (count%4==0), 0.5, 0.25), \modRate, 1,
			\midinote, Pif(in_count.even, ~melos.melo.bass5, ~melos.melo.bass6),
			\rls, 2, \fmVol, Pif((count%3==0), 130, 60), \cgain, 2.2, \fade, 1
		).quant_(4);
		numNotes = 2;
		status = "state 06 one-notes with downward glissando";
	}

	{true} { "end of attCat reached".postln};



	~addVolume.value(catName);
	defer{~status[1].string = catName ++ " : " ++ status};
	postf("\nsetting %\to status \t %\n", catName, status);
};
