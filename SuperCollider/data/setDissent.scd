~setDissent = {
		|counter|
		var c, dura, s_name, amp, status, count, in_count;
		count = floor(counter * ~factor).asInteger;
	s_name = "dissent";
		status = "zero status";
		dura = Env.new([1,0], [count], [-2]).asPseg;
		5.do({|i|
			Pbind(\instrument, \dissent,
				\width, Pwhite(0.4, 0.9, 1), \freq, Pxrand([200, 300], 1), \amp, ~fbVol/2, \atk, Pn(Pwhite(0.01, 0.05), 1), \rls, Pn(Pwhite(0.02, 0.59), 1), \sustain, 0.15, \pulseMul, 0.35, \resoFreq, 3000).play});
		c = case
		{(count > 0) && (count <= 5)} {// 1. Feedback Sound

			status = "Modulation wird schneller";

		}
		{(count > 5) && (count <=10)} {

			status = "Weirder Ton schleicht sich ein";
		}
		{(count > 10) && (count <=20)} {

			status = "Abwechselnd stottern und manisches Fegen";
		}
		{(count > 20) && (count <= 30)} {

			status = "traurige Melodei, abwechselnd hell oder dunkel ";
		}
		{true} {~dis = ~patternDict[\dis]; "end of dissent reached".postln};
		//~addVolume.value(\dis, ~volPlus, ~volMax);

		postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);

	};
