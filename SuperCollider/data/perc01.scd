~setConcession = {
	|s_name, counter|
	var c, dura, pat, status, count;
	dura = Env.new([1,0], [count], [-2]).asPseg;
	status = "zero status";
	count = floor(counter * ~factor).asInteger;
	Pbind(\instrument, \concession, \buf, Pxrand(~buffers[\tonal], 10), \dur, 0.1, \fShift, 0.1,  \amp, 0.02).play(t);
	c = case
	{count == 0}{
		/*Quant -4 sollte normalerweise ausreichen um einen 4er Takt zuende zuspielen. */
		Pbindef(\zahl, *~reset[\patternDict][\zahl].asPairs).quant_(-4);
		Pbindef(\bd01, *~reset[\patternDict][\bd01].asPairs).quant_(-4);
		Pbindef(\sn01, *~reset[\patternDict][\sn01].asPairs).quant_(-4);
		Pbindef(\hh01, *~reset[\patternDict][\hh01].asPairs).quant_(-4);
	}
	{(count > 1) && (count <=5)}{
		~delay.set(\maxdel, 0.9, \deltime, 0.1, \lpf, 1200, \decayT, 3.6, \mul, 0.8, \sweep, count/2);
		Pbindef(\bd01, \rate, Pseq([1, \, \, \, \, \, 1, \, 1, 1, \, \, \, \, \, \ ], inf) );
		Pbindef(\sn01, \buf, Pwrand([~buffers[\sn][5], ~buffers[\sn][11]], [0.7, 0.3].normalizeSum, inf), \rate, Pseq([\, \, 1, \, \, \, \, \, \, \, 1, \, \, 1, 1, 1], inf));
		Pbindef(\hh01, \buf, Pseq([Pn(~buffers[\Bells][2], 14), ~buffers[\sweep][0], ~buffers[\Bells][2] ], inf), \send, -12);
			Pbindef(\zahl, \buf, Pseq([~buffers[\zahlen][7], ~buffers[\zahlen][6], ~buffers[\zahlen][5], ~buffers[\zahlen][4], ~buffers[\zahlen][3], ~buffers[\zahlen][2], ~buffers[\zahlen][1], ~buffers[\zahlen][0]], inf));
			status = "dichtere BD";
		}

		{(count > 5) && (count <= 10)}{
			~delay.set(\maxdel, 0.9, \deltime, count.reciprocal, \sweep, 3.2, \decayT, 0.3 * count, \mul, 0.99);
			~percArray.do({|n, i| if (n == ~buffers[\low][2], { ~percArray[i] = ~buffers[\bd][1]})});
			~con = Pbindef(\con, \dur, 1/4, \buf, Pseq(~percArray, inf), \send, -30 + (count * 2.5), \rate, [0.51, 0.85, 1.54, 2.34, 3.5].choose, \fade, Prand([0.7, 0.9, 0.99], inf));
			status = "random percArray mit delay";
		}
		{(count > 10) && (count <= 20)}{
			~delay.set(\maxdel, 0.1, \deltime, 0.1, \sweep, 1.5, \decayT, 0.2, \mul, 1);
			~con = Pbindef(\con,
				\buf, Pseq([
					Pn(Prand(~buffers[\low], 1), 3),
					Pn(Prand(~buffers[\himid], 1), 1),
					Pn(Prand(~buffers[\mid],1), 2),
					Prand(~buffers[\hi], 1),
					Pn(Prand(~buffers[\mid],1), 1)], inf),
				\rate, Pwhite(0.9, 1.11, inf),
				\dur, 1,
				\outfx, ~fx1Bus,
				\send, -30 + ((count%11) * 4)
			);
			~reverb.set(\bpf, (count * 0.3));
			status = "random percbuffers mit wachsendem Hall";
		}

		{(count > 20) && (count <= 30)}{
			~reverb.set(\bpf, 0.0001);
			~percArray2 = Array.fill(32, {~buffers[\dry][4]});
			~percArray2.put(0, ~buffers[\sn][9]);
			~percArray2.put(1, ~buffers[\bd][8]);
			~percArray2.put(3, ~buffers[\bd][9]);
			~percArray2.put(6, ~buffers[\sweep][0]);
			~percArray2.put(12, ~buffers[\sn][1]);
			~percArray2.put(16, ~buffers[\stakkato][0]);
			//~percArray2.replace((16..26), ~buffers[\bd][9]);
			pat = Pseq([~buffers[\sn][9], ~buffers[\bd][8], \, ~buffers[\bd][9],
				\, \,  ~buffers[\sweep][0], \,
				\, \, \, \,
				~buffers[\sn][1], \, \, \,
				~buffers[\stakkato][0], \, \, \,
				Pseq([\], 12)
			], inf);
			if (count >= 25, {pat.stop; pat.isPlaying.postln;});
			if (count%3 ==0, {~percArray2.do({|n, i| if (n == ~buffers[\dry][4], { ~percArray2[i] = ~buffers[\dry].choose})})},
				{~percArray2.do({|n, i| if (n == ~buffers[\dry][4], {~percArray2[i] = ~buffers[\tonal].choose})})});

			~con = Pbindef(\con, \dur, 1/4, \buf, Pif(count <=25, pat, Pseq(~percArray2, inf), ~buffers[\dry][4]), \send, -30, \rate, 1.0, \rls, 4, \sus, Pkey(\rls), \bpf, 800, \rq, 2.0, \fShift, 0.01, \mix, -0.9, \thr, 0.25, \cgain, 3.4, \outfx, ~fx3Bus, \send, -35 + ((count -20) * 3));
			status = "drum 'n bass figurs";
		}
		{true}{ "end of setConcession reached".postln};
		~addVolume.value(\con, ~volPlus, ~volMax);
		postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);
		//~con.quant_(4);
	}

