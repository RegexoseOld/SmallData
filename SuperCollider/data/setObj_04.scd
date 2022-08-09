~setObj04 = {// represents the rauschen
	|counter|
	var c, dura, notes, status, count, s_name;
	//"\nset Obj04\n".postln;
	s_name = "rauschen";
	postf("\nsetting %\t with count %\n", s_name, counter );

	count = floor(counter * ~factor).asInteger;
	status = "zero status";
	dura = Env.new([1,0], [count], [-2]).asPseg;
	//Pbind(\instrument, \concession, \buf, Pxrand(~buffers[\tonal], 10), \dur, 0.1, \fShift, 0.1, \amp, 0.02).play(t);

	c = case
	{(count > 1) && (count <=10)}{
		// todo: ich will count - mal ein eigenes pattern machen dass 12 mal spielt und dann am liebsten wieder verschwindet
		count.do{
			|c|
			var key, new;
			key = 'knk' ++ c;
			new = Pbindef(key, *~reset[\obj4][\sampl].asPairs);
			new = Pbindef(key, \buf, ~buffers[\klics][0], \dur, Pwhite(1.9, 2.1, inf) - (count/10), \spos, Pwhite(0, 1500, inf), \bpf, Pwhite(300, 1000, inf), \rate, 1.8, \amp, 0.2/ count, \fade, Pgeom(0.35, 0.999, count *10));
			new.quant(1);
			new.play(t);
		};
		status = "start up noise";
	}


		////////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////     10     bis     20    //////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////

{(count > 11) && (count <=20)}{
		var new;
		new = Pbindef(\rau, *~reset[\obj4][\sampl].asPairs);
		new = Pbindef(\rau, \buf, ~buffers[\klics][2], \dur, Pwhite(0.5, 1.1, inf), \rate, Pseq((1.8, 1.7 .. 1.0).mirror, inf), \fade, Pgeom(0.35, 0.999, count *5), \outfx, ~fx1Bus, \send, Pif((count%3== 0), Pseq([-5, -20, -20, -20], inf), -30) );
		new.quant(1);
		new.play(t);

	}

	{true} { "end of object2 reached".postln;};
	postf("\n new status \t %\n", status);

}

