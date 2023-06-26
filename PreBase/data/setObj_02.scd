~setObj02 = {// represents the beat
	|counter|
	var c, dura, notes, status, count, in_count, s_name, bd, sn, hh, arp;
	//"\nset Obj01\n".postln;
	s_name = "beat";
	count = floor(counter * ~factor).asInteger;
	postf("\nsetting %\t with count %\n", s_name, counter );
	status = "zero status";
	dura = Env.new([1,0], [count], [-2]).asPseg;
	Pbind(\instrument, \concession, \buf, Pxrand(~buffers[\tonal], 10), \dur, 0.1, \fShift, 0.1, \amp, ~fbVol/3).play;

	c = case
	{(count > 0) && (count <=5)}{
		var bd1, bd2, sn1, arp1;
		bd = ~buffers[\bd][10];
		sn = ~buffers[\sn][11];
		hh = [Prand(~buffers[\hh], 14), ~buffers[\hh][0], ~buffers[\hh][2] ];
		bd1 = Pseq(~reset[\obj2][\melo][\bd01].collect({|it, i| if (it == 1, {it = bd}, {it = Rest()})}), inf);
		sn1 = Pseq(~reset[\obj2][\melo][\sn01].collect({|it, i| if (it == 1, {it = sn}, {it = Rest()})}), inf);
		arp1 = Pseq(~reset[\obj2][\melo][\arp1], in_count);
		in_count = count - 0;
		Pbindef(\hh1, \fade, Pwhite(0.02, (in_count * 0.18), inf), \buf, Pseq(hh, inf),  \fShift, Prand([0.5, 1.5, 4], inf), \bpf, Pseq((400, 450 .. 1800).mirror, inf), \rq, Pwhite(0.3, 3, inf), \rate, Pwrand([1, 1.2], [0.5, 0.5], inf), \dur, 1/2);
		Pbindef(\bd1, \buf, bd1, \fShift, 0.0002, \dur, 1, \fade, 1);
		Pbindef(\sn1, \buf, sn1, \fShift, 0.05, \dur, 2, \fade, 0.9);
		/*Pbindef(\biz, \dur, 1/16, \rls, 0.1, \fade, 1 * (dura *3));
		Pbindef(\arp, \dur, 1/16, \buf, arp1, \fade, 0.8 * (dura *3), \bpf, Pseq((1800, 1750 .. 800).mirror, inf));*/

		status = "beat1";
	}
	{(count > 5) && (count <=10)}	{// resync all patterns
		var bd1, bd2, sn1, sn2, hh1;
		in_count = count - 5;
		bd = ~buffers[\bd][0];
		sn = ~buffers[\sn][3];
		hh = ~buffers[\hh][3];
		bd1 = Pseq(~reset[\obj2][\melo][\bd01].collect({|it, i| if (it == 1, {it = bd}, {it = Rest()})}), 3);
		bd2 = Pseq(~reset[\obj2][\melo][\bd02].collect({|it, i| if (it == 1, {it = bd}, {it = Rest()})}), 1);
		sn1 = Pseq(~reset[\obj2][\melo][\sn01].collect({|it, i| if (it == 1, {it = sn}, {it = Rest()})}), inf);
		sn2 = Pseq(~reset[\obj2][\melo][\sn02].collect({|it, i| if (it == 1, {it = sn}, {it = Rest()})}), inf);
		Pbindef(\bd1, \buf, Pseq([bd1, bd2], inf));
		Pbindef(\sn1, \buf, Pif(in_count.even, sn2, sn1), \dur, Pif(in_count.even, 0.125, 1), \fade, Pwhite(0.1, 0.99, inf), \bpf, 1600, \rate, 0.6 + (in_count * 0.2), \bpf, 1100);
		Pbindef(\hh1, \buf, hh, \fShift, 2, \bpf, 1800, \mix, 1);
		/*Pbindef(\biz, \dur, 0.25, \atk, 0.003, \rls, 0.04, \phs, Pwhite(0, 50, inf), \tRate, Pseq([1, \, \, 1, \, \, 5, \], inf) * in_count,
			\pulseL, Pwhite(60, 120, inf), \pulseH, Prand([400, 1200], inf), \fade, 1 * dura *2, \amp, 0.35);*/

		status = "Perc1";

	}

	{(count > 10) && (count <= 20)}	{
		var bd3, sn3,sn4, sn5, hh1;
		in_count = count - 10;
		bd = ~buffers[\bd][0];
		sn = ~buffers[\sn][4];
		hh = ~buffers[\dry][in_count];
		hh1 = Pseq(~reset[\obj2][\melo][\hh01].collect({|it, i| if (it == 1, {it = hh}, {it = Rest()})}), inf);
		sn3 = Pseq(~reset[\obj2][\melo][\sn03].collect({|it, i| if (it == 1, {it = sn}, {it = Rest()})}), 1);
		sn4 = Pseq(~reset[\obj2][\melo][\sn04].collect({|it, i| if (it == 1, {it = sn}, {it = Rest()})}), 1);
		sn5 = Pseq(~reset[\obj2][\melo][\sn05].collect({|it, i| if (it == 1, {it = sn}, {it = Rest()})}), 1);
		bd3 = Pseq(~reset[\obj2][\melo][\bd03].collect({|it, i| if (it == 1, {it = bd}, {it = Rest()})}), inf);
		Pbindef(\hh1, \buf, hh1, \dur, 0.125, \fade, 1, \cgain, 3, \rate, 1, \bpf, Pwhite(50, (in_count * 90), inf) + 350) ;
		Pbindef(\sn1, \buf, Pwrand([sn3, sn4, sn5], [0.6, 0.3, 0.1],inf), \dur, 0.25, \fade, 1, \cgain, 3, \rate, 1);
		Pbindef(\bd1, \buf, bd3, \rls, 1.0, \dur, 0.5);

		status= "additiver beat";
		}
		{(count > 20) && (count <= 30)}{
		var bd4, sn4;
		in_count = count - 20;
		bd = ~buffers[\bd][10];
		sn = ~buffers[\sn][6]; // long snare, vary spos and length
		hh = ~buffers[\hh][3];
		bd4 = Pseq(~reset[\obj2][\melo][\bd04].collect({|it, i| if (it == 1, {it = bd}, {it = Rest()})}), inf);
		sn4 = Pseq(~reset[\obj2][\melo][\sn04].collect({|it, i| if (it == 1, {it = sn}, {it = Rest()})}), inf);
		Pbindef(\bd1, \buf, bd4, \dur, 0.5);
		Pbindef(\sn1, \buf, sn4, Pwrand( [0.125, 0.25], [0.7, 0.3], inf));
		Pbindef(\hh1, \buf, hh, \dur, 0.25, \bpf, Pseq((1000, 1020 .. 2000).mirror, inf) + (in_count * 20), \amp, 0.5, \cgain, Pwhite(2, 5, inf), \pos, Pseq((-1.0, -0.9 .. 1.0).mirror, inf));
		status = "heavy beat";
		}
	{true} { "end of object2 reached".postln;};
	postf("\n new status \t %\n  queue clk02  %", status, ~clk02.queue.size);


}

