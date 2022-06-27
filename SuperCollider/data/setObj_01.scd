~setObj01 = {
	|s_name, counter|
	var c, dura, notes, status, count, l, f, a;
	//"\nset Obj01\n".postln;
	count = floor(counter * ~factor).asInteger;
	status = "zero status";
	dura = Env.new([1,0], [count], [-2]).asPseg;

	5.do({|i| Pbind(\instrument, \lecture,
		\freq, [exprand(80, 90 + i), exprand(160, (160 + i))], \amp, 0.05, \filTime, 0.02, \rls, Pn(0.5, 1)).play});
	c = case
	{(count > 0) && (count <=10)}	{
		notes = ~objects[\obj1][\melo][\a];
		Pbindef(\lec, \degree, notes, \fade, count * 0.02);
		Pbindef(\fm, \degree, notes, \fade, count * 0.01);
		Pbindef(\atak, \dur, Pwrand([1, Pwhite(1/8, 1/2, 1)], [(0.2 + (count*0.15)),count.reciprocal].normalizeSum,inf), \which, Pxrand([0,1,2],inf), \fade, 1 - (count*0.06));
		status = "Bassmelo 1 faded, ataks ordnen sich";}

	{(count > 10) && (count <= 15)}	{
		if (count == 11, { // resync all patterns
			Routine.new({
				['lec', 'fm', 'atak'].do({|k| postf("stopped %\n", k); Pbindef.all[k].stop});
				Pbind(\instrument, \lecture, \freq, [800, 828], \amp, 0.1, \rls, Pn(t.beatDur*2, 1)).play;
				(t.beatDur*4).wait;
				Pbindef(\atak, \dur, 1);
				['lec', 'fm', 'atak'].do({|k| postf("play %\n", k); Pbindef.all[k].play(t, quant:1)});
			}).play(t);

		});
		notes = ~objects[\obj1][\melo][\c];
		Pbindef(\lec, \degree, notes);
		Pbindef(\fm, \degree, notes);
		status = "stop and restart obj 1";

	}
	{true} { "end of lecture reached".postln;};
	postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);

}

