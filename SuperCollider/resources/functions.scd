~makeDictionaries = {
	~categorySymbols = (
		\dissent: \dis,
		\praise: \pr,
		\insinuation: \ins,
		\lecture: \lec,
		\concession: \con
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

// initialize utterance counter
~categories.do({
	|cat|
	~uttDict.add(cat-> 0)
});

// initialize dictionary with audio utterances
~categories.do({
	|cat|
	Buffer.read(s, PathName(~samplesPath).parentPath ++ "uttSamples/" ++ cat ++ ".wav",
		action: {arg buffer;
			~uttSamples.add(cat-> [buffer, 0, buffer.numFrames]);
	});
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
    |utt, cat|
    //postf("\n \n+++ ++++ ++++ \n\nnew UTT %\t \n", cat);
	var lastUtts = ~lastUtterances.rotate(1), lastCats = ~lastCategories.rotate(1);
	lastUtts.put(0, utt);
	lastCats.put(0, cat);
	defer {3. do{|i|
		~status[2][i].string = lastCats[i] ++ " : " ++ lastUtts[i]
	}};
	~lastUtterances = lastUtts;
	~lastCategories = lastCats;
    ~totalUtts = ~totalUtts + 1;
    if(~uttDict[cat] >= 15, {~uttDict[cat] = 1}, {~uttDict[cat] = ~uttDict[cat] + 1} );
	defer{var index, count;
	index = ~fadingSynths.detectIndex({|it, i| it == ~categorySymbols[cat.asSymbol]});
	count =  ~uttDict[~cat].asString;
    //postf("\nupdating index % to count % ", index, count);
	~mc_labels[1][index].string = cat ++ "\n" ++ count;
	~mc_labels[1][5].string = "total utts" ++ "\n" ++ ~totalUtts ;
	}
	//~uttDict.postln;
};

~updateSample = {
	|pathString|
	Buffer.read(s, pathString ++ "/00_utterance.wav", action: {arg buffer;
		AppClock.sched(0, {~uttSamples.put(~cat, [buffer, 0, buffer.numFrames-1])});
		AppClock.sched(0, {~slider_buttons[1][~cat][0].readFile(SoundFile.openRead(buffer.path), 0, buffer.numFrames)
			.drawsRMS_(false)
			.yZoom_(2)});
		AppClock.sched(0,
			{~slider_buttons[1][~cat][1].lo_(0);
			~slider_buttons[1][~cat][1].hi_(1);
				~slider_buttons[1][~cat][1]
				.action_({ |slider|
					~uttSamples[~cat][1] = (slider.lo.lincurve(0, 1, 0 , buffer.numFrames, 0)).asInteger;
					~uttSamples[~cat][2] = (slider.hi.lincurve(0, 1, 0 , buffer.numFrames, 0)).asInteger;
				})
		})
	});
};

~addSample = {
	|pathSymbol|
	var path = pathSymbol.asString;
	~utts.add(
		PathName(path).fileName.asSymbol->
		Array.fill(
			PathName(path).entries.size,
			{
				|i|
				 PathName(path).entries[i].postln;
				Buffer.read(s, PathName(path).entries[i].fullPath);
			}
		)
	);
	"updated Sample".postln;
};

~checkFadeVols = {
	var allVolumes=List.new;
	   ~fadingSynths.do{
        |n|
        allVolumes.add(~melos.amps[n]);
    };
	//"FadeVolumes Sum    %".format(allVolumes.sum).postln;
	~fadeVols = allVolumes.sum;
	allVolumes.sum;
};

~addVolume = {
	|cat|
	var c, editVol, allVolumes=List.new;
	editVol =  ~melos[\amps][cat];
	//postf("\n updating volume of %  from %  add %   max %   thres % \n ", cat, editVol, add, max, thres );
	c = case
	{editVol <= ~volThres}{ ~fadePatterns[cat][\vol] = editVol + (~volPlus * ~addFac) }// double enhance when pattern is very quiet
	{(editVol<= ~volMax) && (editVol>= ~volThres)}{ ~melos[\amps][cat] = editVol + ~volPlus}
	{editVol >= ~volMax}{  ~melos[\amps][cat] = ~volMax}
	{true}{"end of addVolume".postln};
	//postf("new vol of %  is % \n", cat, ~fadePatterns[cat][\vol]);
	defer{var index, height, text;
	//"updating mc: index % height  % text  %".format(index, height, text);
	index = ~fadingSynths.detectIndex({|it, i| it == cat});
	height = ~melos[\amps][cat].linlin(0.001, 1.0, 10, 360);
	text =  ~melos[\amps][cat].trunc(0.001).asString;
	~mc_track[1][index].resizeTo(100, height);
	~mc_track[1][index].string = text;
	}
	//postf("\nthe vol of all patterns is   %\n", ~fadeVols);
};

~continuousFadeOut = {
	|listOfPatterns|
	//TODO wann schaltet sich das ein und evtl auch wieder ab?
	listOfPatterns.do({
		|cat|
		var vol, c;
		vol = ~melos[\amps][cat];
		//postf("\nthe vol %  of the pattern   %\n", vol, cat);
		c = case
		{(vol > ~volMin) && (vol >= ~volThres)} {~melos[\amps][cat] = vol - (~volStep * ~subFac)} // loud volumes decrease fast
		{(vol <= ~volThres) && (vol >= ~volMin)} {~melos[\amps][cat]= vol - ~volStep;} // middle volumes decrease slower
		{vol <= ~volMin} {~melos[\amps][cat] = ~volMin}
		{true}{"end of fade cases"};
		Pbindef(cat, \amp, ~fadePatterns[cat][\vol]);
		defer{var index, height, text;
			//"updating mc: index % height  % text  %".format(index, height, text);
			index = ~fadingSynths.detectIndex({|it, i| it == cat});
			height = ~melos[\amps][cat].linlin(0.001, 1.0, 10, 360);
			text = ~melos[\amps][cat].trunc(0.001).asString;
			~mc_track[1][index].resizeTo(100, height);
			~mc_track[1][index].string = text;
		}
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
		Pdefn(\melody).play(~t, quant:1);
		~patternsPlaying = true;
		[\answer].do{|n| Pbindef(n).play(~t, quant:1)}
    }
    {true} {"end of global settings".postln};
    ~allocateSynth.(~cat, ~uttDict[~cat]);
    ~t.schedAbs(~t.nextTimeOnGrid, {
        if(~checkFadeVols.() >= ~thresCont, {
            ~continuousFadeOut.value(~fadingSynths); 1},
		{"not fading: fadeVols = %".format(~fadeVols).postln})
    });
};


~mock = {
    var cat = ~categories.choose;
	/* ~cat = 'insinuation';
	~updateUtts.("das ist gut", cat);
 	~setGlobal.value();*/
	m = NetAddr("127.0.0.1", 57120);
	m.sendMsg("/interpreter_input", ~story[~storyIndex % ~story.size], cat, ~uttDict[cat], ~resourcePath ++ "samples/lec01/");
	~storyIndex = ~storyIndex + 1;
};
