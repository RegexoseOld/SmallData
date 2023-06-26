
~attPraise = {
	|counter|
	var c, s_name, dura, status, count, in_count, local_feedback;
	count = floor(counter * ~factor).asInteger;
    dura = Env.new([1,0], [count], [-2]).asPseg;
    local_feedback = 0.3;
	s_name = "praise";
	status = "zero status";

	c = case
	{(count > 0) && (count <= 5)} {
		in_count = count - 0;
        //Pbindef(\pr, \fade, in_count * 0.1);
        local_feedback = 0.4;
		status = "fading in praise (65= F)";
	}
	{(count > 5) && (count <= 10)} {
		in_count = count -5;
		//Pbindef(\b1, \modF, 1.0 - (in_count* 0.2));


		status = "modF back";
	}
	{(count > 10) && (count <= 20)} {

		status = "organ hall";
	}
	{(count > 20) && (count <= 30)} {

		status = "hh1 freqency range";
	}
	{true} {"end of insinuation reached".postln};

      //das sollte die gleiche Note sein, aber stakkato und gut hörbar
    5.do({|i|
		Pbind(\instrument, \bell2,
			\midinote, [~melos[\melo][\pr][0], ~melos[\melo][\pr][0] + 12],
            \amp, ~fbVol * local_feedback, \pan, Pwhite(-1.0, 1.0, 5),
            \atk, 0.05, \rls, 0.14,
            \dur, 0.25
    ).play});
    ~addVolume.value(\pr, ~volPlus, ~volMax, ~volThres);
    postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status)

}
