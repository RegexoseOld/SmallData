~setObj01 = {
	|s_name, counter|
	var c, dura, notes, status, count, l, f, a;
	//"\nset Obj01\n".postln;
	count = floor(counter * ~factor).asInteger;
	status = "zero status";
	dura = Env.new([1,0], [count], [-2]).asPseg;

	5.do({|i| Pbind(\instrument, \lecture,
		\freq, [exprand(80, 90 + i), exprand(160, (160 + i))], \amp, 0.09, \filTime, 0.02, \rls, Pn(0.5, 1)).play});
	c = case
	{(count > 0) && (count <=5)}	{
		(Pbindef.all.keys - Set['rausch', 'metronom']).postln;
		notes = ~objects[\obj1][\melo][\c];

		Pbindef(\lec, \degree, notes);
		Pbindef(\fm, \degree, notes);
		status = "Bassfigur 1";}
	{true} { "end of lecture reached".postln;};
	postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);

}

