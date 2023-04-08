~makeDictionaries = {
	~categorySymbols = (
		dissent: \dis,
		praise: \pr,
		insinuation: \ins,
		lecture: \lec,
		concession: \con
	);
	// Dictionary for channel allocation
	~cat2Channel = (
		\pr: ~ch1,
		\dis: ~ch2,
		\con: ~ch3,
		\lec: ~ch4,
		\ins: ~ch5,
	);
};

~makeWaveTable = {
	|size|
	var sig, wt, buf;
	sig = Signal.sineFill(size.asInteger, Array.fill(6, {rrand(0.01, 1)}), [0,pi,0,pi,0,0].scramble);
	wt = sig.asWavetable;
	wt.size.postln;
	r{
		buf = Buffer.alloc(s, size*2);
		s.sync;
		buf.sendCollection(wt);
		//buf.plot;
		s.sync;
		~buffers.add(\wt ->buf);
	}.play(AppClock);

};


~makeNodes = {
	//~channels.do{|c| if (c.active, {postf("free channel %\n", c.asString); c.free;})};
	s.bind(
		//
		// Mixer Channels, you have to install dewdrop_lib and ddwMixerChannel with Quarks.gui
		~master = MixerChannel(\master, s, 2, 2);
		~ch1 = MixerChannel(\ch1, s, 2, 2, outbus: ~master);
		~ch2 = MixerChannel(\ch2, s, 2, 2, outbus: ~master);
		~ch3 = MixerChannel(\ch3, s, 2, 2, outbus: ~master);
		~ch4 = MixerChannel(\ch4, s, 2, 2, outbus: ~master);
		~ch5 = MixerChannel(\ch5, s, 2, 2, outbus: ~master);
		~utt = MixerChannel(\ch6, s, 2, 2, outbus: ~master);
		~ringmod = MixerChannel(\ring, s, 2, 2, outbus: ~master);
		~chorus = MixerChannel(\chrs, s, 2, 2, outbus: ~master);
		~reverb = MixerChannel(\vrb1, s, 2, 2, outbus: ~master);

)};

~runFx = {
~fx = (
	\rev: ~reverb.playfx(FxPatch(#[ \busfx, \vrb1 ], ~patches[\reverb2])),
	\ring : ~ringmod.playfx(FxPatch(#[\busfx, \ring1], ~patches[\ring])),
	\chor : ~chorus.playfx(FxPatch(#[\busfx, \chorus], ~patches[\chorus])),
	\mst_lim : ~master.playfx(FxPatch(#[\busfx, \limiter], ~patches[\limiter])),
    \ch1_cmp : ~ch1.playfx(FxPatch(#[\busfx, \companderd], ~patches[\companderd_01])),
	\ch2_cmp : ~ch2.playfx(FxPatch(#[\busfx, \companderd], ~patches[\companderd_01])),
	\ch3_cmp : ~ch3.playfx(FxPatch(#[\busfx, \companderd], ~patches[\companderd_beat])),
	\ch4_cmp :~ch4.playfx(FxPatch(#[\busfx, \companderd], ~patches[\companderd_01])),
	\ch5_cmp : ~ch5.playfx(FxPatch(#[\busfx, \companderd], ~patches[\companderd_01])),
	//\ch6_cmp : ~utt.playfx(FxPatch(#[\busfx, \companderd], ~patches[\companderd_01]))
)
};

~bypass = {
	|key, on|
	if (on, {~fx[key].synth.run(false)}, {~fx[key].synth.run(true);
})
};

~activateFaders = {
	var i = 0;
	~sends.keys.asList.sort.do({
		|snd|
		if ("vrb".matchRegexp(snd.asString), {
			("found  " ++ snd).postln;
		    ~activateReverb.(snd, i, 89 );
			i = i+1;
		})
	});

	~faderControl.do{|chan, it| ~activateVolume.(chan, it)}
};

~uttDict = Dictionary.new;
	['dissent', 'praise', 'insinuation', 'concession', 'lecture'].do({
		|cat|
		~uttDict.add(cat-> 0)
	});

// make buffers
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
    if(~uttDict[~cat] >= 70, {~uttDict[~cat] = 1}, {~uttDict[~cat] = ~uttDict[~cat] + 1} );
	~uttDict.postln;
    //postf("\nupdated % to % ", cat, ~uttDict[cat]);
};

~updateSample = {
	// ~uttSample wird mit einem neuen File geladen und aktualisiert. Relevant für makeSlot in organist.scd
	"updated Sample".postln;
};

~checkFadeVols = {
	var allVolumes=List.new;
	   ~fadingSynths.do{
        |n|
        //v.vol.postln;
        allVolumes.add(~melos.amps[n]);
    };
	//"FadeVolumes Sum    %".format(allVolumes.sum).postln;
	~fadeVols = allVolumes.sum;
	allVolumes.sum;
};

~addVolume = {
    |cat, add, max, thres|
    var c, editVol, allVolumes=List.new;
    //editVol = ~fadePatterns[cat][\vol];
    editVol = ~melos[\amps][cat];
    //postf("\n updating volume of %  from %  add %   max %   thres % \n ", cat, editVol, add, max, thres );
    c = case
    {editVol <= thres}{~melos[\amps][cat] = editVol + (add * ~volFac) }// double enhance when pattern is very quiet
    {(editVol<= max) && (editVol>= thres)}{ ~melos[\amps][cat]  = editVol + add}
    {editVol >= max}{~melos[\amps][cat]  = max}
    {true}{"end of addVolume".postln};
    //Pbindef(cat, \amp, ~fadePatterns[cat][\vol]);
	~fadingSynths.do{|n| "%  newVolume %".format(n, ~melos.amps[n]).postln;};
    //postf("new vol of %  is % \n", cat, ~melos[\amps][cat] );
	~fadeVols = ~checkFadeVols.();
    postf("\nthe vol of all patterns is   %\n", ~checkFadeVols.());
};

~continuousFadeOut = {
	|listOfPatterns|
    //TODO wann schaltet sich das ein und evtl auch wieder ab?
	"continous fadeOut".postln;
        listOfPatterns.do({
            |cat|
            var vol, c;
            //vol = ~fadePatterns[cat][\vol];
            vol = ~melos[\amps][cat] ;
            //postf("\nthe vol %  of the pattern   %\n", vol, cat);
            c = case
            {(vol > ~volMin) && (vol >= ~volThres)} {~melos[\amps][cat] = vol - (~volStep*2)} // loud volumes decrease fast
            {(vol <= ~volThres) && (vol > ~volMin)} {~melos[\amps][cat] = vol - ~volStep} // middle volumes decrease slower
            {vol <= ~volMin} {~melos[\amps][cat] = ~volMin}
            {true}{"end of fade cases"};
		//postf("\nthe vol %  of the pattern   %\n", ~melos[\amps][cat] , cat);
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

    {~totalUtts == 20}{
        //start a drum pattern
        Pbindef(\drm, \dur, Pseq([4, 4, 4, 8], inf), \bpf1, Prand([80, 100, 300], 24),  \amp, 0.3).play(~t);

    }
	{~totalUtts == 10}{
        //send
			"10 utts".postln;
    }
    {(~totalUtts > 1) && (~totalUtts < 10) }{
		Pbindef(\metronom).play(~t, quant:1);
	}
    {(~totalUtts == 1)}{
        //"first utt".postln;
		~runFx.();
		~activateFaders.();
        ~fadingSynths.do{|name| ~melos[\amps][name] = ~volMin};
		~fadingSynths.do{|name| Pbindef(name).play(~t, quant:1)};
		~patternsPlaying = true;
		[\answer].do{|n| Pbindef(n).play(~t, quant:1)}
    }
    {true} {"end of global settings".postln};
    ~allocateSynth.(~cat, ~uttDict[~cat]);
    ~t.schedAbs(~t.nextTimeOnGrid, {
        if(~checkFadeVols.() >= 0.15, {
            ~continuousFadeOut.value(~fadingSynths); 1},
		{"not fading: fadeVols = %".format(~fadeVols).postln})
    });
};

~mock = {
    var cat = ['dissent', 'praise', 'insinuation', 'concession', 'lecture'].choose;
	//~cat = 'praise';
    ~cat = cat;
    ~updateUtts.(~cat);
	//~allocateSynth.(cat, ~uttDict[cat]);
	~setGlobal.value();
};
