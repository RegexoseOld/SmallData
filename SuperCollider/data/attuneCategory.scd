~attCat = {
    |catName, counter|
    var c, dura, status, count, in_count, local_feedback, numNotes;
    count = floor(counter * ~factor).asInteger;
    status = "zero status";
    local_feedback = 1;
    numNotes = 1;
    dura = Env.new([1,0], [count], [-2]).asPseg;

    c = case
    {(count >= 10) && (count <= 15)} {
        in_count = count - 10;
        Pbindef(catName, \midinote, Pseq(~melos[\melo][catName], inf),
            \dur, 2,
            \fade, 0.01 * in_count,
            \vibF, 2,
            \index, Pwhite(1, 1.2, inf)
        );
        numNotes = 2;
        status = "count 10, fading in, vib=2";
    }
    {(count > 15) && (count <=20)} {
        var add_send;
        in_count = count - 15;
        Pbindef(catName,
            \dur, 1.5,
            \fade, 0.1,
            \index, 2
        );
        numNotes = 3;
        status = "count 20, index = 2";
    }
    {(count > 20) && (count <=30)} {
        in_count = count - 20;
           Pbindef(catName, \midinote, Pseq(~melos[\melo][catName], inf) -12,
            \dur, 2,
            \fade, 0.5,
            \bpf1, 80,
            \bpf2, Prand([1,2,4,6], inf),
            \vibF, 2
        );
        numNotes = 4;
        status = "octave down and vibF 2";
    }
    {(count > 30) && (count <=40)} {
        in_count = count - 30;
           Pbindef(catName, \midinote, Pseq(~melos[\melo][catName], inf),
            \dur, 2,
            \fade, 0.2,
            \cRatio, in_count/2.ceil,
            \vibF, 1,
        );
        numNotes = 5;
        status = "count 30, cRatio";
    }

    {(count > 40) && (count <=50)} {
        var fb_note = ~melos[\melo][catName][0];
        in_count = count - 50;
           Pbindef(catName, \midinote, Pseq([fb_note, fb_note +12], inf),
            \dur, 2,
            \fade, 0.2,
            \vibF, Pseq([4, 2],inf)
        );
        numNotes = 6;
        status = "count 40, feedback note oktaviert";
    }
    {(count > 50) && (count <=60)} {
        var fb_note = ~melos[\melo][catName][0];
        in_count = count - 50;
           Pbindef(catName, \midinote, Pseq([fb_note-12, fb_note -12, fb_note +12, fb_note+12], inf),
            \dur, 1,
            \fade, 0.2,
            \mRatio, Pseq([1, 2, 4, 3], inf)
        );
        numNotes = 7;
        status = "count 60, 4 notes with duration of 1 beat";
    }


    {true} { "end of attCat reached".postln};




    3.do{
        |n|
        Pbind(
            \instrument, \quitt,
            \dur, Prand([0.25, 0.31], inf),
            \midinote, ~melos[\melo][catName][0],
            \detune, Pwhite(-6, 6, numNotes),
            \amp, ~fbVol * local_feedback, \pan, Pwhite(-1.0, 1.0, numNotes),
            \ampDist, 2, \durDist, 0.2,
            \gendAmp, Pwrand([0.05, 0.14, 0.33], [0.6, 0.3, 0.1], inf),
            \ffreq, Pwhite( 300, 800, inf),
            \minFreq, 600, \maxFreq, 1400,
            \atk, 0.05, \rls, Pkey(\dur), \crv, -4
        ).play;
    };


    ~addVolume.value(catName, ~volPlus, ~volMax, ~volThres);

    postf("\nsetting %\t with count %\n at status \t %\n", catName, count, status);

};
