~makeNodes = {
	s.bind(
		~fxGroup = Group.new;
		//später: Fx Synth machen und hier instantiieren zB ...
		//~reverb = Synth('reverb', [\in, ~fx1Bus, \lofr, 100, \hifr, 220 ], ~fxGroup);
		~synthLoad.value();

)};

~uttDict = Dictionary.new;
	['dissent', 'praise', 'insinuation', 'concession', 'lecture'].do({
		|cat|
		~uttDict.add(cat-> 0)
	});

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
    {s_name == 'praise'} {~allocate.value(\pr, count)} // reverb
    {s_name == 'dissent'} {~allocate.value(\dis, count)}
    {s_name == 'insinuation'} {~allocate.value(\ins, count)}
    {s_name == 'lecture'} {~allocate.value(\lec, count)}
    {s_name == 'concession'} {~allocate.value(\con, count)}
		{true}{"end of allocation".postln};

	};

~setGlobal = {

    var c;
    postf("\ntotalUtts % \n", ~totalUtts);
    c = case

    {~totalUtts == 112}{
        Pbindef(\perc1, \dur, Pseq([Pseq([1/16, 1/4], 32), Pseq([1/2, 1/4], 32)]),
            \decayScale, Pwhite(1, 4, inf));
         Pbindef(\drum, \dur, Pseq([Pseq([4, 4, 4, 8], 8), Pseq([2, 2, 2, 4], 2) ], inf), \bpf1, Prand([80, 100, 300], inf), \send, Pwhite(-19, -9, inf), \amp, 0.7).play(~t)
    }
    {~totalUtts == 105}{
            Pbindef(\perc1, \dur, Pwhite(1/16, 1/4, inf), \fade, Pseq((0.05,0.1 .. 0.75).mirror, inf), \send, Prand([-18, -12, -9], inf), \pan, Pwhite(-0.5, 0.5, inf), \minFreq, Pwhite(80, 300, inf), \accent, Prand([1, 2, 4], inf)).play

        }
    {~totalUtts == 95}{
        Pbindef(\perc1).stop
    }
    {~totalUtts == 90}{Pbindef(\perc1, \dur, 1/16, \fade, Pseq((0.05,0.1 .. 0.75).mirror, inf), \send, Prand([-18, -12, -9],inf), \pan, Pwhite(-0.5, 0.5, inf), \minFreq, Pwhite(80, 300, inf), \accent, Prand([1, 2, 4], inf)).play}
    {~totalUtts == 85}{Pbindef(\drums).stop}

    {~totalUtts == 65}{
       Pbindef(\drum, \dur, Pseq([4, 4, 4, 8], inf), \bpf1, Prand([80, 100, 300], inf), \amp, 0.7).play(~t)
    }

    {~totalUtts == 20}{
        //start a drum pattern
        Pbindef(\drum, \dur, Pseq([4, 4, 4, 8], inf), \bpf1, Prand([80, 100, 300], 24),  \amp, 0.3).play(~t)
    }

    {(~totalUtts == 1)}{
        "first utt".postln;
        ~patternsPlaying = true;
        ~fadingSynths.do{|name| ~fadePatterns[name][\vol] = ~volMin};
        ~fadingSynths.do{|name| Pbindef(name, \amp, ~volMin).play(~t, quant:1)}
    }
    {true} {"end of global settings".postln};
    ~allocateSynth.value(~cat, ~uttDict[~cat]);
    ~t.schedAbs(~t.nextTimeOnGrid, {
        if(~fadeVols >= 0.15, {
            ~continuousFadeOut.value(~fadingSynths, ~volMin, ~volStep, ~volThres); 1})
    });
};

~mock = {
    var cat = ['dissent', 'praise', 'insinuation', 'concession', 'lecture'].choose;
    ~cat = cat;
    ~updateUtts.(cat);
	~setGlobal.value();
};
