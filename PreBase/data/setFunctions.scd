(
dis : {
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

},
ins: {
	|s_name, counter|
	var c, dura, oneShot, amp, status, count;
	count = floor(counter * ~factor).asInteger;
	status = "zero status";
	dura = Env.new([1,0], [count], [-2]).asPseg;
	5.do({|i|
		Pbind(\instrument, \insinuation,
			\freq, [exprand(100, 250), exprand(1700, 2300)], \amp, 0.04, \rls, Pn(3, 1)).play});
	c = case
	{(count > 0) && (count <= 5)} {
		~ins = Pbindef(\ins,  *~reset[\patternDict][\ins].asPairs);
		~ins = Pbindef(\ins, \fShift, 100 + (50 *count));
		status = "Figur wird höher";
	}
	{(count > 5) && (count <= 10)} {~ins = Pbindef(\ins, \slideTime, count * 0.7, \dur, 4, \atk, 0.8 , \rls, 4.0, \sustain, 4.0, \preamp, 0.9, \degree, Pseq([(0 -count),-5, 0, (2 -count)], inf) );
		status = "Schlierenfigur";
	}

	{(count > 10) && (count <= 20)} {
		if (count% 4 == 0, {oneShot = Pbindef(\ins2, *~reset[\ins].asPairs);
			oneShot = Pbindef(\ins2, \degree, Pseq([
				Pseq([-5],5), Pseq([\r],13),
				[-8, 0], Pseq([\r], 15),
				[-5, 3], Pseq([\r],15),
				Pseq([\r], 16)
		], 2) + count, \amp, 0.4, \dur, 1/16).play(t);"one shot Modulo 4".postln;} );

		~ins = Pbindef(\ins, \slideTime, 3.5 - (count* 0.02), \maxF, 600 + (count * 10), \dur, 4,
			\atk, 0.8 - (count * 0.04), \rls, 4.0 - (count * 0.16), \sustain, Pkey(\rls),
			\preamp, 0.9,
			\degree, Pseq([(10 - count),-5, 0, (2 -count)], inf) );
		status = "Noten werden immer kürzer und tiefer";
	}
	{(count > 20) && (count <= 30)} {
		~ins = Pbindef(\ins, \ctranspose, 14, \dur, 2,
			\degree, Pseq([[-5, 0], [0,5], [-5, 0], [-9,-5]], inf) -2,
			\sus, 2, \c1, Pxrand([7, -7], inf),
			\modWidth, Pxrand([0.3, 2.4], inf),
			\preamp, 0.22,
			\fShift, 150 + ((count-20) * 80), \noiseFreq, 3.5
		);
		status = "Akkordschleier wird immer höher";
	}

	{true} {~ins = ~patternDict[\ins]; "end of insinuation reached".postln};
	~addVolume.value(\ins, ~volPlus, ~volMax);
	~ins.quant_(4);
	postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);

},

lec:  {
	|s_name, counter|
	var c, dura, pat, status, count;
	count = floor(counter * ~factor).asInteger;
	status = "zero status";
	dura = Env.new([1,0], [count], [-2]).asPseg;
	~dis = Pbindef(\dis, *~reset[\patternDict][\lec].asPairs);
	~fm = Pbindef(\dis, *~reset[\patternDict][\fm].asPairs);
	5.do({|i| Pbind(\instrument, \lecture,
		\freq, [exprand(80, 90 + i), exprand(160, (160 + i))], \amp, 0.01, \filTime, 0.02, \rls, Pn(0.5, 1)).play});
	c = case
	{count ==1}	{
		~lec = Pbindef(\lec, \dur, 1,
			\degree, Pseq([0, \r, \r, \r,
				-6, Pseq([\r], 3),
				-5, Pseq([\r], 3),
				-6, Pseq([\r], 3),
	], inf)); status = "Bassfigur 1";}
	{count ==2}	{~lec = Pbindef(\lec, \dur, 1, \degree, Pseq([0, Pseq([\r], 7), -5, Pseq([\r], 7)], inf)); status = "Bassfigur 2";}
	{count ==3}	{~lec = Pbindef(\lec, \dur, 1,\degree, Pseq([0, \, \, \, -6, \, \, \, -5,Pseq([\r], 7)], inf)); status = "Bassfigur 3";}
	{count ==4}	{~lec = Pbindef(\lec, \dur, 1,\degree, Pseq([0, \, \, \, -6, \, \, \, -5, \, \, \, -6, \, \, \], inf)); status = "Bassfigur 4";}
	{count ==5}	{~lec = Pbindef(\lec, \dur, 1,\degree, Pseq([0, \, \, \, -6, \, \, \, -5, \, \, \, -7, \, \, \], inf)); status = "Bassfigur 5";}


	{(count > 5) && (count <= 10)} {
		~lec = Pbindef(\lec,
			\dur, 1,
			\degree, Pseq([0, -6, -5, -7], inf),
			\fade, 0.4 - (count * 0.02), \distort, 1.4, \filTime, 0.6 -((count -5) * 0.05));
		~fmbass = Pbindef(\fm, \dur, 1, \degree, Pseq([0, -6, -5, -7], inf), \fade, (count-5) * 0.05 , \atk, (count-4).reciprocal);
		status = "Schnellere Figur und anderer Synth dazu";
	}
	{(count > 10) && (count <= 12)} {
		~lec = Pbindef(\lec, \fade, 0);
		~fmbass = Pbindef(\fm, \dur, 1/4, \degree, Pseq([0, \, \, \, -6, \, \, \, -5, \, \, \, -7, \, \, \], inf), \fade, 0.4);
		status = "FM Bass Figur 1";
	}
	{(count > 12) && (count <= 14)}{
		~lec = Pbindef(\lec, \fade, 0);
		~fmbass = Pbindef(\fm, \dur, 1/4, \degree, Pseq([0, \, \, \, -6, \, \, \, \, \, \, \, 6, \, \, \], inf), \fade, 0.4);
		status = "FM Bass Figur 2";
	}
	{(count > 14) && (count <= 16)}{
		~lec = Pbindef(\lec, \dur, 1, \degree, Pseq([0, -6, -5, -7], inf), \distort, 1.4, \filTime, 0.6 -((count -5) * 0.05));
		~fmbass = Pbindef(\fm,\dur, 1/4, \degree, Pseq([0, \, \, \, -6, \, \, \, \, \, 6, \, 11, \, \, \], inf), \fade, 0.4);
		status = "FM Bass Figur 3";
	}
	{(count > 16) && (count <= 18)}{
		~lec = Pbindef(\lec, \fade, 0);
		~fmbass = Pbindef(\fm,\dur, 1/4, \degree, Pseq([0, \, \, \, -6, \, -6, \, -6, \, 6, \, 11, \, \, \], inf), \fade, 0.4);
		status = "FM Bass Figur 4";
	}
	{(count > 18) && (count <= 20)}{
		~fmbass = Pbindef(\fm,  \dur, Pseq([Pseq([1/4], 4), 6/4, Pseq([1/4], 6) ], inf), \degree, Pseq([0, \, 0, \, 0,  6, \, 11, \, \, \], inf), \fade, 0.4); status = "FM Bass Figur 5";}

	{(count > 20) && (count <= 30)} {
		//~fmbass.pause;
		~reverb.set(\bpf, 0.002);
		~lec = Pbindef(\lec, \degree, Pseq([0, -1],inf) -12, \dur, 3, \filTime, 0.85, \cgain, 5, \distort, 1.5, \fade, (count -20) * 0.13, \outfx, ~fx1Bus, \send, -5);
		pat = Pbind(\instrument, \lecture, \sus, 0.3, \rls, 1.0 - ((count-20) * 0.03),
			\degree, Pif(count.even, Pseq([12, 11, 11, 8, 8, \r, 6, Pseq([\], 24)], inf), Pseq([1, \, -3, \, -5, \, -8, \], inf), Pseq([-12],1)),
			\dur, Pif(count.even, 1, 2, 1/8),
			\distort, 1.3,
			\det1, 1.0 - (count * 0.007), \det2, 1.0 + (count * 0.007),
			\filTime, Pif(count.even, 0.6, 0.8, 0.4 ),
			\amp, Prand([0.4, 0.3, 0.2, 0.1], 9),
			\outfx, Pif(count.even,~fx2Bus, ~fx3Bus, ~fx1Bus ),
			\send, Pif(count.even, -35+ ((count-20)* 2), -40 + ((count-20)* 2), -40),
		).play(t, quant:4);

		~delay.set(\decayT, 0.1 * (count-15));
		~fmbass = Pbindef(\fm, \dur, Pif((count%3==0), 1/4, Pseq([1/8], 15), 1/4),
			\degree, Pif((count%3 == 0),
				Pseq([14, \, \, \, 7, \, \, -2, 0, \, 0, \, \, \, \, 4], inf),
				Pseq([6, \, 0, \, \, 6, \, 0, \, \, 0, \, 4, 14, \, \], inf),

				6),
			\modAmp, 5,
			\fade, 0.6- ((count-20)* 0.059)
		);
		status = "FM Bass faded, Menace Bass rises";

	}
	{true} {~fmbass = ~patternDict[\fm]; ~lec = ~patternDict[\lec]; "end of lecture reached".postln;};
	~addVolume.value(\lec, ~volPlus, ~volMax);
	~addVolume.value(\fm, (~volPlus * 0.8), ~volMax);
	postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);
	~lec.quant_(4);
	~fmbass.quant_(4);
},


con: {
	|s_name, counter|
	var c, dura, pat, status, count;
	dura = Env.new([1,0], [count], [-2]).asPseg;
	status = "zero status";
	count = floor(counter * ~factor).asInteger;
	Pbind(\instrument, \concession, \buf, Pxrand(~buffers[\tonal], 10), \dur, 0.1, \fShift, 0.1,  \amp, 0.02).play(t);
	c = case
	{count == 0}{~con = Pbindef(\con, *~reset[\patternDict][\con].asPairs)}
	{count ==1}{
		~percArray.put(6, ~buffers[\himid][2]);
		~percArray.put(10, ~buffers[\himid][3]);
		~percArray.put(14, ~buffers[\low][2]);
		~con = Pbindef(\con,\buf, Pseq(~percArray,inf));
		status = "percArray startet";

	}
	{(count > 1) && (count <=5)}{
		~delay.set(\maxdel, 0.9, \deltime, 0.1, \lpf, 1200, \decayT, 3.6, \mul, 0.8, \sweep, count/2);
		~percArray.do({|n, i| if (n == ~buffers[\low][2], {[i + "  "+ n].postln; ~percArray[i] = ~buffers[\bd][1]})});
		~con = Pbindef(\con, \buf, Pseq(~percArray, inf), \send, -35 + (count * 6), \bpf, 100);
		status = "percArray mit delay";
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
	{true}{	~con = ~patternDict[\con]; "end of setConcession reached".postln};
	~addVolume.value(\con, ~volPlus, ~volMax);
	postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);
	~con.quant_(4);
},

pr: {
	|s_name, counter|
	var c, pat, dura, status, count;
	dura = Env.new([1,0], [count], [-2]).asPseg;
	count = floor(counter * ~factor).asInteger;
	status = "zero status";
	5.do({|i|
		Pbind(\instrument, \praise,
			\freq, Pxrand([Pwhite(120, 240, 1), Pwhite(240, 480, 1)], 1), \amp, 0.13, \pulRate, 20, \bpf, 500, \rls, Pn(0.3, 1), \sustain, 0.3).play});
	c = case
	{(count > 0) && (count <= 5)} {
		~pr = Pbindef(\pr, *~reset[\patternDict][\pr].asPairs);
		~pr = Pbindef(\pr, \ffreq, 800, \degree, Pif(
			count.even, Pseq([[0, 12], \r, \r, \r,
				[9, 12], \r, \r, \r,
				Pseq([\], [-4, 8])], inf),
			Pseq([[12, 9 ,4], \r, \r, \r,
				[9, 12], \r, \r, \r,
				[12, 4, 10], \r, \r, \r], inf)),
		\ampScale, 0.75 + (count * 0.15),
		\send, -40 + (count * 8)
		);
		status = "Abwechselnde Notenfolgen wachsender Hall";
	}
	{(count > 5) && (count <= 10)} {
		~pr = Pbindef(\pr, \degree, Pseq([[0, 4, 7], [1, 3, 7], [4, 2, 5], [1, 3, 6]], inf) * Pwrand([1, (1 - count.reciprocal)], [0.9, 0.1].normalizeSum, inf), \dur, 3, \ampHz, count -4, \bpf, 120 + (count * 100), \send, -40);
		status = "stottern schneller, random verstimmung wird weniger";
	}
	{(count > 10) && (count <= 20)} {
		~pr = Pbindef(\pr,
			\degree, Pseq([[count]], inf),
			\dur, 1,
			\ampHz, 4,
			\fRate, 8,
			\pulRate, 2,
			\fade, 0.8
		);
		status = "statische Figur wird höher";
	}
	{(count > 20) && (count <= 30)} {
		~pr = Pbindef(\pr,
			\degree, -8 + Pif(count.even, 24, 0, 1),
			\ampHz, Pif(count.even, 0.25, (count-20)*2, 1),
			\pulWidth, 0.75,
			\ampScale, Pif(count.even, 0.3, Pwhite(0.6, 3.9, inf), 1),
			\fRate, 0.25,
			\pulRate, Pif(count.even, 0.125, (count-20)*0.25, 1),
			\fMul, Pif(count.even, 0.25, (count-20)*2, 1),
			\sustain, Pif(count.even, 0.1, 0.5, 1),
			\atk,  Pif(count.even, 0.02, 0.09, 1),
			\rls, Pif(count.even, 0.15, 0.5, 1),
			\dur, Pif(count.even, 1/8, 1/4, 1),
			\width, Pif(count.even, 1.1, 0.5, 1),
			\ffreq, Pn(Pgeom(100, 1.1, count), inf),
			\rq, Pif(count.even, 0.2, 0.8, 1),
			\fade, Pif(count.even, 0.6, 0.8, 0.9)
		);
		status = "heavy Arpeggio, Wechselt bei gerade/ungeraden Counts";
	}
	{true} {~pr = ~patternDict[\pr];"end of insinuation reached".postln;};
	~addVolume.value(\pr,(~volPlus *1.6), ~volMax);
	~pr.quant_(4);
	postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);

},

rausch: {
	|count|
	var c, dura, now;
	postf("\nsetting rauschen with count %\t", count);
	dura = Env.new([1,0], [count], [-2]).asPseg;
	c = case
	{(count > 5) && (count <= 10)}{Pbindef(\rausch, \ffreq, Pxrand([300, 666, 760], inf) , \rq, Pxrand((0.05, 0.1 .. 2.0), inf), \rls, 0.3, \amp, 0.1);}
	{true} {"end of rauschen cases".postln};
	Pbindef(\rausch).quant_(4);
};

alloc: {
	|s_name, count|
	var c;
	~totalUtts = ~totalUtts + 1; // unbedingt wieder löschen, ist nur test
	~setGlobal.value();
	~updateUtts.(s_name);
	postf("\n \n+++ ++++ ++++ \n\nnew UTT %\t \n", s_name);
	postf("\ntotalUtts %\n", ~totalUtts);
	postf("\nuttDict: %\t", ~uttDict);
	c = case
	{s_name == \lecture} {~setLecture.value(s_name, count);}
	{s_name == \praise} {~setPraise.value(s_name, count)}
	{s_name == \dissent} {~setDissent.value(s_name, count)}
	{s_name == \concession} {~setConcession.value(s_name, count)}
	{s_name == \insinuation} {~setInsinuation.value(s_name, count)}
	{true}{"end of allocation".postln};
};

setGlobal: {
	var c;
	c = case
	{~totalUtts >= 40} {"changed Scale".postln; Scale.choose}
	{~totalUtts >= 25} {"mic ohne hall".postln; ~mic.set(\send, -38);}
	{~totalUtts == 20} {"mic mit hall".postln; ~mic.set(\send, -12);}
	{~totalUtts ==10} {~uttDict.keys.do({|k| k.postln; ~uttDict[k]= 0});~startAllPatterns.()}
	{~totalUtts >=6} {~setRauschen.(~totalUtts)}
	{~totalUtts >=5} {Pbindef(\rausch).play(t, quant:1); ~mic.set(\send, -20); ~metro.play(t, quant:1);}
	{~totalUtts > 0 } {~mic.set(\send, (-35 + (~totalUtts * 6)));  }
	{true} {"end of global settings".postln};

}

)