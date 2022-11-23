~makeNodes = {
	s.bind(
		~fxGroup = Group.new;
		//später: Fx Synth machen und hier instantiieren zB ...
		~reverb = Synth('reverb', [\in, ~fx1Bus, \lofr, 100, \hifr, 220 ], ~fxGroup);
		~synthLoad.value();

)};

~uttDict = Dictionary.new;
	['dissent', 'praise', 'insinuation', 'concession', 'lecture'].do({
		|cat|
		~uttDict.add(cat-> 0)
	});

~buffers = Dictionary.new;
	//~path = "/Users/borisjoens/Desktop/Soundwesen/percSamples01/";
	PathName(~samplesPath).entries.do({
		arg subfolder;
		~buffers.add(
			subfolder.folderName.asSymbol ->
			Array.fill(
				subfolder.entries.size,
				{
					arg i;
					Buffer.read(s, subfolder.entries[i].fullPath);
				}
			)
		)
	});

~updateUtts = {
    |cat|
    //postf("\n \n+++ ++++ ++++ \n\nnew UTT %\t \n", cat);
    ~totalUtts = ~totalUtts + 1;
    ~uttDict.postln;
    if(~uttDict[~cat] >= 70, {~uttDict[~cat] = 1}, {~uttDict[~cat] = ~uttDict[~cat] + 1} );
    //postf("\nupdated % to % ", cat, ~uttDict[cat]);
};



~addVolume = {
    |cat, add, max, thres|
    var c, editVol, allVolumes=List.new;
    editVol = ~fadePatterns[cat][\vol];
    //postf("\n updating volume of %  from %  add %   max %   thres % \n ", cat, editVol, add, max, thres );
    c = case
    {editVol <= thres}{ ~fadePatterns[cat][\vol] = editVol + (add * ~volFac) }// double enhance when pattern is very quiet
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
    {~totalUtts == 80}{~godChord.pause; ~zC[\gC] = false; (~dataPath ++ "allNotesOff.scd").load; ~allNotesOff.play;
        ~godMelo.resume(~t); ~zC[\gM] = true

    }
    {~totalUtts == 70}{~godChord.resume; ~zC[\gC] = true}
    {~totalUtts == 60}{~godChord.pause; ~zC[\gC] = false; (~dataPath ++ "allNotesOff.scd").load; ~allNotesOff.play;
        Pbindef(\drum, \dur, Pseq([4, 4, 4, 24], inf), \bpf1, Prand([80, 100, 300], inf), \send, -9, \amp, 0.5).play(~t)
    }
    {~totalUtts == 55}{~zC[\zChord] = ~melos[\melo][\z_ruzhim01][4..7];
        ~godChord.resume; ~zC[\gC] = true}
    {~totalUtts == 45}{~godMelo.resume; ~zC[\gM] = true;
        (~dataPath ++ "allNotesOff.scd").load; ~allNotesOff.play

    }
    {~totalUtts == 44}{~godChord.pause;(~dataPath ++ "allNotesOff.scd").load; ~allNotesOff.play; ~zC[\gC]  = false;}

    {~totalUtts == 35}{
        ~zC[\zChord] = ~melos[\melo][\z_ruzhim01][4..7];
        ~godChord.resume; (~dataPath ++ "allNotesOff.scd").load;  ~zC[\gC] = true;


    }
    {~totalUtts == 30}{
        //pause godMel and resume godChord
        ~godMelo.pause; (~dataPath ++ "allNotesOff.scd").load; ~allNotesOff.play; ~zC[\gM] = false;
        Pbindef(\drum, \dur, Pseq([4, 4, 4, 16], inf), \bpf1, Prand([80, 100, 300], 12), \send, -9, \amp, 0.7).play(~t)
    }
    {~totalUtts == 15}{
        //pause godChord and play godMel
        ~godChord.pause;(~dataPath ++ "allNotesOff.scd").load; ~allNotesOff.play; ~zC[\gC]  = false;
        ~godMelo.play(~t); ~zC[\gM] = true;

    }
    {(~totalUtts == 10) && (~patternsPlaying == false)} {


    }
    {(~totalUtts == 5)}{
        //play godChord
        ~godChord.play(~t); ~zC[\gC] = true
    }
    {(~totalUtts == 1)}{
        ~patternsPlaying = true;
        ~fadingSynths.do{|name| ~fadePatterns[name][\vol] = ~volMin};
        ~fadingSynths.do{|name| Pbindef(name, \amp, ~volMin).play(~t, quant:1)};}
    {true} {"end of global settings".postln};
    ~allocateSynth.value(~cat, ~uttDict[~cat]);
    ~t.schedAbs(~t.nextTimeOnGrid, {
        if(~fadeVols >= 0.15, {
            ~continuousFadeOut.value(~fadingSynths, ~volMin, ~volStep, ~volThres); 1})
    });
};

~godMelo = Task({
    var pause, note, dur, vel, idx = 0;
    "playing godMelo".postln;
     pause = ~zC[\mPause];
     {
        note = ~zC[\zMelo][idx];
        //note = (13 .. 127)[idx];
        note.postln;
        dur = ~zC[\zDur][idx];
        //dur = 1;
        vel = ~melos[\zit][\vel][note.asSymbol];
        ~midiOut.noteOn(0, note, vel);
    dur.wait;
    ~midiOut.noteOn(0, note, 0);
    idx = (idx + 1) % (~zC[\zMelo]).size;
    //idx = (idx + 1) % (54 .. 90).size;
    }.loop
}
);

~godChord = Task({
    var vel, dur, pause, gC;
    "playing godChord".postln;
      {
        pause = ~zC[\cPause];
        dur = ~zC[\cDur];
        /*gC = (((13..21) ++ (54..73)).scramble)[0..4];
        gC.postln;*/
     ~zC[\zChord].do{
            |nn|
            vel = ~melos[\zit][\vel][nn.asSymbol] + 3;
            ~midiOut.noteOn(0, nn, vel)};

    dur.wait;

            ~zC[\zChord].do{|nn|
                ~midiOut.noteOn(0, nn, 0)};

        //godChord.do{|nn| ~midiOut.noteOn(0, nn, 0)};
       pause.wait;
    }.loop
    }
);

~allNotesOff =
    Routine({
        (1 .. 73).do{|nn| nn.postln; ~midiOut.noteOn(0, nn, 0);
0.05.wait
        };
    "allNotesOff".postln;
    });

~allNotesOff2 ={
    (1 .. 73).do{|nn| nn.postln; ~midiOut.noteOn(0, nn, 0)};
    "allnotesOff2".postln
    };




~mock = {
    var cat = ['dissent', 'praise', 'insinuation', 'concession', 'lecture'].choose;
    ~cat = cat;
    ~updateUtts.(cat);
	//~allocateSynth.value(cat, ~uttDict[cat]);
	~setGlobal.value();
};
