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
	~makeDictionaries.();

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
			~updateSample.(msg[4]);
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

Pbindef(\sn01, \ffreq, 1200, \cgain, 1, \thr, 0.8, \rls1, 0.1, \numharm, 20, \ampDecay, 0.9)
Pbindef(\sn02)
Synth(\sn2)
(
~allocate.(\dis, 1)
~allocate.(\ins, 21)
~allocate.(\lec, 21)
~allocate.(\pr, 21)
~allocate.(\con, 21)
Pbindef(\dis, \thr, 0.7, \cgain, 1.4, \gendAmp, 0.9, \ffreq, 2600, \rq, 0.8, \lag, 0, \pulseMul, 0.6, \add, 0, \width, 0.3);
Pbindef(\pr).play(~t)
Pbindef(\pr, \cgain, 1.0, \vibF, Pseq([0.2, 4, 2.0, 0.4],inf), \bpf, Pwhite(300, 600, inf) )
Pbindef(\con, \detune, 0)
Pbindef(\sn01, \dur, 1/4, \freq, Pseq([\, \, Pn(200, 6), \, \, 190, \, \, Pn(200, 4), \, \], inf)).quant_(1)
Pbindef(\lec, \fmVol, 150, \fmVol, 150, \filTime, 0.1, \modRate, 0.9, \rls, 0.1, \sustain, 0.15)
Pbindef(\sn01, \freq, 300)
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
Pbindef(\vox, \rls, 1, \crv, -1, \lg1, 1, \lg2, 0.8).play

Pbindef.all.do(_.stop);
~sim.stop

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

currentEnvironment.keys.do(_.postln)