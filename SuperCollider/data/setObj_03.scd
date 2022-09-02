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
			\freq, [exprand(100, 250), exprand(1700, 2300)], \amp, 0.04, \rls, Pn(3, 1)).play});
	c = case
	{(count > 0) && (count <=5)}	{// resync all patterns
		var chrd1, chrd2, chrd3;
		in_count = count - 0;
		chrd1 = Pseq(~reset[\obj3][\melo][\partA], inf);
		chrd2 = Pseq(~reset[\obj3][\melo][\partB], inf);
		chrd3 = Pseq(~reset[\obj3][\melo][\partC], inf);
		Pbindef(\org1, \midinote, chrd1, \fade, 0.2 + (in_count * 0.1));
		Pbindef(\org2, \midinote, chrd1, \fade, 0.5 + (in_count * 0.11), \atk, 0.8 - (in_count * 0.18), \rls, Pkey(\atk));
		status = "organ1 +2";
	}
	{(count > 5) && (count <= 10)}{
		var chrd1, chrd2;
		in_count = count - 5;
		chrd1 = Pseq(~reset[\obj3][\melo][\partA], inf) ;
		chrd2 = Pseq(~reset[\obj3][\melo][\partB], inf) ;

		Pbindef(\org1, \midinote,  chrd2, \fade, 0.4, \modWidth, 0.5);
		Pbindef(\org2, \midinote, chrd2, \fade, 0.75, \dur, 1, \ampHz, in_count, \pulRate, 4, \fMul, in_count/2, \bpf, Pwhite(120, 400, inf) * in_count, \atk, 0.04, \rls, 0.1);
		status = "organ 2 higher spectrum";
	}
	{(count > 10) && (count <= 15)}	{
		var chrd1, chrd2;
		in_count = count - 10;
		chrd1 = Pseq(~reset[\obj3][\melo][\partA], 16) ;
		chrd2 = Pseq(~reset[\obj3][\melo][\partB], 16) ;
		Pbindef(\org1, \midinote,  Pseq([chrd1, chrd2], inf), \fade, 0.4, \modWidth, 0.5);
		Pbindef(\org2, \midinote, Pseq([chrd1, chrd2], inf), \fade, 0.8, \dur, 1, \ampHz, in_count, \pulRate, 4, \fMul, 2, \bpf, Pwhite(80, 200, inf) * in_count);
		status= "segment 3 long release";
	}
	{(count > 15) && (count <= 20)}	{
		var notes1 = Pseq(~reset[\obj1][\melo][\hast1], 3);
		var notes2 = Pseq(~reset[\obj1][\melo][\hast2], 1);
		in_count = count - 15;
		notes = Pseq([notes1, notes2], inf);

		['lec', 'lec0', 'lec1', 'lec2'].do({|k|
			postf("editing %\n", k);
			Pbindef(k, \dur, 2, \degree, notes -12, \fade, 0.76, \rls, 0.1, \sus, Pkey(\rls));
		});
		Pbindef(\fm, \dur, 2, \degree, notes);
		status= "segment 3 long release";
	}
	{(count > 20) && (count <= 25)}	{

		status= "segment 3 long release";
	}

	{(count > 20) && (count <= 25)}{

		status = "c, d pattern";
	}

	{true} { "end of lecture reached".postln;};
	postf("\n new status \t %\n", status);

}

