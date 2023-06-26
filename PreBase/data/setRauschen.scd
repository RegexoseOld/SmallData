~setRauschen = {// represents the rauschen
    |counter|
    var c, dura, notes, status, count, s_name, in_count, sustain;
    //"\nset Obj04\n".postln;
    s_name = "Grundrauschen";
    sustain = 6;
    postf("\nsetting %\t with count %\n", s_name, counter);
    count = floor(counter * ~factor).asInteger;
    status = "zero status";
    dura = Env.new([1,0], [count], [-2]).asPseg;
    c = case
    {(count > 0) && (count <=20)}{
        var key, new;
        in_count = count;
        status = "impulses";

        in_count.do{
            |c|
            key = ('perc1' ++ c).asSymbol;
            new = Pbindef(key, *~reset[\perc1].asPairs);
            new = Pbindef(key,
                \carAmp, Pwhite(0.1, 0.7, in_count * sustain),
                \minfrq, Pwrand([80, 300, 800], [0.1, 0.4, 0.5].normalizeSum, in_count * sustain),
                \dur, Pwhite(0.3, 1.7, in_count* sustain),
                \decayScale, Pseq((0.5, 1.0 .. 2.5), in_count* sustain), \accent, Pwhite(-0.4, 0.8, in_count* sustain),
                \amp, 0.58/ in_count, \fade, Pgeom(0.99, 0.9, in_count* sustain),
                \send, Pwrand([-10, -25, -30], [0.1, 0.25, 0.65].normalizeSum, in_count*sustain), \pan, Pwhite(-0.7, 0.6, in_count* sustain));
            new.play;
        }



    }
    {true} { "end of setRauschen reached".postln;};
    postf("\n new status \t %\n", status);

}

