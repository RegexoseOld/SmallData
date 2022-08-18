~setObj02 = {// represents the beat
	|counter|
	var c, dura, notes, status, count, in_count, s_name, bd, sn, hh, arp;
	//"\nset Obj01\n".postln;
	s_name = "beat";
	count = floor(counter * ~factor).asInteger;
	postf("\nsetting %\t with count %\n", s_name, counter );
	status = "zero status";
	dura = Env.new([1,0], [count], [-2]).asPseg;
	Pbind(\instrument, \concession, \buf, Pxrand(~buffers[\tonal], 10), \dur, 0.1, \fShift, 0.1, \amp, 0.02).play(t);

	c = case
	{(count > 0) && (count <=5)}{
		var bd1, bd2, h1, arp1;
		bd = ~buffers[\bd][10];
		sn = ~buffers[\sn][11];
		hh = [Prand(~buffers[\hh_spec], 14), ~buffers[\hh][0], ~buffers[\hh_spec][1] ];
		bd1 = Pseq(~reset[\obj2][\melo][\bd01].collect({|it, i| if (it == 1, {it = bd}, {it = Rest()})}), inf);
		bd2 = Pseq(~reset[\obj2][\melo][\bd02].collect({|it, i| if (it == 1, {it = bd}, {it = Rest()})}), inf);
		h1 = Pseq(hh, inf);
		arp1 = Pseq(~reset[\obj2][\melo][\arp1], 4);
		in_count = count - 0;
		Pbindef(\hh1, \fade, Pwhite(0.3, 1, inf), \fShift, Prand([0.5, 1.5, 4], inf), \bpf, Pseq((400, 450 .. 1800).mirror, inf), \rq, Pwhite(0.3, 3, inf), \rate, Pwrand([1, 1.2], [0.5, 0.5], inf), \dur, 1/2);
		Pbindef(\bd1, \buf, bd1, \fShift, 0.0002, \dur, 1, \fade, 0.9);
		Pbindef(\biz, \dur, 1/16, \rls, 0.1, \fade, 1 * dura);
		Pbindef(\arp, \dur, 1/16, \buf, arp1, \fade, 0.5, \bpf, Pseq((1800, 1750 .. 800).mirror, inf));
		//Pbind(\instrument, \concession, \buf,  arp1, \dur, 1/32, \fade, 0.4, \rate, 1.0 * in_count).play(t);

		status = "beat1";
	}
	{(count > 5) && (count <=10)}	{// resync all patterns
		bd = ~buffers[\bd][0];
		sn = ~buffers[\sn][6];
		hh = ~buffers[\hh][3];
		Pbindef(\bd1, \buf, Pseq(~reset[\obj2][\melo][\bd03], inf));
		Pbindef(\sn1, \buf, Pseq(~reset[\obj2][\melo][\sn01], inf));
		Pbindef(\hh1, \buf, Pseq(~reset[\obj2][\melo][\bd03], inf));
		Pbindef(\biz, \dur, 0.5, \atk, 0.003, \rls, 0.004, \phs, Pwhite(0, 50, inf), \tRate, Pseq([1, \, \, 1, \, \, 5, \], inf) * count,
			\pulseL, Pwhite(60, 120, inf), \pulseH, Prand([400, 1200], inf));
		Pbindef(\atag, \dur, 0.5, \which, Pseq([0, \, \, 2, \, \, 0, \], inf), \fdur, Pwhite(0.02, 0.08, inf), \rls, 0.12, \sus, 0);

		['hh1', 'bd1', 'sn1'].do{
			|k|
			Pbindef(k, *~reset[\obj2][k].asPairs);
		};

		status = "Perc1";

	}

	{(count > 20) && (count <= 30)}	{

			status= "transition to reset of object 1";
		}
		{(count > 30)}{
			status = "reset object 1 circle";
		}
	{true} { "end of object2 reached".postln;};
	postf("\n new status \t %\n", status);

}

