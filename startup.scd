(
~projectRoot = PathName(thisProcess.nowExecutingPath).parentPath;

~configFile = ~projectRoot ++ "config.scd";
~configFile.load;
~resourcePath = ~projectRoot ++ "resources/";

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
	(~resourcePath ++ "initialisation.scd").load;
	(~resourcePath ++ "functions.scd").load;
	(~resourcePath ++ "organist.scd").load;

	// LOAD GUI FILES
	thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI_files/GUI_Styles.scd");
	thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI_files/GUI_Constructor.scd");
	// Wait until boot is done and then begin launching the rest of the prograam
	s.sync;
	// Set global memory storage
	if (~gm == nil, {
		~gm = Dictionary.new();
	});

	Window.closeAll;
	thisProcess.interpreter.executeFile(~projectRoot +/+ "GUI_files/sequencer_gui.scd");

	// Load song specific files
	~allocate = (~showFolder +/+ "allocate.scd").load;
	(~showFolder +/+ "constants.scd").load;

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


	//load melodies
	~melPath = ~resourcePath ++ "melodies.sc";
	//~melos = ~melos ? ();
	~melos = ();
	~melos = thisProcess.interpreter.compileFile(~melPath.absolutePath).value;


// load state patterns into a Dictionary with different states for the 5 categories
	//~states = ~states ? ();
	~states = ();
	(PathName(~showFolder) +/+ "patterns").entries.do({
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
					//~cat2Channel.put(k, ~utt);
					//Pbindef(k, \out, ~cat2Channel[k].inbus);
				};
			};
		);
	});

	// set fade volume low at the beginning
	~fadingSynths.do{| k|  ~faderControl.add(k)};
[\bass, \kik01].do {|k| ~faderControl.add(k)};

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
			~cat = msg[2];
			~updateUtts.(msg[1], msg[2]);
			~blinkSelector.();
			~addNewSample.(msg[4]);
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
        [16, 10].choose.wait;
		//"mocked" .po stln;
        }
) }).play;
)
~sim.stop

~t.beatsPerBar
~states[\bass]

~samplePaths["dissent".asSymbol]
~uttSamples["dissent".asSymbol]
~slider_buttons[1]["dissent"]
Pbindef(\sn01, \ffreq, 1200, \cgain, 1, \thr, 0.8, \rls1, 0.1, \numharm, 20, \ampDecay, 0.9)
Pbindef(\sn02)
Synth(\sn2)
(
~allocate.(\dis, 7)
~allocate.(\ins, 7)
~allocate.(\lec,7)
~allocate.(\pr, 7)
~allocate.(\con, 7)

)
(
Pbindef(\pr).play
Pbindef(\pr, \mRatio, 0.8, \cRatio, 1.1, \fmDur, 4, \index, 10, \bpf, 300, \bpf2, 10, \bpf3, 4, \bpfQ, 0.2, \bpfMul, 10, \vibF, 0.002 )
Pbindef(\con).play
Pbindef(\con).stop
Pbindef(\con, \dur, 1, \rls, 2.3)
Pbindef(\metronom).stop
)
(
~postBeats = {~t.beats.postln; 4};
~t.schedAbs(~t.nextBar, {~postBeats.value})
)
~t.tempo = 120/60

Window.closeAll;
Pdefn(\melody).play(~t)
// Testing
s.makeWindow
Pbindef(\vox, \rls, 1, \crv, -1, \lg1, 1, \lg2, 0.8).play

Pbindef.all.do(_.stop);

// record some stuff..
(
Routine({
	s.record;
	wait(0.02);
	Synth(\rec, [\amp, 1.0, \in, 3]);
	wait(2);
	s.stopRecording
}).play
)
~categories

currentEnvironment.keys.do(_.postln)