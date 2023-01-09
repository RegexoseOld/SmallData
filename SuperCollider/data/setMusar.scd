  /*
wird erstmal von ~totalUtts getriggert
    */
~setMusar = {
    |cat, counter|
    var c, status, melo, duras, count, in_count, pause,
    local_feedback; // faktor der lautstärke Local;
    pause = ~melos[\pauses][cat];
    //postf("pause  % \n", pause);
    count = floor(counter * ~factor).asInteger;
    status = "zero status";

    c = case
    {(count > 0) && (count <= 40)} {
        in_count = count - 0;
        Pbindef(\musar, \midinote, Pseq(~musarMel,inf), \dur, Pseq(~musarDur, inf));
        Pbindef(\musar2, \midinote, Pseq(~musarMel,inf), \dur, Pseq(~musarDur, inf));
        status = "musar melo with pauses inbetween lines";
    }
    /*
    {(count > 10) && (count <= 15)} {
        in_count = count - 10;
        Pbindef(\musar, \midinote, Pseq([~musarMel[in_count], Rest()],inf), \dur, Pseq([1, Rest(pause)], inf));
        status = "varying single note";
    }
    {(count > 15) && (count <= 25)} {
        in_count = count - 15;
        Pbindef(\musar, \midinote, Pseq(~musarMel[0..in_count] ++ Rest(), inf),
            \dur, Pseq(~musarDur[0..in_count] ++ Rest(pause), inf), \atk, 0.4, \rls, 0.6);
        status = "building first part of Musar Melody";
    }
    {(count > 25) && (count <= 35)} {
        in_count = count - 25;
        Pbindef(\musar, \midinote, Pseq(~musarMel,inf), \dur, Pseq(~musarDur, inf));
        status = "melo without pauses";
    }
    {(count > 35) && (count <= 45)} {
        in_count = count -35;
        Pbindef(\musar, \midinote, Pseq([~musarMel ++ Rest()],inf) +12, \dur, Pseq([~musarDur ++ Rest(pause)], inf));
        status = "melo with pauses";

    }
    {(count > 45) && (count <= 55)} {
        in_count = count -45;

        melo = ~melos[\melo][\arp01];
        duras = ~melos[\duras][\arp01];
        Pbindef(\musar, \midinote, Pseq(melo ++ Rest(pause), inf), \dur, Pseq(duras, inf));
        status = "arpeggio 1";
    }
    {(count > 55) && (count <= 60)} {
        in_count = count -55;
        Pbindef(\musar, \midinote, Pseq([49, 52, 56, Rest(pause)], inf), \dur, 1);
        status = "group01";
    }*/
    {true} {"end of musar reached".postln};
    postf("\nsetting Musar \t with count %\n at status \t %\n", count, status)

}
