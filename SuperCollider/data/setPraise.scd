
~setPraise = {
	|counter|
	var c, s_name, dura, status, count, in_count;
	dura = Env.new([1,0], [count], [-2]).asPseg;
	count = floor(counter * ~factor).asInteger;
	s_name = "praise";
	status = "zero status";
	postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);
	/*5.do({|i|
		Pbind(\instrument, \bell1,
			\freq, Pxrand([Pwhite(120, 240, 1), Pwhite(240, 480, 1)], 1), \amp, ~fbVol *1.1,  \rls, Pn(0.3, 1)).play});*/
	c = case
	{(count > 0) && (count <= 5)} {
		in_count = count -0;
		Pbindef(\b1, \modF, in_count* 0.2);
		Pbindef(\b2, \dep, in_count * 0.1);
		status = "modF";
	}
	{(count > 5) && (count <= 10)} {
		in_count = count -5;
		Pbindef(\b1, \modF, 1.0 - (in_count* 0.2));


		status = "modF back";
	}
	{(count > 10) && (count <= 20)} {

		status = "organ hall";
	}
	{(count > 20) && (count <= 30)} {

		status = "hh1 freqency range";
	}
	{true} {"end of insinuation reached".postln};


}
