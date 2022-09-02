~setObj01 = {
	|counter|
	var c, s_name, dura, notes, status, count, in_count;
	//in_count steuert den sound in den 5er segmente
	//"\nset Obj01\n".postln;
	s_name = "Object 1";
	count = floor(counter * ~factor).asInteger;
	postf("\nsetting %\t with count %\n", s_name, count);
	status = "zero status";
	dura = Env.new([1,0], [count], [-2]).asPseg;

	5.do({|i| Pbind(\instrument, \lecture,
		\freq, [exprand(80, 90 + i), exprand(160, (160 + i))], \amp,~fbVol/2, \fade, 0.2, \filTime, 0.02, \rls, Pn(0.5, 1)).play});
	c = case
	{(count > 0) && (count <=5)}	{// resync all patterns
        in_count = count - 0;
		"resync".postln;
		~objects[\obj1].keys.do({|k| Pbindef.all[k].stop; postf("stopped %   , pattern %  \n", k, Pbindef.all[k].isPlaying)});
		notes = Pseq(~reset[\obj1][\melo][\a], inf) + 60;
		Pbindef(\fm,  \rls, 1, \dur, 1/2, \midinote, notes, \fade, in_count * 0.05);
		Pbindef(\lec, \rls, 1, \dur, 1/2, \midinote, notes -24 , \filTime, 0.5, \fade, in_count * 0.22);

		//multichannel expansion
		"add mulitple lec patterns".postln;
		3.do{|i|
			var sym, add;
			sym = ('lec'.asString ++ i).asSymbol;
			// add additional pattern
			add = Pbindef(sym, \dur, 1/2, \midinote, notes - 12, \distort, 2.0,
				\rls, 0.8 + (in_count * 0.02), \sustain, Pkey(\rls), \filTime, Pwhite(0.03, 0.4, inf) * (in_count * 0.04), \fade, in_count * 0.2, \amp, 0.1, \thr, 0.65, \cgain, 5); //anpassen
			~objects[\obj1].add(sym -> add);
		};

		~objects[\obj1].keys.do({|k| postf("play %   , pattern %  \n", k, Pbindef.all[k]);
			Pbindef.all[k].quant_(8);
			Pbindef.all[k].play(t);
		});
		status = "segment 1 fades in";
	}
	{(count > 5) && (count <= 10)}{
		in_count = count - 5;
		notes = Pseq(~reset[\obj1][\melo][\b], inf) + 60;
		['lec', 'lec0', 'lec1', 'lec2'].do({|k|
			postf("editing %\n", k);
			Pbindef(k, \dur, 1, \midinote, notes -24, \fade, 1, \rls, 1 - (in_count * 0.18), \sus, Pkey(\rls));
		});
		Pbindef(\fm, \dur, 1, \midinote, notes);
		status = "segment 2 ändert sound";
	}
	{(count > 10) && (count <= 15)}	{
		var notes1 = Pseq(~reset[\obj1][\melo][\hast1], 3)+ 60;
		var notes2 = Pseq(~reset[\obj1][\melo][\hast2], 1)+ 60;
		in_count = count - 10;
		notes = Pseq([notes1, notes2], inf);

		['lec', 'lec0', 'lec1', 'lec2'].do({|k|
			postf("editing %\n", k);
			Pbindef(k, \dur, 4, \midinote, notes -12, \fade, 1, \rls, 0.1 + (in_count * 0.25), \sus, Pkey(\rls));
		});
		Pbindef(\fm, \dur, 4, \midinote, notes);
		status= "segment 3 long release";
	}
	{(count > 15) && (count <= 20)}	{
		var notes1 = Pseq(~reset[\obj1][\melo][\hast1], 3)+ 60;
		var notes2 = Pseq(~reset[\obj1][\melo][\hast2], 1)+ 60;
		in_count = count - 15;
		notes = Pseq([notes1, notes2], inf);

		['lec', 'lec0', 'lec1', 'lec2'].do({|k|
			postf("editing %\n", k);
			Pbindef(k, \dur, 2, \midinote, notes -12, \fade, 1, \rls, 0.1, \sus, Pkey(\rls));
		});
		Pbindef(\fm, \dur, 2, \midinote, notes);
		status= "segment 3 long release";
	}
	{(count > 20) && (count <= 25)}	{
		var notes1 = Pseq(~reset[\obj1][\melo][\ha5], 3)+ 60;
		var notes2 = Pseq(~reset[\obj1][\melo][\ha6], 1)+ 60;
		in_count = count - 20;
		notes = Pseq([notes1, notes2], inf);

		['lec', 'lec0', 'lec1', 'lec2'].do({|k|
			postf("editing %\n", k);
			Pbindef(k, \dur, 1, \midinote, notes -12, \fade, 1, \rls, 0.6, \sus, Pkey(\rls), \modRate, 0.8 * in_count);
		});
		Pbindef(\fm, \dur, 1, \midinote, notes);
		status= "segment 5 und 6 hintereinander";
	}

	{(count > 25) && (count <= 30)}{
		var notes1 = Pseq(~reset[\obj1][\melo][\ha1], 1) + 60;
		var notes2 = Pseq(~reset[\obj1][\melo][\ha2], 1) + 60;
		var notes3 = Pseq(~reset[\obj1][\melo][\ha3], 1) + 60;
		var notes4 = Pseq(~reset[\obj1][\melo][\ha4], 1) + 60;
		in_count = count - 25;
		notes = Pseq([notes1, notes2, notes3, notes4], inf);
		['lec', 'lec0', 'lec1', 'lec2'].do({|k|
			postf("editing %\n", k);
			Pbindef(k, \midinote, notes -12, \dur, 1/2);
		});
		Pbindef(\fm, \dur, 1/2, \midinote, notes);
		status = "Einzelsegmente hintereinander schneller werdend";
	}


	{true} { "end of Object 1 reached".postln;};
	postf("\n new status \t %\n", status);

}

