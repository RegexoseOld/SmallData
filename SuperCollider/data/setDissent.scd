~setDissent = {
		|counter|
		var c, dura, s_name, amp, status, count, in_count;
		count = floor(counter * ~factor).asInteger;
	s_name = "dissent";
		status = "zero status";
		dura = Env.new([1,0], [count], [-2]).asPseg;
		5.do({|i|
			Pbind(\instrument, \dissent,
				\width, Pwhite(0.4, 0.9, 1), \freq, Pxrand([200, 300], 1), \amp, ~fbVol/2, \atk, Pn(Pwhite(0.01, 0.1), 1), \rls, Pn(Pwhite(0.02, 0.9), 1), \sustain, 0.15, \pulseMul, 0.35, \resoFreq, 3000).play});
		c = case
		{(count > 0) && (count <= 10)} {
		in_count = count - 0;
		Pbindef(\dis, \dur, 0.25, \midinote, Pseq([Prand([80, 84, 91, 100], 2), Prand([110, 93, 105, 100], 2)], in_count), \fade, 0.99, \gendAmp, 1, \maxfreq, 750 + (in_count * 100), \atk, 0.04, \rls, 0.1, \sustain, 0.4, \ffreq, Pwhite(400, 1000 + (in_count * 100), inf), \modF, 0.5).play;
		status = "dissent Synth kurz";

		}
		{(count > 10) && (count <=20)} {
		var add_send;
		in_count = count - 10;
		add_send = in_count * 4.8;
		Pbindef(\dis, \dur, 4, \midinote, Pseq([Prand([[80, 84], [91, 100]], 1)], 2), \fade, 0.69, \gendAmp, 0.9, \maxfreq, 750 + (in_count * 100), \atk, 1.9, \rls, 3.5, \sustain, 3,\ffreq, Pwhite(400, 1000 + (in_count * 100), inf), \modF, 0.2 + (in_count * 0.1)).play(~clk04, quant:1);

			status = "dissent synth lang mit modulation";
		}
		{(count > 20) && (count <=30)} {
		var add_send;
		in_count = count - 20;
		add_send = in_count * 4.8;
		Pbindef(\dis, \dur, Pwrand([0.25, 0.75, 1.5], [0.43, 0.49, 0.1].normalizeSum, inf), \midinote, Pseq([Prand([[80, 84], [91, 100]], 1)], in_count), \fade, 0.69, \gendAmp, 0.9, \maxfreq, 750 + (in_count * 100), \atk, 0.04, \rls, 0.5, \sustain, 0.5, \ffreq, Pwhite(400, 1000 + (in_count * 100), inf), \modF, 0.2 + (in_count * 0.1)).play(~clk04, quant:1);

			status = "dissent synth hühner";
		}


		{true} { "end of dissent reached".postln};
		//~addVolume.value(\dis, ~volPlus, ~volMax);

		postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);

	};
