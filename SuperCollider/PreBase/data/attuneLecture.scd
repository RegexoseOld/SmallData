
~attLecture = {
	|counter|
	var c, s_name, dura, status, count, in_count, local_feedback;
	count = floor(counter * ~factor).asInteger;
    dura = Env.new([1,0], [count], [-2]).asPseg;
    local_feedback = 0.3;
	s_name = "lecture";
	status = "zero status";

	c = case
	{(count > 0) && (count <= 10)} {
		in_count = count - 0;
        //Pbindef(\pr, \fade, in_count * 0.1);
         Pbindef(\lec, \fade, in_count * ~fadeInc);
        status = "fading in lecture";
	}
	{(count > 10) && (count <= 20)} {
		in_count = count -10;

		status = "lecture status 2";
	}
	{(count > 10) && (count <= 20)} {

		status = "lecture status 3";
	}
	{true} {"end of insinuation reached".postln};

      //das sollte die gleiche Note sein, aber stakkato und gut hörbar
    5.do({|i|
		Pbind(\instrument, \bell2,
			\midinote, [~melos[\melo][\lec][0], ~melos[\melo][\lec][0] + 12],
            \amp, ~fbVol * local_feedback, \pan, Pwhite(-1.0, 1.0, 5),
            \atk, 0.05, \rls, 0.14,
            \dur, 0.25
    ).play});
    ~addVolume.value(\lec, ~volPlus, ~volMax, ~volThres);
    postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status)

}
