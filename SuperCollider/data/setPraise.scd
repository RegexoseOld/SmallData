
~setPraise = {
	|counter|
	var c, s_name, dura, status, count, in_count;
	dura = Env.new([1,0], [count], [-2]).asPseg;
	count = floor(counter * ~factor).asInteger;
	s_name = "praise";
	status = "zero status";
	5.do({|i|
		Pbind(\instrument, \praise,
			\freq, Pxrand([Pwhite(120, 240, 1), Pwhite(240, 480, 1)], 1), \amp, ~fbVol, \pulRate, 20, \bpf, 500, \rls, Pn(0.3, 1), \sustain, 0.3, \send, -35).play});
	c = case
	{(count > 0) && (count <= 5)} {
		in_count = count - 0;
		Pbindef(\sn1, \outfx, ~fx1Bus, \send, -35 + (in_count * 4.3));
		~reverb.set(\mx, 0.99, \room, 0.91, \bpf, 0.001, \damp, 0.3, \cgain, 4);

		status = "wachsender Hall auf Pbindef(\sn1)";
	}
	{(count > 5) && (count <= 10)} {

		status = "stottern schneller, random verstimmung wird weniger";
	}
	{(count > 10) && (count <= 20)} {

		status = "statische Figur wird höher";
	}
	{(count > 20) && (count <= 30)} {

		status = "heavy Arpeggio, Wechselt bei gerade/ungeraden Counts";
	}
	{true} {~pr = ~patternDict[\pr];"end of insinuation reached".postln;};
	//~addVolume.value(\pr,(~volPlus *1.6), ~volMax);
	postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);

}
