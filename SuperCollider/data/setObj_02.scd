~setObj02 = {// represents the rauschen
	|counter|
	var c, dura, notes, status, count, s_name;
	//"\nset Obj01\n".postln;
	postf("\nsetting %\t with count %\n", s_name, counter );
	s_name = "concession";
	count = floor(counter * ~factor).asInteger;
	status = "zero status";
	dura = Env.new([1,0], [count], [-2]).asPseg;
	Pbind(\instrument, \concession, \buf, Pxrand(~buffers[\tonal], 10), \dur, 0.1, \fShift, 0.1, \amp, 0.02).play(t);

	c = case
	{(count > 0) && (count <=10)}{
		status = "start up noise";
	}
	{(count > 10) && (count <=20)}	{// resync all patterns
		Pbindef(\biz, \dur, 0.5, \atk, 0.003, \rls, 0.004, \phs, Pwhite(0, 50, inf), \tRate, Pseq([1, \, \, 1, \, \, 5, \], inf) * count,
			\pulseL, Pwhite(60, 120, inf), \pulseH, Prand([400, 1200], inf));
		Pbindef(\atag, \dur, 0.5, \which, Pseq([0, \, \, 2, \, \, 0, \], inf), \fdur, Pwhite(0.02, 0.08, inf), \rls, 0.12, \sus, 0);

		['hh01', 'bd01', 'sn01'].do{
			|k|
			Pbindef(k, *~reset[\obj2][k].asPairs);
		};
		Pbindef(\sn01, \dur, 1, \rate, Pif((count%3 ==0), Pseq([\, \, 1, \, \, \, \, \, 1, 1, 1, \, \, \, \, \], inf),
			Pseq([\, \, 1, \, \, \, \, \, \, \, 1, \, \, \, \, \], inf)
		),
		\pan, Pwhite(-1.0, 1.0, inf), \fade, 0.3 + (count * 0.05));

		~objects[\obj2].keys.do({|k| postf("play %   , pattern %  \n", k, Pbindef.all[k]);
			Pbindef.all[k].quant_(8)});

		status = "Perc1";

	}

		////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////     10     bis     20    //////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////


	{count == 11}{

		status = "b pattern";
	}
	{count == 12}{

		status = "c pattern";
	}
	{count == 13}{

		status = "d pattern";
	}
	{count == 14}{

		status = "e pattern";
	}
	{count == 15}{
		Pbindef(\bd01,  \rate, 1 );
		Pbindef(\sn01,  \dur, 0.5, \rate, Pseq([\, 1], inf) );
		Pbindef(\hh01,  \dur, 0.25, \buf, Prand(~buffers[\hh], inf) );

		status = "techno beat";
	}
	{count == 16}{


		status= "f + g pattern";
	}
	{count == 17}{


		status= "f + g pattern";
	}
	{count == 18}{

		status= "lec chooses sounds, fm chooses patterns f or g";
	}
	{count == 19}{

		status= "lec chooses sounds, fm chooses patterns f or g or e";
	}

	{count == 20}{

		status= "lec chooses sounds, fm chooses patterns f or g or e";
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

