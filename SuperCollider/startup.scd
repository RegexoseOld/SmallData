(
var path;
path = thisProcess.nowExecutingPath;

~configFile = PathName(path).parentPath ++ "config.scd";
~configFile.load;
~resourcePath = PathName(path).parentPath ++ "resources/";

Server.default.options.numInputBusChannels_(1);
Server.default.options.outDevice_(~audioInterface);
Server.default.options.inDevice_(~audioInterface);
s.newBusAllocators;
ServerTree.removeAll; // löscht alle funktionen

s.waitForBoot({
	s.freeAll;
	Buffer.freeAll;
	Pbindef.all.do(_.clear);
	s.sync;
	MIDIClient.init;
	MIDIIn.connectAll;
	~midiOut = MIDIOut.new(0);
	~midiIn = MIDIIn.new(0);


	/// load SynthDefs, Constants, Functions
	(~resourcePath ++ "synths.scd").load;
	(~resourcePath ++ "story.scd").load;
	(~resourcePath ++ "constants.scd").load;
	(~resourcePath ++ "functions.scd").load;
	(~resourcePath ++ "organist.scd").load;

	// LOAD GUI FILES
	thisProcess.interpreter.executeFile(PathName(path).parentPath +/+ "GUI_files/GUI_Styles.scd");
	thisProcess.interpreter.executeFile(PathName(path).parentPath +/+ "GUI_files/GUI_Constructor.scd");
	// Wait until boot is done and then begin launching the rest of the prograam
	s.sync;
	// Set global memory storage
	if (~gm == nil, {
		~gm = Dictionary.new();
	});

	Window.closeAll;
	thisProcess.interpreter.executeFile(PathName(path).parentPath +/+ "GUI_files/sequencer_gui.scd");

	~allocate = (~resourcePath ++ "allocate.scd").load;

    MixerChannel.freeAll;
	s.sync;
	ServerTree.add(~makeNodes);
	ServerTree.run;
	"serverTree made nodes".postln;
	 ~makeWaveTable.(4096); // for WaveTable Synth
	s.sync;

//make Dictionary with effekt Patches
	~patches = (~resourcePath ++ "fx_patches.scd").load;
	//make all other Dictionaries, that can't be made in constants
	~makeDictionaries.();

	//load melodies
	~melPath = ~resourcePath ++ "melodies.sc";
	//~melos = ~melos ? ();
	~melos = ();
	~melos = thisProcess.interpreter.compileFile(~melPath.absolutePath).value;


// load state patterns into a Dictionary with different states for the 5 categories
	//~states = ~states ? ();
	~states = ();
	PathName(~showFolder).entries.do({
		|pathName, i|
		var categorySymbol, category, patternStates;
		category = pathName.fileNameWithoutExtension;
		patternStates = thisProcess.interpreter.compileFile(pathName.absolutePath).value;
		if (~categorySymbols.includesKey(category.asSymbol),
			{
				categorySymbol = ~categorySymbols[category.asSymbol];
				~states.put(categorySymbol, patternStates[\patterns]);
			},
			{
				categorySymbol = \additional;
				patternStates[\patterns].keys.do{
					|k|
					~states.put(k, patternStates[\patterns][k]);
					Pbindef(k, *~states[k].asPairs);
					~additionalSynths.add(k);
					~cat2Channel.put(k, ~utt);
					Pbindef(k, \out, ~cat2Channel[k].inbus);
				};
			};
		);
	});

	// set fade volume low at the beginning
	~fadingSynths.do{| k| ~fadePatterns.add(k -> (\vol: 0.005)); ~faderControl.add(k)};
	~faderControl.add(~additionalSynths.asArray);

	// make Patterns for all fading Synths
	~fadingSynths.do{
		|name|
		var default, c;
		default = (name ++ "0").asSymbol;
		default.postln;
		Pbindef(name, *~states[name][default].asPairs);
	    Pbindef(name, \out, ~cat2Channel[name].inbus); //assign to channel input
	};

	// Send Objekte machen
	~sends = ~sends ? ();

	[~ch1, ~ch2, ~ch3, ~ch4, ~ch5].do{
		|ch, i|
		var sendName;
		//postf("channel %\t i %\n", ch, i);
		[~reverb, ~ringmod, ~chorus].do {
			|fx|
			//postf("fx name %\n", fx.asString);
			sendName = "ch" ++ (i+1).asString ++ "_snd_" ++ fx.asString[13..16];
			~sends.put(sendName.asSymbol, ch.newPostSend(fx, 0.01) ); // nicht an patch sondern an channel senden
		}
	};

	OSCdef.newMatching(
		\interpreter,
		{ arg msg;
			//postf("\nmessage?: %\n", msg);
			postf("\nnew utt: %", msg[1]);
			postf("\nnew cat: %\n", msg[2]);
			//postf("\npath  % path is nil? % \n", msg[4], msg[4].isNil);
			~cat = msg[2];
			~updateUtts.(msg[1], msg[2]);
			//~updateSample.(msg[4]);
			~allocateSynth.value(msg[2], ~uttDict[msg[2]]);
			~setGlobal.value();
		},
		'/interpreter_input'
	);
	"done".postln;
})
);
(
~sim = Routine(
    { loop ( {
        ~mock.();
        [4, 5].choose.wait;
		//"mocked" .po stln;
        }
) }).play;
)
~sim.stop
~t.beatsPerBar

Pbindef(\sn01, \ffreq, 1200, \cgain, 1, \thr, 0.8, \rls1, 0.1, \numharm, 20, \ampDecay, 0.9)
Pbindef(\sn02)
Synth(\sn2)
(
~allocate.(\dis, 21)
~allocate.(\ins, 21)
~allocate.(\lec, 21)
~allocate.(\pr, 21)
~allocate.(\con, 11)
Pbindef(\dis, \detune, Pn(Pgeom(30, 0.89, 16),inf));
Pbindef(\pr, \cgain, 3)
~states[\ins][\ins05]
~allocate.(\pr, 6)
~states[\pr][\pr05]
)
(
~postBeats = {~t.beats.postln; 4};
~t.schedAbs(~t.nextBar, {~postBeats.value})
)

Window.closeAll;
Pdefn(\melody).play(~t)
// Testing
s.makeWindow

Pbindef.all.do(_.stop);
~sim.stop
~uttSamples[\praise].play
(
Routine({
	s.record;
	wait(0.02);
	Synth(\rec, [\amp, 1.0, \in, 3]);
	wait(2);
	s.stopRecording
}).play
)
~buffers[\catSampDe][0].play
~buffers[\catSampEn][1].play
~buffers[\wt].numFrames.isPowerOfTwo
(
var new = ~lastUtterances.rotate(1);
new.put(0, "six");
~lastUtterances = new;
/*new.collect({|item, i|
	item.postln;
	if (i <2, {new.put((i+1), item)})
});
	new.put(0, "eight");*/
)
