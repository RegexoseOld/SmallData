
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
~cat2Channel = (
		\dis: ~ch1,
		\pr: ~ch2,
		\con: ~ch3,
		\lec: ~ch4,
		\ins: ~ch5,
		\kik01: ~perc,
		\sn01 : ~perc,
		\h01: ~perc,
		\bass: ~bass
	);
~lastUtterances = Array.with("one", "two", "three");
~lastCategories = Array.with("praise", "dissent", "insinuation");
~samplesPath = PathName(thisProcess.nowExecutingPath).parentPath ++ "samples/";
~showFolder = ~projectRoot +/+ "shows" +/+ ~showName;
~fadePatterns = Dictionary.new;

~buffers = Dictionary.new;
~uttDict = Dictionary.new;
~uttSamples = Dictionary.new;  // dictionary with current audio utterances
~samplePaths = Dictionary.new; // container for paths of audio-utterance-PopUpMenus. dictionary of dictionaries with paths to all audio utterances, ie ~samplePaths[praise] contains [name1->path1,...] - dictionary to audio-utterances of praise


~categories.do({
	|cat|
	var path = PathName(PathName(~samplesPath).parentPath ++ "uttSamples/" ++ cat +/+ "00_utterance.wav");
	~samplePaths.add(cat -> Dictionary[cat.asSymbol -> path]);
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

)};