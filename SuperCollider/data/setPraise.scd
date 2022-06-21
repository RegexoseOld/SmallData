
~setPraise = {
	|s_name, counter|
	var c, pat, dura, status, count;
	dura = Env.new([1,0], [count], [-2]).asPseg;
	count = floor(counter * ~factor).asInteger;
	status = "zero status";
	5.do({|i|
		Pbind(\instrument, \praise,
			\freq, Pxrand([Pwhite(120, 240, 1), Pwhite(240, 480, 1)], 1), \amp, 0.13, \pulRate, 20, \bpf, 500, \rls, Pn(0.3, 1), \sustain, 0.3).play});
	c = case
	{(count > 0) && (count <= 5)} {
		~pr = Pbindef(\pr, *~reset[\patternDict][\pr].asPairs);
		~pr = Pbindef(\pr, \ffreq, 800, \degree, Pif(
			count.even, Pseq([[0, 12], \r, \r, \r,
				[9, 12], \r, \r, \r,
				Pseq([\], [-4, 8])], inf),
			Pseq([[12, 9 ,4], \r, \r, \r,
				[9, 12], \r, \r, \r,
				[12, 4, 10], \r, \r, \r], inf)),
		\ampScale, 0.75 + (count * 0.15),
		\send, -40 + (count * 8)
		);
		status = "Abwechselnde Notenfolgen wachsender Hall";
	}
	{(count > 5) && (count <= 10)} {
		~pr = Pbindef(\pr, \degree, Pseq([[0, 4, 7], [1, 3, 7], [4, 2, 5], [1, 3, 6]], inf) * Pwrand([1, (1 - count.reciprocal)], [0.9, 0.1].normalizeSum, inf), \dur, 3, \ampHz, count -4, \bpf, 120 + (count * 100), \send, -40);
		status = "stottern schneller, random verstimmung wird weniger";
	}
	{(count > 10) && (count <= 20)} {
		~pr = Pbindef(\pr,
			\degree, Pseq([[count]], inf),
			\dur, 1,
			\ampHz, 4,
			\fRate, 8,
			\pulRate, 2,
			\fade, 0.8
		);
		status = "statische Figur wird höher";
	}
	{(count > 20) && (count <= 30)} {
		~pr = Pbindef(\pr,
			\degree, -8 + Pif(count.even, 24, 0, 1),
			\ampHz, Pif(count.even, 0.25, (count-20)*2, 1),
			\pulWidth, 0.75,
			\ampScale, Pif(count.even, 0.3, Pwhite(0.6, 3.9, inf), 1),
			\fRate, 0.25,
			\pulRate, Pif(count.even, 0.125, (count-20)*0.25, 1),
			\fMul, Pif(count.even, 0.25, (count-20)*2, 1),
			\sustain, Pif(count.even, 0.1, 0.5, 1),
			\atk,  Pif(count.even, 0.02, 0.09, 1),
			\rls, Pif(count.even, 0.15, 0.5, 1),
			\dur, Pif(count.even, 1/8, 1/4, 1),
			\width, Pif(count.even, 1.1, 0.5, 1),
			\ffreq, Pn(Pgeom(100, 1.1, count), inf),
			\rq, Pif(count.even, 0.2, 0.8, 1),
			\fade, Pif(count.even, 0.6, 0.8, 0.9)
		);
		status = "heavy Arpeggio, Wechselt bei gerade/ungeraden Counts";
	}
	{true} {~pr = ~patternDict[\pr];"end of insinuation reached".postln;};
	~addVolume.value(\pr,(~volPlus *1.6), ~volMax);
	~pr.quant_(4);
	postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);

}
