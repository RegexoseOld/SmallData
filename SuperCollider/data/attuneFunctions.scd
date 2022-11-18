~makeNodes = {
	s.bind(
		~fxGroup = Group.new;
		//später: Fx Synth machen und hier instantiieren zB ...
		~reverb = Synth('reverb', [\in, ~fx1Bus], ~fxGroup);
		~synthLoad.value();

)};

~uttDict = Dictionary.new;
	['dissent', 'praise', 'insinuation', 'concession', 'lecture'].do({
		|cat|
		~uttDict.add(cat-> 0)
	});

~updateUtts = {
    |cat|
    //postf("\n \n+++ ++++ ++++ \n\nnew UTT %\t \n", cat);
    ~totalUtts = ~totalUtts + 1;
    ~uttDict[cat].postln;
    ~uttDict[cat] = ~uttDict[cat] + 1;
    //postf("\nupdated % to % ", cat, ~uttDict[cat]);
};

~addVolume = {
    |cat, add, max, thres|
    var c, editVol, allVolumes=List.new;
    editVol = ~fadePatterns[cat][\vol];
    //postf("\n updating volume of %  from %  add %   max %   thres % \n ", cat, editVol, add, max, thres );
    c = case
    {editVol <= thres}{ ~fadePatterns[cat][\vol] = editVol + (add *2) }// double enhance when pattern is very quiet
    {(editVol<= max) && (editVol>= thres)}{ ~fadePatterns[cat][\vol] = editVol + add}
    {editVol >= max}{ ~fadePatterns[cat][\vol] = max}
    {true}{"end of addVolume".postln};
    Pbindef(cat, \amp, ~fadePatterns[cat][\vol]);
    //postf("new vol of %  is % \n", cat, ~fadePatterns[cat][\vol]);
    ~fadePatterns.values.collect{
        |v|
        //v['vol'].postln;
        allVolumes.add(v['vol']);
    };

    ~fadeVols = allVolumes.sum;
    postf("\nthe vol of all patterns is   %\n", ~fadeVols);
};

~continuousFadeOut = {
	|listOfPatterns, min, step, thres|
    //TODO wann schaltet sich das ein und evtl auch wieder ab?
        listOfPatterns.do({
            |cat|
            var vol, c;
            vol = ~fadePatterns[cat][\vol];
            //postf("\nthe vol %  of the pattern   %\n", vol, cat);
            c = case
            {(vol > min) && (vol >= thres)} {~fadePatterns[cat][\vol] = vol - (step*4)} // loud volumes decrease fast
            {(vol <= thres) && (vol >= min)} {~fadePatterns[cat][\vol] = vol - step ;} // middle volumes decrease slower
            {vol <= min} {~fadePatterns[cat][\vol] = min}
            {true}{"end of fade cases"};
            Pbindef(cat, \amp, ~fadePatterns[cat][\vol]);
        })
};

~allocateSynth = {
		|s_name, count|
		var c;
    //postf("\nallocating % with count %\n", s_name, count);
		c = case
    {s_name == 'praise'} {~attCat.value(\pr, count)} // reverb
    {s_name == 'dissent'} {~attCat.value(\dis, count)}
    {s_name == 'insinuation'} {~attCat.value(\ins, count)}
    {s_name == 'lecture'} {~attCat.value(\lec, count)}
    {s_name == 'concession'} {~attCat.value(\con, count)}
		{true}{"end of allocation".postln};

	};

~setGlobal = {
    //Todo: Verschiedene zither Aktionen
    var c;
    postf("\ntotalUtts % \n", ~totalUtts);
    c = case
    {~totalUtts == 60}{~godChord.pause; ~zC[\gC] = false}
    {~totalUtts == 50}{~zC[\godChord] = ~melos[\melo][\z_ruzhim01][4..7];
        ~godChord.resume; ~zC[\gC] = true}
    {~totalUtts == 40}{
        ~godMelo.pause; ~zC[\gM] = false}
    {(~totalUtts == 31) && (~gM == false)}{"play godmelo?".postln; ~godMelo.resume(~t); ~zC[\gM] = true}
 {~totalUtts == 30}{ //pause godChord and resume godMel
        ~godChord.pause; ~allNotesOff.(); ~zC[\gC] = false;

    }
    {~totalUtts == 20}{
        //pause godMel and resume godChord
        ~godMelo.pause; ~allNotesOff.(); ~zC[\gM] = false;
        ~godChord.resume(~t); ~zC[\gC] = true}
    {~totalUtts == 15}{
        //pause godChord and play godMel
        ~godChord.pause; ~allNotesOff.(); ~zC[\gC]  = false;
        ~godMelo.play(~t); ~zC[\gM] = true

    }
    {(~totalUtts == 10) && (~patternsPlaying == false)} {
        ~patternsPlaying == true;
        ~fadingSynths.do{|name| ~fadePatterns[name][\vol] = ~volMin};
        ~fadingSynths.do{|name| Pbindef(name, \amp, ~volMin).play(~t, quant:[0,-1 ])};

    }
     {(~totalUtts == 5)}{
        //play godChord
        ~zC[\gChord] = ~melos[\melo][\z_ruzhim01][0..3];
        ~godChord.play(~t); ~zC[\gC] = true}
    {(~totalUtts > 0) && (~totalUtts <= 10)} {

       if(~setMus, {~setMusar.(~cat, ~totalUtts)})
       // ~setRauschen.(~totalUtts);
    }
    {true} {"end of global settings".postln};
    ~allocateSynth.value(~cat, ~uttDict[~cat]);
    ~t.schedAbs(~t.nextTimeOnGrid, {
        if(~fadeVols >= 0.2, {
            ~continuousFadeOut.value(~fadingSynths, ~volMin, ~volStep, ~volThres); 1})
    });
};

~godMelo = Task({
    var godChord, pause, note, dur, vel, idx = 0;
    "playing godMelo".postln;
     pause = ~zC[\mPause];
     {
        note = ~melos[\melo][\z_ruzhim01][idx];
        dur = ~melos[\duras][\z_ruzhim01][idx];
        if((68..73).includes(note), {vel = 35}, {vel= 24});
        ~midiOut.noteOn(0, note, vel);
    dur.wait;
    ~midiOut.noteOn(0, note, 0);
    idx = (idx + 1) % (~melos[\melo][\z_ruzhim01]).size;
    }.loop
}
);

~godChord = Task({
    var vel, dur, pause;
    "playing godChord".postln;
      {
        //note = ~melos[\melo][\z_ruzhim01][idx];
        pause = ~zC[\cPause];
        dur = ~zC[\cDur];
      ~zC[\gChord].do{
            |nn|
            var vel = rrand(10, 27);
            ~midiOut.noteOn(0, nn, vel)};

    dur.wait;

            ~zC[\gChord].do{|nn|
                if((67 ..73).includes(nn), {vel = 35}, {vel= 25});
                ~midiOut.noteOn(0, nn, 0)};
        //godChord.do{|nn| ~midiOut.noteOn(0, nn, 0)};
       pause.wait;


    }.loop
    }
);

~allNotesOff = {
    (54 .. 73).do{|nn| ~midiOut.noteOn(0, nn, 0)};
    "allNotesOff".postln;
};

~mock = {
    var cat = ['dissent', 'praise', 'insinuation', 'concession', 'lecture'].choose;
    ~cat = cat;
    ~updateUtts.(cat);
	//~allocateSynth.value(cat, ~uttDict[cat]);
	~setGlobal.value();
};
