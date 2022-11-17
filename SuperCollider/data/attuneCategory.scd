~attCat = {
    |catName, counter|
    var c, dura, status, count, in_count, local_feedback, numNotes;
    count = floor(counter * ~factor).asInteger;
    status = "zero status";
    local_feedback = 0.2;
    dura = Env.new([1,0], [count], [-2]).asPseg;

    c = case
    {(count > 0) && (count <= 10)} {
        in_count = count - 0;
        Pbindef(catName, \midinote, Pseq(~melos[\melo][catName], inf),
            \dur, 4,
            \fade, 0.05 * in_count,
        );
        numNotes = 3;
        status = "fading in, dur = 4 beats";
    }
    {(count > 10) && (count <=20)} {
        var add_send;
        in_count = count - 10;
        Pbindef(catName, \midinote, Pseq(~melos[\melo][catName], inf) +12,
            \dur, 4,
            \fade, 0.5
        );
        numNotes = 2;
        status = "octave up";
    }
    {(count > 20) && (count <=30)} {
        in_count = count - 20;
           Pbindef(catName, \midinote, Pseq(~melos[\melo][catName], inf) -12,
            \dur, 4,
            \fade, 0.5,
            \sig2Fade, 0.07,
            \bpf1, 80,
            \bpf2, 4300,
            \bpf3, 3.2
        );
        numNotes = 4;
        status = "octave down";
    }
    {(count > 30) && (count <=40)} {
        in_count = count - 30;
           Pbindef(catName, \midinote, Pseq(~melos[\melo][catName], inf),
            \dur, 2,
            \fade, 0.6,

            \bpf1, 300,
            \bpf2, 4300,
            \bpf3, 1.4
        );
        numNotes = 2;
        status = "duration 2 beats";
    }

    {(count > 40) && (count <=50)} {
        var fb_note = ~melos[\melo][catName][0];
        in_count = count - 40;
           Pbindef(catName, \midinote, Pseq([fb_note, fb_note +12], inf),
            \dur, 2,
            \fade, 0.6
        );
        numNotes = 5;
        status = "feedback note";
    }
    {(count > 50) && (count <=60)} {
        var fb_note = ~melos[\melo][catName][0];
        in_count = count - 50;
           Pbindef(catName, \midinote, Pseq([fb_note-12, fb_note -12, fb_note +12, fb_note+12], inf),
            \dur, 1,
            \fade, 0.6
        );
        numNotes = 6;
        status = "4 notes with duration of 1 beat";
    }


    {true} { "end of attCat reached".postln};

    3.do{
        |n|
        Pbind(
            \instrument, \quitt,
           \dur, 0.25,
            \midinote, ~melos[\melo][catName][0],
            \detune, Pwhite(-6, 6, numNotes),
            \amp, ~fbVol * 0.6, \pan, Pwhite(-1.0, 1.0, numNotes),
            \gendAmp, Pwrand([0.05, 0.2], [0.8, 0.2], numNotes), \gendScale, 0.2,
            \rls, Pkey(\dur)/2, \crv, -2
        ).play;
    };


    ~addVolume.value(catName, ~volPlus, ~volMax, ~volThres);

    postf("\nsetting %\t with count %\n at status \t %\n", catName, count, status);

};
