
~setInsinuation = {
	|s_name, counter|
	var c, dura, oneShot, amp, status, count;
	count = floor(counter * ~factor).asInteger;
	status = "zero status";
	dura = Env.new([1,0], [count], [-2]).asPseg;
	5.do({|i|
		Pbind(\instrument, \insinuation,
			\freq, [exprand(100, 250), exprand(1700, 2300)], \amp, 0.04, \rls, Pn(3, 1)).play});
	c = case
	{(count > 0) && (count <= 5)} {
		~ins = Pbindef(\ins,  *~reset[\patternDict][\ins].asPairs);
		~ins = Pbindef(\ins, \fShift, 100 + (50 *count));
		status = "Figur wird höher";
	}
	{(count > 5) && (count <= 10)} {~ins = Pbindef(\ins, \slideTime, count * 0.7, \dur, 4, \atk, 0.8 , \rls, 4.0, \sustain, 4.0, \preamp, 0.9, \degree, Pseq([(0 -count),-5, 0, (2 -count)], inf) );
		status = "Schlierenfigur";
	}

	{(count > 10) && (count <= 20)} {
		if (count% 4 == 0, {oneShot = Pbindef(\ins2, *~reset[\patternDict][\ins].asPairs);
			oneShot = Pbindef(\ins2, \degree, Pseq([
				Pseq([-5],5), Pseq([\r],13),
				[-8, 0], Pseq([\r], 15),
				[-5, 3], Pseq([\r],15),
				Pseq([\r], 16)
		], 2) + count, \amp, 0.4, \dur, 1/16).play(t);"one shot Modulo 4".postln;} );

		~ins = Pbindef(\ins, \slideTime, 3.5 - (count* 0.02), \maxF, 600 + (count * 10), \dur, 4,
			\atk, 0.8 - (count * 0.04), \rls, 4.0 - (count * 0.16), \sustain, Pkey(\rls),
			\preamp, 0.9,
			\degree, Pseq([(10 - count),-5, 0, (2 -count)], inf) );
		status = "Noten werden immer kürzer und tiefer";
	}
	{(count > 20) && (count <= 30)} {
		~ins = Pbindef(\ins, \ctranspose, 14, \dur, 2,
			\degree, Pseq([[-5, 0], [0,5], [-5, 0], [-9,-5]], inf) -2,
			\sus, 2, \c1, Pxrand([7, -7], inf),
			\modWidth, Pxrand([0.3, 2.4], inf),
			\preamp, 0.22,
			\fShift, 150 + ((count-20) * 80), \noiseFreq, 3.5
		);
		status = "Akkordschleier wird immer höher";
	}

	{true} {~ins = ~patternDict[\ins]; "end of insinuation reached".postln};
	~addVolume.value(\ins, ~volPlus, ~volMax);
	~ins.quant_(4);
	postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);

}
