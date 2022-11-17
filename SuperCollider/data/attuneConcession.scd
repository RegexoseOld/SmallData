~setConcession = {
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

    3.do{
        |n|
        var name1 = ("bw" + n.asString).asSymbol,
        name2 = ("bwawa" + n.asString).asSymbol,
        numNotes = 5;
        Pbindef(name1,
            \instrument, \bwack,
            \dur, 0.25,
            \midinote, ~melos[\melo][\con][0],
            \detune, Pwhite(-6, 6, numNotes),
            \amp, ~fbVol * local_feedback, \pan, Pwhite(-1.0, 1.0, numNotes),
            \thr, 0.25, \cgain, 0,
            \noiseLev, 0.3, \bpfFactor, 2200,
            \dura, Pkey(\dur)*4/5, \part, Pkey(\dura)/10,
            \rls, Pkey(\dura)/2
        ).play;

        Pbindef(name2, \instrument, \bwawack,
            \dur, Pseq([1.5, 0.25, 0.25, 0.5], inf),
            \midinote, ~melos[\melo][\con][0] +12,
            \detune, Pwhite(-6, 6, numNotes),
            \freqMod, 12,
            \bpfFactor, 1500, \noiseLev, 0.4,
            \pan, Pwhite(-0.5, 0.5, numNotes),
            \dura, Pkey(\dur)/2, \part, Pkey(\dura)/10,
            \rls, Pkey(\dura)/2,
            \amp, ~fbVol * local_feedback,
             \thr, 0.25, \cgain, 1,
        ).play
    };


/*
        Ppar(
          [  Pbind(\instrument, \feedback,
            \midinote, ~melos[\melo][\con][0],
            \amp, ~fbVol * local_feedback, \pan, Pwhite(-1.0, 1.0, 5),
            \dur, 0.5
        ),
            Pbind(\instrument, \percImp,
                \accent, Pwhite(-0.2, 0.4, 10),
                \freqOff, Pwhite(-100, 199, 10),
                \decayScale, Pseq([0.2, 0.2, 0.4, 0.6, 0.8],2),
                \dur, 0.125, \fade, 0.0, \amp, 0
            )]
        ).play;*/
     ~addVolume.value(\con, ~volPlus, ~volMax, ~volThres);

    postf("\nsetting %\t with count %\n at status \t %\n", s_name, count, status);

};
