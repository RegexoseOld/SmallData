~setDissent = {
    |counter|
    var c, s_name, dura, status, count, in_count, local_feedback;
    count = floor(counter * ~factor).asInteger;
    s_name = "concession";
    status = "zero status";
    local_feedback = 0.3;
    dura = Env.new([1,0], [count], [-2]).asPseg;

    c = case
    {(count > 0) && (count <= 10)} {
        in_count = count - 0;
 Pbindef(\con, \fade, in_count * 0.01);
        status = "fading in concession";
    }
    {(count > 10) && (count <=20)} {
        var add_send;
        in_count = count - 10;

        status = "concession status2";
    }
    {(count > 20) && (count <=30)} {
        var add_send;
        in_count = count - 20;
        status = "concession status3";
    }


    {true} { "end of concession reached".postln};

    5.do({|i|
        Pbind(\instrument, \bell2,
            \midinote, [~melos[\melo][\con][0], ~melos[\melo][\con][0] + 12],
            \amp, ~fbVol * local_feedback, \pan, Pwhite(-1.0, 1.0, 5),
            \atk, 0.05, \rls, 0.14,
            \dur, 0.25
    ).play});
     ~addVolume.value(\con, ~volPlus, ~volMax, ~volThres);

    postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);

};
