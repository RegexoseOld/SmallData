~setObj04 = {// represents the rauschen
	|counter|
	var c, dura, notes, status, count, s_name, in_count;
	//"\nset Obj04\n".postln;
	s_name = "rauschen";
	postf("\nsetting %\t with count %\n", s_name, counter );

	count = floor(counter * ~factor).asInteger;
	status = "zero status";
	dura = Env.new([1,0], [count], [-2]).asPseg;
	c = case
	{(count > 1) && (count <=10)}{
		in_count = count - 1;
		in_count.do{
			|c|
			var key, new;
			key = 'knk' ++ c;
			new = Pbindef(key, *~reset[\obj4][\sampl].asPairs);
			new = Pbindef(key, \buf, ~buffers[\klics][0], \dur, Pwhite(1.9, 2.1, inf) - (in_count/10), \spos, Pwhite(0, 1500, inf), \bpf, Pwhite(300, 1000, inf), \rate, 1.8, \amp, 0.28/ in_count, \fade, Pgeom(0.45, 0.999, in_count *14));
			new.quant(1);
			new.play(t);
		};
		status = "start up noise";
	}


		////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////     10     bis     20    //////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////

{(count > 30) && (count <=40)}{
		var new;
		in_count = count-10;
		new = Pbindef(\rau, *~reset[\obj4][\sampl].asPairs);
		new = Pbindef(\rau, \buf, ~buffers[\klics][2], \dur, Pwhite(0.5, 1.1, inf), \rate, Pseq((1.8, 1.7 .. 1.0).mirror, inf), \fade, Pgeom(0.45, 0.9999, in_count *10), \outfx, ~fx1Bus, \send, Pif((in_count%3== 0), Pseq([-5, -20, -20, -20], inf), -30) );
		new.quant(1);
		new.play(t);
		status = "klic sound klic3"
	}

	{true} { "end of object2 reached".postln;};
	postf("\n new status \t %\n", status);

}

