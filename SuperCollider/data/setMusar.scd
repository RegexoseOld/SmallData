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
	{(count > 0) && (count <= 7)} {
		in_count = count - 0;
        ~musarMel[in_count].postln;
        Pbindef(\musar, \midinote, Pseq([~musarMel[in_count], Rest()],inf), \dur, Pseq([1, Rest(pause)], inf));
		status = "single note";
	}
	{(count > 7) && (count <= 14)} {
	in_count = count - 7;
        Pbindef(\musar, \midinote, Pseq(~musarMel[0..in_count] ++ Rest(), inf),
            \dur, Pseq(~musarDur[0..in_count] ++ Rest(pause), inf));
		status = "building first part of Musar Melody";
	}
	{(count > 14) && (count <= 20)} {
        in_count = count -14;
        melo = ~melos[\melo][\arp01];
        duras = ~melos[\duras][\arp01];
        Pbindef(\musar, \midinote, Pseq(melo ++ Rest(pause), inf), \dur, Pseq(duras, inf));
		status = "arpeggio 1";
	}
	{(count > 20) && (count <= 30)} {
       Pbindef(\musar, \midinote, Pseq([49, 52, 56, Rest(pause)], inf), \dur, 1);
		status = "group01";
	}
	{true} {"end of musar reached".postln};
    postf("\nsetting Musar \t with count %\n at status \t %\n", count, status)

}
