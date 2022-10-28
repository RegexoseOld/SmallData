~setRauschen = {// represents the rauschen
	|counter|
	var c, dura, notes, status, count, s_name, in_count;
	//"\nset Obj04\n".postln;
	s_name = "Grundrauschen";
	postf("\nsetting %\t with count %\n", s_name, counter);

	count = floor(counter * ~factor).asInteger;
	status = "zero status";
	dura = Env.new([1,0], [count], [-2]).asPseg;
	c = case
	{(count > 1) && (count <=10)}{
		in_count = count - 1;
        status = "empty function";
	/*	in_count.do{
			|c|
			var key, new;
			key = 'knk' ++ c;
			new = Pbindef(key, *~reset[\obj4][\sampl].asPairs);
			new = Pbindef(key, \buf, ~buffers[\klics][0], \dur, Pwhite(1.9, 2.1, inf) - (in_count/10), \bpf, Pwhite(300, 1000, inf), \rate, 1.8, \amp, 0.58/ in_count, \fade, Pgeom(0.75, 0.999, in_count *2));
			new.play;
		}*/

	}
	{true} { "end of object2 reached".postln;};
	postf("\n new status \t %\n", status);

}

