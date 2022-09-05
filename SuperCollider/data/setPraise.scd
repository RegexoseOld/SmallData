
~setPraise = {
	|counter|
	var c, s_name, dura, status, count, in_count, send_add;
	dura = Env.new([1,0], [count], [-2]).asPseg;
	count = floor(counter * ~factor).asInteger;
	s_name = "praise";
	status = "zero status";
	5.do({|i|
		Pbind(\instrument, \praise,
			\freq, Pxrand([Pwhite(120, 240, 1), Pwhite(240, 480, 1)], 1), \amp, ~fbVol *1.1, \pulRate, 20, \bpf, 500, \rls, Pn(0.3, 1), \sustain, 0.3, \send, -35).play});
	c = case
	{(count > 0) && (count <= 5)} {
		in_count = count - 0;
		send_add = in_count * 5.5;
		Pbindef(\sn1, \outfx, ~fx1Bus, \send, -35 + send_add);
		~reverb.set(\mx, 0.8, \room, 0.91, \bpf, (in_count % 5) * 0.3, \damp, 0.1, \cgain, 4);

		status = "wachsender Hall auf Pbindef(\sn1)";
	}
	{(count > 5) && (count <= 10)} {
		in_count = count - 5;
		send_add = in_count * 5;
		Pbindef(\sn1, \send, 5 - send_add);
		Pbindef(\bd1, \outfx, ~fx1Bus, \send, -35 + send_add);
		~reverb.set(\mx, 0.9, \room, 0.91, \bpf, 0.3, \damp, 0.1, \cgain, 4);

		status = "sn weniger bd mehr hall";
	}
	{(count > 10) && (count <= 20)} {
		in_count = count - 10;
		send_add = in_count * 3;
		Pbindef(\sn1, \send, -35);
		Pbindef(\bd1, \outfx, ~fx1Bus, \send, -35);
		Pbindef(\org2, \outfx, ~fx1Bus, \send, -35 + send_add);
		~reverb.set(\mx, 0.9, \room, 0.91, \bpf, 0.002, \damp, 0.1, \cgain, 3);
		status = "organ hall";
	}
	{(count > 20) && (count <= 30)} {
		in_count = count - 20;
		send_add = in_count * 3;
		Pbindef(\hh1, \outfx, ~fx1Bus, \send, -35 + send_add );
		~reverb.set(\mx, 0.9, \room, 0.9, \bpf, 0.03, \damp, 0.1, \cgain, 3);
		status = "hh1 freqency range";
	}
	{true} {"end of insinuation reached".postln;};
	postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);

}
