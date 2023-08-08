
~fadingSynths = [\dis, \pr,  \ins, \con, \lec];
~additionalSynths = List.new;
~faderControl = List.new; // Patterns controlled by MIDIFaders or OSC Controllers
// booleans
~patternsPlaying = false;
~categories = ['dissent', 'praise', 'insinuation', 'concession', 'lecture'];
~categorySymbols = (
		\dissent: \dis,
		\praise: \pr,
		\insinuation: \ins,
		\lecture: \lec,
		\concession: \con
	);

~t = TempoClock(80/60, queueSize: 1024).permanent_(true);

// using 5 tempoClocks to avoid full scheduler queue
//~t = ();
// (~categorySymbols.values ++ [\seq, \kik02, \hh01, \bass, \snip01, \sn01]).do({
// 	|k|
// 	~t.add(k -> TempoClock(80/60, queueSize: 1024).permanent_(true));
// });


~lastUtterances = Array.with("one", "two", "three");
~lastCategories = Array.with("praise", "dissent", "insinuation");
~samplesPath = PathName(thisProcess.nowExecutingPath).parentPath ++ "samples/";
~showFolder = ~projectRoot +/+ "shows" +/+ ~showName;
~fadePatterns = Dictionary.new;

~buffers = Dictionary.new;
~uttDict = Dictionary.new;
~uttSamples = Dictionary.new;  // dictionary with current audio utterances
~samplePaths = Dictionary.new; // container for paths of audio-utterance-PopUpMenus. dictionary of Arrays with paths to all audio utterances. The order of the elements in e.g. samplePaths[lecture] is linked to the order of the elements in the corresponding popupMenu ~utteranceSelectors[1][lecture].items


~categories.do({
	|cat|
	var path = PathName(PathName(~samplesPath).parentPath ++ "uttSamples/" ++ cat +/+ "00_utterance.wav");
	~samplePaths[cat] = [path];
	~uttDict.add(cat-> 0);

	Buffer.read(s, PathName(~samplesPath).parentPath ++ "uttSamples/" ++ cat +/+ "00_utterance.wav",
		action: {arg buffer;
			~uttSamples.add(cat-> [buffer, 0, buffer.numFrames]);
	});
});


PathName(~samplesPath).entries.do({
		arg subfolder;
	//subfolder.postln;
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

//load melodies
~melPath = ~resourcePath ++ "melodies.sc";
//~melos = ~melos ? ();
~melos = ();
~melos = thisProcess.interpreter.compileFile(~melPath.absolutePath).value;

// define function to get PatternLists out of MIDIFolder
~makePatternList = {
	//returns Pseqs for notes and durs, derived from MIDIfiles in the MIDI folder
	|key, path, make|
	var midi, notes=[].asList, durs=[].asList, c;
	if(make==True, {
		midi = SimpleMIDIFile.read(path.fullPath);
		//midi.midiEvents.dopostln;

		c = case
		{key == "note"}{
			midi.generatePatternSeqs.flatten(2).pairsDo({|a,b|
				/*"a % is %".format(a, a.class).postln;
				"a % is %".format(a, (a < 10)).postln;*/
				if (((a < 10) || (a.isSymbol )), {
					notes.add(Rest(0).asSymbol)
				}, {
					notes.add(a)
				});
			});
			"file notes %: % ".format(path.fileNameWithoutExtension, notes).postln;
		}
		{key == "dur"} {
			midi.generatePatternSeqs.flatten(2).pairsDo({|a,b|
				durs.add(b.softRound(0.125, 0.001,1))});
			"file durs %: %".format(path.fileNameWithoutExtension, durs).postln;
		}
		{true}{"end of MIDIPatterns".postln};
	});
};

// get PatternLists out of MIDIFolder
~midiFolder = ~showFolder +/+ "MIDI";
PathName(~midiFolder).entries.do({
	|path|
	//"entry: % and %".format(path, path.fileNameWithoutExtension).postln;
	//midiKey = path.fileNameWithoutExtension.asSymbol;
	~makePatternList.("note", path, False);
    ~makePatternList.("dur", path, False);
});



~makeWaveTable = {
	|size|
	var sig, wt, buf;
	sig = Signal.sineFill(size.asInteger, Array.fill(6, {rrand(0.01, 1)}), [0,pi,0,pi,0,0].scramble);
	wt = sig.asWavetable;
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
		~perc = MixerChannel(\ch7, s, 2, 2, outbus: ~master);
		~bass = MixerChannel(\ch8, s, 2, 2, outbus: ~master);
		~ringmod = MixerChannel(\ring, s, 2, 2, outbus: ~master);
		~chorus = MixerChannel(\chrs, s, 2, 2, outbus: ~master);
		~reverb = MixerChannel(\vrb1, s, 2, 2, outbus: ~master);
		~cat2Channel = (
		\pr: ~ch1,
		\dis: ~ch2,
		\con: ~ch3,
		\lec: ~ch4,
		\ins: ~ch5,
		\kik01: ~perc,
		\sn01 : ~perc,
		\h01: ~perc,
		\bass: ~bass
	);

		~cat2Channel = (
		\dis: ~ch1,
		\pr: ~ch2,
		\ins: ~ch3,
		\con: ~ch4,
		\lec: ~ch5,
		\utt: ~utt,
		\perc: ~perc,
		\kik02 : ~perc,
		\sn01 : ~perc,
		\hh01: ~perc,
		\bass: ~bass
	);

)};