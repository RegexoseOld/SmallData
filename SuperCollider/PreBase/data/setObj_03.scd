~setObj03 = {
	|counter|
	var c, s_name, dura, notes, status, count, in_count;
	//in_count steuert den sound in den 5er segmente
	//"\nset Obj01\n".postln;
	s_name = "Object 3";
	count = floor(counter * ~factor).asInteger;
	postf("\nsetting %\t with count %\n", s_name, count);
	status = "zero status";
	dura = Env.new([1,0], [count], [-2]).asPseg;
	5.do({|i|
		Pbind(\instrument, \insinuation,
			\freq, [exprand(100, 250), exprand(1700, 2300)], \amp, ~fbVol/2, \rls, Pn(3, 1)).play});
	c = case
	{(count > 0) && (count <=5)}	{// resync all patterns
		var chrd1, chrd2, chrd3;
		in_count = count - 0;
		chrd1 = Pseq(~reset[\obj3][\melo][\partA], inf);
		chrd2 = Pseq(~reset[\obj3][\melo][\partB], inf);
		chrd3 = Pseq(~reset[\obj3][\melo][\partC], inf);
		Pbindef(\org1, \midinote, chrd1, \fade, 0.2 + (in_count * 0.15));
		Pbindef(\org2, \dur, 2, \midinote, chrd1, \fade, 0.4 + (in_count * 0.11), \atk, 0.1, \fMul, in_count);
		status = "organ1 +2";
		status = "organ1 +2 long attack and release";
	}
	{(count > 5) && (count <= 10)}{
		var chrd1, chrd2;
		in_count = count - 5;
		chrd1 = Pseq(~reset[\obj3][\melo][\partA], 4) ;
		chrd2 = Pseq(~reset[\obj3][\melo][\partB], 4) ;

		Pbindef(\org1, \midinote,  Pseq([chrd1, chrd2],inf), \fade, 0.4, \modWidth, 0.5);
		Pbindef(\org2, \midinote, Pseq([chrd1, chrd2],inf), \fade, 1, \dur, 2, \pulRate, 4, \fMul, 4, \bpf, Pwhite(200, 200 * in_count, inf), \atk, 0.4, \rls, 1.5);
		status = "organ 2 ";
	}
	{(count > 10) && (count <= 15)}	{
		var chrd1, chrd2;
		in_count = count - 10;
		chrd1 = Pseq(~reset[\obj3][\melo][\partA], 16) ;
		chrd2 = Pseq(~reset[\obj3][\melo][\partB], 16) ;
		Pbindef(\org1, \midinote,  Pseq([chrd1, chrd2], inf), \fade, 0.4, \modWidth, 0.5);
		Pbindef(\org2, \midinote, Pseq([chrd1, chrd2], inf), \fade, 1.2, \dur, 1, \ampHz, in_count, \pulRate, 4, \fMul, 2, \bpf, Pwhite(80, 200, inf) * in_count, \rls, 0.2 * in_count);

		status= "segment 3 long release";
	}
	{(count > 15) && (count <= 20)}	{
		var chrd1, chrd2, chrd3;
		in_count = count - 15;
		chrd1 = Pseq(~reset[\obj3][\melo][\partA], 16) ;
		chrd2 = Pseq(~reset[\obj3][\melo][\partB], 16) ;
		chrd3 = Pseq(~reset[\obj3][\melo][\partC], 16) ;
		in_count = count - 15;
		Pbindef(\org2, \midinote, Pwrand([chrd1, chrd2, chrd3], [0.45, 0.2, 0.35], inf), \fade, 1.2, \dur, Pwrand([0.5, 2], [0.7, 0.3], inf), \ampHz, 1, \pulRate, 1, \fMul, 2, \bpf, Pwhite(80, 200, inf) * in_count);
		status= "segment 3 long release";
	}
	{(count > 20) && (count <= 25)}	{
			var chrd1, chrd2, chrd3;
		in_count = count - 20;
		chrd1 = Pseq(~reset[\obj3][\melo][\partA], 16) + in_count;
		chrd2 = Pseq(~reset[\obj3][\melo][\partB], 16) + in_count;
		chrd3 = Pseq(~reset[\obj3][\melo][\partC], 16) + in_count;
		in_count = count - 15;
		Pbindef(\org2, \midinote, Pwrand([chrd1, chrd2, chrd3], [0.45, 0.2, 0.35], inf), \fade, 0.8, \dur, Pwrand([0.5,2], [0.7, 0.3], inf), \ampHz, 1, \pulRate, 1, \fMul, 2, \bpf, Pwhite(80, 200, inf) * in_count);
		status = "parts A, B, C";
	}

	{(count > 25) && (count <= 30)}	{
		var chrd1, chrd2, chrd3;
		in_count = count - 25;
		chrd1 = Pseq(~reset[\obj3][\melo][\partA], 16) ;
		chrd2 = Pseq(~reset[\obj3][\melo][\partB], 16) ;
		chrd3 = Pseq(~reset[\obj3][\melo][\partC], 16) ;
		in_count = count - 15;
		Pbindef(\org2, \midinote, Pwrand([chrd1, chrd2, chrd3], [0.45, 0.2, 0.35], inf) + Pif(in_count.even, in_count.rand, in_count.rand * (-1)), \fade, 0.8, \dur, Pwrand([0.5,2], [0.7, 0.3], inf), \ampHz, 1, \pulRate, 1, \fMul, 2, \bpf, Pwhite(80, 200, inf) * in_count);
		status = "25-30";
	}

	{true} { "end of Object 3 reached".postln;};
	postf("\n new status \t %\n schedule clk03  %", status, ~clk03.queue.size);

}

