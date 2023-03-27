(
var path;
path = thisProcess.nowExecutingPath;

~configFile = PathName(path).parentPath ++ "config.scd";
~configFile.load;
~resourcePath = PathName(path).parentPath ++ "resources/";

Server.default.options.numInputBusChannels_(0);
Server.default.options.outDevice_(~audioInterface);
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
	(~resourcePath ++ "constants.scd").load;
	(~resourcePath ++ "functions.scd").load;
	(~resourcePath ++ "organist.scd").load;

	~allocate = (~resourcePath ++ "allocate.scd").load;

	// LOAD GUI FILES
	thisProcess.interpreter.executeFile(PathName(path).parentPath +/+ "GUI_files/GUI_Styles.scd");
	thisProcess.interpreter.executeFile(PathName(path).parentPath +/+ "GUI_files/GUI_Constructor.scd");
	// Wait until boot is done and then begin launching the rest of the prograam
	s.sync;
	// Set global memory storage
	if (~gm == nil, {
		~gm = Dictionary.new();
	});
	thisProcess.interpreter.executeFile(PathName(path).parentPath +/+ "GUI_files/sequencer_gui.scd");

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
			var path = msg[4];
			postf("\nmessage?: %\n", msg);
			postf("\nnew utt: %", msg[1]);
			postf("\nnew cat: %\n", msg[2]);
			~cat = msg[2];
			~updateUtts.(msg[2]);
			~updateSample.(path);
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
        [2, 5].choose.wait;
        "mocked".postln;
        }
) }).play;
)
~seq = Pdefn(\melody).play(~t)
~seq.resume
(
~currentUttPattern = \vox;
~makeUttSlot.(~currentUttPattern);
~activateFaders.();
~runFx.();
Pbindef(\vox).play(~t);
Pbindef(\vox, \dur, 0.5, \atk, 0.02, \rls, 0.4, \lg1, 0.2, \lg2, 0.8, \end, 70000, \amp, 0.6);
/*Pbindef(\mono).play(~t)
Pbindef(\mono, \amp, 0.9, \dur, 1, \cgain, 2, \rls, 2);
Pbindef(\grainvox).play(~t);*/


)
(
Pbindef(\grainvox, \dur, 0.5, \atk, 0.06, \rls, 0.2, \sus, 0.2, \grainDur, 0.4, \grainAmp, 0.7, \dens, 20,
 \harm, -2, \pos, 0.1);
)
(
Pbindef(\grainvox).stop
Pbindef(\vox).stop
Pbindef(\mono).stop

)

Pbindef.all.do(_.stop);
~buffers[\lec01][1..16].do{|x|x.numFrames.postln}
(
~makeSlot.(\pr, 16)
~runFx.()


)

~states[\vox2]
Window.closeAll;

// Testing
s.makeWindow

(
//https://scsynth.org/t/switching-between-sample-and-non-sample-based-instruments-in-a-pattern/658

Ppatlace([~melos[\slots][\a], ~melos[\slots][\b], ~melos[\slots][\c]], inf).play
Ppatlace([Pbindef(\pr), Pbindef(\dis), Pbindef(\lec), Pbindef(\ins), Pbindef(\vox)], inf).play;
Ppatlace([Pbindef(\pr), Pbindef(\dis), Pbindef(\lec), Pbindef(\ins), Pbindef(\con)], inf).stop;
)

MIDIFunc.trace(false);
MIDIFunc.trace(true);


(
Pbindef(\lec).play(~t);
Pbindef(\lec, \modRate, 0.9, \filTime, 0.9, \atk, 0.001, \rls, 0.27, \fmFreq, 800, \fmVol, 100);
Pbindef(\pr, \dur, 1, \atk, 0.04, \rls, 0.3, \dev, Pwhite(0.3, 3, inf)).play(~t);
Pbindef(\ins).play(~t);
Pbindef(\ins, \dur, 1, \atk, 0.1, \atkcrv, Prand([-3, -1, 3, 7], inf), \relcrv, Pkey(\atkcrv), \midinote, 40, \modfreq, Pwhite(500, 4000, inf), \modamp, 1000).play(~t);
Pbindef(\con, \dur, 1, \carAmp, 0.8, \amp, 0.35, \decayScale, Pwhite(0.01, 6, inf), \accent, Pwhite(0, 5, inf)).play(~t);
Pbindef(\dis, \dur, 1, \atk, 0.1, \rls, 0.6, \amp, 0.25, \ffreq, Pwhite(100, 1000, inf)).play(~t);
Pbindef(\zahl, \dur, 0.5, \amp, 0.3, \rate, (0.9, 0.95 .. 1.1), \cgain, 1, \zit1, 10, \zit2, 2, \w, 2).play(~t);

Pbindef(\uttlec).play(~t);
Pbindef(\uttpr, \dur, 1, \rls, 0.2, \atk, 0.03, \buf, Pseq(~melos[\slots][\utt], inf), \amp, 0.8).play(~t);
Pbindef(\uttcon).play;
Pbindef(\uttins).play(~t);
Pbindef(\uttdis).play;
)
Pbindef.all.do(_.stop);
//Pbindef.all.do({|p| p.postln + "\n"})


~board = MixingBoard("demo",nil, ~ch1, ~ch2, ~ch3, ~ch4, ~ch5, ~ringmod, ~reverb, ~master);
(


topEnvironment.do(_.pop)
currentEnvironment
s.queryAllNodes
CmdPeriod.run
ServerTree.removeAll

