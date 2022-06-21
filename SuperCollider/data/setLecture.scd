~setLecture =  {
	|s_name, counter|
	var c, dura, pat, status, count;
	count = floor(counter * ~factor).asInteger;
	status = "zero status";
	dura = Env.new([1,0], [count], [-2]).asPseg;
	~lec = Pbindef(\dis, *~reset[\patternDict][\lec].asPairs);
	~fm = Pbindef(\dis, *~reset[\patternDict][\fm].asPairs);
	5.do({|i| Pbind(\instrument, \lecture,
		\freq, [exprand(80, 90 + i), exprand(160, (160 + i))], \amp, 0.09, \filTime, 0.02, \rls, Pn(0.5, 1)).play});
	c = case
	{(count > 0) && (count <=5)}	{~lec = Pbindef(\dis, *~reset[\patternDict][\lec].asPairs);
		status = "Bassfigur 1";}

	{(count > 5) && (count <= 10)} {
		~lec = Pbindef(\lec,
			\dur, 1,
			\degree, Pseq([0, -6, -5, -7], inf),
			\fade, 0.4 - (count * 0.02), \distort, 1.4, \filTime, 0.6 -((count -5) * 0.05));
		~fm = Pbindef(\fm, \dur, 1, \degree, Pseq([0, -6, -5, -7], inf), \fade, (count-5) * 0.05 , \atk, (count-4).reciprocal);
		status = "Schnellere Figur und anderer Synth dazu";
	}
	{(count > 10) && (count <= 12)} {
		~lec = Pbindef(\lec, \fade, 0);
		~fm = Pbindef(\fm, \dur, 1/4, \degree, Pseq([0, \, \, \, -6, \, \, \, -5, \, \, \, -7, \, \, \], inf), \fade, 0.4);
		status = "FM Bass Figur 1";
	}
	{(count > 12) && (count <= 14)}{
		~lec = Pbindef(\lec, \fade, 0);
		~fm = Pbindef(\fm, \dur, 1/4, \degree, Pseq([0, \, \, \, -6, \, \, \, \, \, \, \, 6, \, \, \], inf), \fade, 0.4);
		status = "FM Bass Figur 2";
	}
	{(count > 14) && (count <= 16)}{
		~lec = Pbindef(\lec, \dur, 1, \degree, Pseq([0, -6, -5, -7], inf), \distort, 1.4, \filTime, 0.6 -((count -5) * 0.05));
		~fm = Pbindef(\fm,\dur, 1/4, \degree, Pseq([0, \, \, \, -6, \, \, \, \, \, 6, \, 11, \, \, \], inf), \fade, 0.4);
		status = "FM Bass Figur 3";
	}
	{(count > 16) && (count <= 18)}{
		~lec = Pbindef(\lec, \fade, 0);
		~fm = Pbindef(\fm,\dur, 1/4, \degree, Pseq([0, \, \, \, -6, \, -6, \, -6, \, 6, \, 11, \, \, \], inf), \fade, 0.4);
		status = "FM Bass Figur 4";
	}
	{(count > 18) && (count <= 20)}{
		~fm = Pbindef(\fm,  \dur, Pseq([Pseq([1/4], 4), 6/4, Pseq([1/4], 6) ], inf), \degree, Pseq([0, \, 0, \, 0,  6, \, 11, \, \, \], inf), \fade, 0.4); status = "FM Bass Figur 5";}

	{(count > 20) && (count <= 30)} {
		//~fmbass.pause;
		~reverb.set(\bpf, 0.002);
		~lec = Pbindef(\lec, \degree, Pseq([0, -1],inf) -12, \dur, 3, \filTime, 0.85, \cgain, 5, \distort, 1.5, \fade, (count -20) * 0.13, \outfx, ~fx1Bus, \send, -5);
		pat = Pbind(\instrument, \lecture, \sus, 0.3, \rls, 1.0 - ((count-20) * 0.03),
			\degree, Pif(count.even, Pseq([12, 11, 11, 8, 8, \r, 6, Pseq([\], 24)], inf), Pseq([1, \, -3, \, -5, \, -8, \], inf), Pseq([-12],1)),
			\dur, Pif(count.even, 1, 2, 1/8),
			\distort, 1.3,
			\det1, 1.0 - (count * 0.007), \det2, 1.0 + (count * 0.007),
			\filTime, Pif(count.even, 0.6, 0.8, 0.4 ),
			\amp, Prand([0.4, 0.3, 0.2, 0.1], 9),
			\outfx, Pif(count.even,~fx2Bus, ~fx3Bus, ~fx1Bus ),
			\send, Pif(count.even, -35+ ((count-20)* 2), -40 + ((count-20)* 2), -40),
		).play(t, quant:4);

		~delay.set(\decayT, 0.1 * (count-15));
		~fm = Pbindef(\fm, \dur, Pif((count%3==0), 1/4, Pseq([1/8], 15), 1/4),
			\degree, Pif((count%3 == 0),
				Pseq([14, \, \, \, 7, \, \, -2, 0, \, 0, \, \, \, \, 4], inf),
				Pseq([6, \, 0, \, \, 6, \, 0, \, \, 0, \, 4, 14, \, \], inf),

				6),
			\modAmp, 5,
			\fade, 0.6- ((count-20)* 0.059)
		);
		status = "FM Bass faded, Menace Bass rises";

	}
	{true} {~fmbass = ~patternDict[\fm]; ~lec = ~patternDict[\lec]; "end of lecture reached".postln;};
	~addVolume.value(\lec, ~volPlus, ~volMax);
	~addVolume.value(\fm, (~volPlus * 0.8), ~volMax);
	postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);
	~lec.quant_(4);
	~fm.quant_(4);
}

