~setObj01 = {
	|counter|
	var c, s_name, dura, notes, status, count, l, f, a;
	//"\nset Obj01\n".postln;
	postf("\nsetting %\t with count %\n", s_name, counter );
	s_name = "lecture";
	count = floor(counter * ~factor).asInteger;
	status = "zero status";
	dura = Env.new([1,0], [count], [-2]).asPseg;

	5.do({|i| Pbind(\instrument, \lecture,
		\freq, [exprand(80, 90 + i), exprand(160, (160 + i))], \amp, 0.01, \filTime, 0.02, \rls, Pn(0.5, 1)).play});
	c = case
	{(count > 0) && (count <=10)}	{// resync all patterns

			"resync".postln;
			~objects[\obj1].keys.do({|k| Pbindef.all[k].stop; postf("stopped %   , pattern %  \n", k, Pbindef.all[k].isPlaying)});
			//Pbind(\instrument, \lecture, \freq, [200, 228], \amp, 0.01, \rls, Pn(t.beatDur*2, 1)).play;
			notes = ~reset[\obj1][\melo][\a];
			Pbindef(\fm,  \rls, 1, \dur, 4, \degree, Pseq(notes, inf) , \fade, count * 0.003);
			//notes =  notes.collect({|n| Array.fill(4, { n + rrand(-0.001, 0.001) } )}); // Multichannel expansion by 4
			Pbindef(\lec, \rls, 1, \dur, 4, \degree, Pseq(notes, inf) -12 , \filTime, 0.5, \fade, count * 0.04);
			Pbindef(\atak, \dur, Pwrand([4, [1/2, 3/4, 1.5].choose], [(0.2 + (count* 0.15)), count.reciprocal].normalizeSum, inf),
				\which, Pxrand([0,1,2],inf), \fade, 1 - (count*0.06), \send, -3 - (count * 4));
			//multichannel expansion
		"add patterns".postln;
			notes = ~reset[\obj1][\melo][\a];
			3.do({|i|
				var sym, add;
				sym = ('lec'.asString ++ i).asSymbol;
				// add additional pattern
				add = Pbindef(sym, *~reset[\obj1][\lec].asPairs); // initialisieren
				add = Pbindef(sym, \degree, Pseq(notes, inf) -12, \atk, Pwhite(0.05, 0.15, inf) + (count * 1.2),
					\rls, 0.8 + (count * 0.02), \sustain, Pkey(\rls),  \filTime, Pwhite(0.03, 0.4, inf), count * 0.04); //anpassen
				~objects[\obj1].add(sym -> add);
			});
			//Pbindef(\atak, \dur, 1); // set dur to the exact same value as \lec and \fm.
		~objects[\obj1].keys.do({|k| postf("play %   , pattern %  \n", k, Pbindef.all[k]);
			Pbindef.all[k].quant_(8);
			Pbindef.all[k].play(t);
		});

		status = "Bassmelo 1 faded, ataks ordnen sich";

	}

		////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////     10     bis     20    //////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////


	{count == 11}{
		notes = ~reset[\obj1][\melo][\b];
		 ['lec', 'lec0', 'lec1', 'lec2'].do({|k|
			var p = Pbindef.all[k];
			postf("editing %\n", k);
			p = Pbindef(k, \degree, Pseq(notes, inf) -12, \dur, 2);
			p.quant_(8);
			//p.play(t)
		});
		Pbindef(\fm, \dur, 2, \degree, Pseq(notes, inf));
		Pbindef(\atak, \dur, 2, \which, Pseq([\, 2, \, 2, \, \, \, 1, \, \, 2, \, \, 2, \, \], inf), \amp, Pwhite(0.05, 0.12, inf));
		//"replay".postln;
		// ~objects[\obj1].keys.do({|k| postf("play %\n", k); Pbindef.all[k].play(t, quant:1)});
		status = "b pattern";
	}
	{count == 12}{
		notes = ~reset[\obj1][\melo][\c];
		 ['lec', 'lec0', 'lec1', 'lec2'].do({|k|
			var p = Pbindef.all[k];
			postf("editing %\n", k);
			p = Pbindef(k, \degree, Pseq(notes, inf) -12, \dur, 2);
			p.quant_(8);
			//p.play(t)
		});
		Pbindef(\fm, \dur, 2, \degree, Pseq(notes, inf));
		Pbindef(\atak, \dur, 2, \which, Pseq([\, 2, \, 2, \, \, \, 1, \, \, 2, \, \, 2, \, \], inf), \amp, Pwhite(0.05, 0.12, inf));
		//"replay".postln;
		// ~objects[\obj1].keys.do({|k| postf("play %\n", k); Pbindef.all[k].play(t, quant:1)});
		status = "c pattern";
	}
	{count == 13}{
		notes = ~reset[\obj1][\melo][\d];
		 ['lec', 'lec0', 'lec1', 'lec2'].do({|k|
			var p = Pbindef.all[k];
			postf("editing %\n", k);
			p = Pbindef(k, \degree, Pseq(notes, inf) -12, \dur, 2);
			p.quant_(8);
			//p.play(t)
		});
		Pbindef(\fm, \dur, 2, \degree, Pseq(notes, inf));
		Pbindef(\atak, \dur, 1, \which, Pseq([\, 2, \, 2, \, \, \, 1, \, \, 2, \, \, 2, \, \], inf), \amp, Pwhite(0.05, 0.12, inf));
		//"replay".postln;
		// ~objects[\obj1].keys.do({|k| postf("play %\n", k); Pbindef.all[k].play(t, quant:1)});
		status = "d pattern";
	}
	{count == 14}{
		notes = ~reset[\obj1][\melo][\e];
		  ['lec', 'lec0', 'lec1', 'lec2'].do({|k|
			var p = Pbindef.all[k];
			postf("editing %\n", k);
			p = Pbindef(k, \degree, Pseq(notes, inf) -12, \dur, 1/4);
			p.quant_(8);
			//p.play(t)
		});
		Pbindef(\fm, \dur, 1/4, \degree, Pseq(notes, inf));
		Pbindef(\atak, \dur, 1/2, \which, Pseq([\, 2, \, 2, \, \, \, 1, \, \, 2, \, \, 2, \, \], inf), \amp, Pwhite(0.05, 0.12, inf));
		//"replay".postln;
		// ~objects[\obj1].keys.do({|k| postf("play %\n", k); Pbindef.all[k].play(t, quant:1)});
		status = "e pattern";
	}
	{count == 15}{
		notes = ~reset[\obj1][\melo][\f];
		 ['lec', 'lec0', 'lec1', 'lec2'].do({|k|
			var p = Pbindef.all[k];
			postf("editing %\n", k);
			p = Pbindef(k, \degree, Pseq(notes, inf)-12, \dur, 1/4);
			p.quant_(8);
			//p.play(t)
		});
		Pbindef(\fm, \dur, 1/4, \degree, Pseq(notes, inf));
		Pbindef(\atak, \dur, 1/2, \which, Pseq([\, 2, \, 2, \, \, \, 1, \, \, 2, \, \, 2, \, \], inf), \amp, Pwhite(0.05, 0.12, inf));
		status = "f pattern";
	}
	{count == 16}{
		var notes2 = ~reset[\obj1][\melo][\g];
		notes = ~reset[\obj1][\melo][\f];

		['lec', 'lec0', 'lec1', 'lec2'].do({|k|
			var p = Pbindef.all[k];
			postf("editing %\n", k);
			p = Pbindef(k, \degree, Pseq(notes2, inf) -12);
			p.quant_(8);
			});
		Pbindef(\fm, \dur, 1/4, \degree, Pseq(notes, inf));
		//Pbindef(\atak, \dur, 1/2, \which, Pseq([\, 2, \, 2, \, \, \, 1, \, \, 2, \, \, 2, \, \], inf), \amp, Pwhite(0.05, 0.12, inf));

		status= "f + g pattern";
	}
	{count == 17}{
		var notes2 = ~reset[\obj1][\melo][\g];
		notes = ~reset[\obj1][\melo][\f];

		['lec', 'lec0', 'lec1', 'lec2'].do({|k|
			var p = Pbindef.all[k];
			postf("editing %\n", k);
			p = Pbindef(k, \degree, Pseq(notes2, inf) -12, \crv, [-3.0, -7.0, 1.0, 5.0].choose, \center, Pwhite(-0.9, 0.9, inf), \cgain, Pwhite(3, 5, inf), \distort, Pwhite(1.5, 2.3, inf));
			p.quant_(8);
			});
		Pbindef(\fm, \dur, 1/4, \degree, Pseq(notes, inf));
		//Pbindef(\atak, \dur, 1/2, \which, Pseq([\, 2, \, 2, \, \, \, 1, \, \, 2, \, \, 2, \, \], inf), \amp, Pwhite(0.05, 0.12, inf));

		status= "f + g pattern";
	}
	{count == 18}{
		var notes2 = ~reset[\obj1][\melo][\g];
		notes = ~reset[\obj1][\melo][\f];

		['lec', 'lec0', 'lec1', 'lec2'].do({|k|
			var p = Pbindef.all[k];
			postf("editing %\n", k);
			p = Pbindef(k, \degree, Pseq(notes2, inf) -12, \crv, [-3.0, -7.0, 1.0, 5.0].choose, \filTime, Pwhite(0.3, 0.6, inf), \rls, Pwhite(0.6, 1.3, inf), \sus, 1.3);
			p.quant_(8);
			});
		Pbindef(\fm, \dur, 1/4, \degree, Pwrand([Pseq(notes), Pseq(notes2)], [0.8, 0.2], inf));

		status= "lec chooses sounds, fm chooses patterns f or g";
	}
	{count == 19}{
		var notes2 = ~reset[\obj1][\melo][\g];
		var notes3 = ~reset[\obj1][\melo][\e];
		notes = ~reset[\obj1][\melo][\f];
		Pbindef(\fm, \dur, 1/4, \degree, Pwrand([Pseq(notes), Pseq(notes2), Pseq(notes3)], [0.2, 0.6, 0.2], inf));

		status= "lec chooses sounds, fm chooses patterns f or g or e";
	}
	{count == 20}{
		notes = ~reset[\obj1][\melo][\h];
		['lec', 'lec0', 'lec1', 'lec2'].do({|k|
			var p = Pbindef.all[k];
			postf("editing %\n", k);
			p = Pbindef(k, \dur, 1, \degree, Pseq(notes, inf) -12, \crv, [-3.0, -7.0, 1.0, 5.0].choose, \filTime, Pwhite(0.3, 0.6, inf), \rls, Pwhite(0.6, 1.3, inf), \sus, 1.3);
			p.quant_(8);
			});
		Pbindef(\fm, \dur, 1, \degree, Pseq(notes, inf));

		status= "lec chooses sounds, fm chooses patterns f or g or e";
	}
	{(count > 20) && (count <= 30)}	{
			var notes2 = ~reset[\obj1][\melo][\i];
			notes = ~reset[\obj1][\melo][\h];
			['lec', 'lec0', 'lec1', 'lec2'].do({|k|
				var p = Pbindef.all[k];
				postf("editing %\n", k);
				p = Pbindef(k, \dur, 1, \degree, Pif((count%3 == 0), Pseq(notes2, inf) -12, Pseq(notes, inf) -12, Pseq(notes, inf) -12));
				p.quant_(8);
			});
			Pbindef(\fm, \dur, 1, \degree, Pseq(notes2, inf));

			status= "transition to reset of object 1";
		}
		{(count > 30)}{

		~objects[\obj1].keys.do({|k| ['lec0', 'lec1', 'lec2'].do({|l| Pbindef.all[l].clear; ~objects[\obj1].removeAt(l) })});
		"what is alive?".postln;
		~objects[\obj1].keys.do({|k| k.postln; postf("object  % active % \n ", k, Pbindef.all[k].isPlaying)});
			status = "reset object 1 circle";
		}
	{true} { "end of lecture reached".postln;};
	postf("\n new status \t %\n", status);

}

