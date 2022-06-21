~setDissent = {
		|s_name, counter|
		var c, dura, now, amp, status, count;
		count = floor(counter * ~factor).asInteger;
		status = "zero status";
		dura = Env.new([1,0], [count], [-2]).asPseg;
		5.do({|i|
			Pbind(\instrument, \dissent,
				\width, Pwhite(0.4, 0.9, 1), \freq, Pxrand([200, 300], 1), \amp, 0.06, \atk, Pn(Pwhite(0.01, 0.05), 1), \rls, Pn(Pwhite(0.02, 0.59), 1), \sustain, 0.15, \pulseMul, 0.35, \resoFreq, 3000).play});
		c = case
		{(count > 0) && (count <= 5)} {// 1. Feedback Sound
			~dis = Pbindef(\dis, *~reset[\patternDict][\dis].asPairs);
			~dis = Pbindef(\dis, \resoFreq, 1200 + (100*count), \modF, 0.8  + (count * 0.22));
			status = "Modulation wird schneller";

		}
		{(count > 5) && (count <=10)} {
			~dis = Pbindef(\dis, \dur, 1, \amp, 0.6, \rls, (0.35 * count), \sustain, Pkey(\rls), \pulseMul, count.reciprocal, \gendAmp, 0.9, \ampDist, 6, \durDist, 4, \modF, 0.4, \maxfreq, 120 *count, \ffreq, count*160);
			status = "Weirder Ton schleicht sich ein";
		}
		{(count > 10) && (count <=20)} {
			~dis = Pbindef(\dis,
				\degree, Prand([[0, 4, 7], [0, 3, 7]], inf) * Pif(count.even, 2, 1, 1),
				\dur, Pif(count.even, 2, 0.25, 1),
				\rls, Pif(count.even, 2.5, 0.1, 0.5),
				\sustain, Pkey(\rls),
				\atk, 0.02,
				\minfreq, 200 * (count.linlin(0, count, 1.1, 1.9)),
				\maxfreq, Pkey(\minfreq) * 4,
				\gendAmp, 0.9,
				\pulseMul, Pif(count.even, 0.45, 1.3, 0.4),
			    \modF, Pif(count.even, 0.5 + (count * 0.02), 0.9, 0.5),
				\outfx, ~fx3Bus,
				\send, Pif(count.even, -25 + (count * 0.8), -40, -35)
			);
			status = "Abwechselnd stottern und manisches Fegen";
		}
		{(count > 20) && (count <= 30)} {
			~dis = Pbindef(\dis, *~reset[\patternDict][\dis].asPairs);
			~dis = Pbindef(\dis, \degree, Pseq([
				0, \, \, \,
				0, 4, 2, \,
				-1, \, -1, 2,
				0, \, -4, \,
				\, \, \, -4,
				-1, -1, \, -3,
				\, \, \, \
				], inf),
			\atk, 0.3,
			\rls, 1.3,
			\sustain, Pkey(\rls),
			\width, Pif(count.even, 0.1, Pwhite(0.4, 0.9, inf), 2000),
			\dur, 1,
			\pulseMul, 0.8,
			\add, (count -20) * 0.05,
			\lag, 0.4,
			\gendAmp, 0.8,
			\gendScale, 0.3,
			\ffreq, Pif(count.even, Pwhite(800, 2000, inf), 2000, 800),
			\resoFreq, Pif(count.even, 200, 2000, 2000),
			\outfx, ~fx1Bus,
			\send, -22
			);
			status = "traurige Melodei, abwechselnd hell oder dunkel ";
		}
		{true} {~dis = ~patternDict[\dis]; "end of dissent reached".postln};
		~addVolume.value(\dis, ~volPlus, ~volMax);
		~dis.quant_(4);
		postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);

	};
