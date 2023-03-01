(

~configFile = PathName(thisProcess.nowExecutingPath).parentPath ++ "config.scd";
~configFile.load;
~resourcePath = PathName(thisProcess.nowExecutingPath).parentPath ++ "resources/";

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

    MixerChannel.freeAll;
	s.sync;
	ServerTree.add(~makeNodes);
	ServerTree.run;
	"serverTree made nodes".postln;
	s.sync;

//make Dictionary with effekt Patches
	~patches = (~resourcePath ++ "fx_patches.scd").load;
	//make all other Dictionaries, that can't be made in constants
	~makeDictionaries.();


	//load melodies
	~melPath = ~resourcePath ++ "melodies.sc";
	~melos = ~melos ? ();
	~melos = thisProcess.interpreter.compileFile(~melPath.absolutePath).value;

// load state patterns into a Dictionary with different states for the 5 categories
	~states = ~states ? ();
	PathName( ~showFolder).entries.do({
		|pathName, i|
		var categorySymbol;
		var category = pathName.fileNameWithoutExtension;
		var patternStates = thisProcess.interpreter.compileFile(pathName.absolutePath).value;
		if (~categorySymbols.includesKey(category.asSymbol),
			{
				categorySymbol = ~categorySymbols[category.asSymbol];
			},
			{
				[\vox, \drm, \vox2, \zahl].do{
					|name|
					~states.put(name, patternStates[name]);
					Pbindef(name, *~states[name].asPairs);
				}∞
			}
		);
		~states.put(categorySymbol, patternStates[\patterns]);
	});


	// set fade volume low at the beginning
	~fadingSynths.do{| k| ~fadePatterns.add(k -> (\vol: 0.005))};

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
			postf("\nnew utt: %", msg[1]);
			postf("\nnew cat: %\n", msg[2]);
			~cat = msg[2];
			~updateUtts.(msg[2]);
			~updateSample.();
			~allocateSynth.value(msg[2], ~uttDict[msg[2]]);
			~setGlobal.value();
		},
		'/interpreter_input'
	);


	"done".postln;
});

)


Window.closeAll;
~buffers[\lecture][0].play

// Testing
~channels = [~ch1, ~ch2, ~ch3, ~ch4, ~ch5, ~master, ~ringmod, ~reverb];
(
//https://scsynth.org/t/switching-between-sample-and-non-sample-based-instruments-in-a-pattern/658

Ppatlace([~melos[\slots][\a], ~melos[\slots][\b], ~melos[\slots][\c]], inf).play
Ppatlace([Pbindef(\pr), Pbindef(\dis), Pbindef(\lec), Pbindef(\ins), Pbindef(\con)], inf).stop;
)

MIDIFunc.trace(false);
MIDIFunc.trace(true);

~makeSlot.(\lec, 20)

~fadingSynths.do{|chan, i| ~activateFader.(chan, i)}
~channels.do(_.postln);
~sends.keys.do(_.postln)
~melos[\slots][\uttlec].trace.play


(
Pbindef(\lec, \dur, 0.24, \atk, 0.09, \rls, 0.27, \sustain, 0.2, \amp, 0.23);
Pbindef(\pr, \dur, 1, \amp, 0.1, \atk, 0.02, \rls, 1.5);
Pbindef(\ins,  \dur, 1, \amp, 0.1);
Pbindef(\con, \dur, 1, \amp, 0.25);
Pbindef(\dis, \dur, 0.33, \atk, 0.1, \rls, 0.6, \amp, 0.5, \ffreq, Pwhite(100, 1000, inf));
Pbindef(\zahl, \amp, 0.9, \cgain, 3).play
)
Pbindef.all.do(_.stop)
//Pbindef.all.do({|p| p.postln + "\n"})


~board = MixingBoard("demo",nil, ~ch1, ~ch2, ~ch3, ~ch4, ~ch5, ~ringmod, ~reverb, ~master);
(
~sim = Routine(
    { loop ( {
        ~mock.();
        [2, 5].choose.wait;
        "mocked".postln;
        }
) }).play;
)

topEnvironment.do(_.pop)
currentEnvironment
s.queryAllNodes
CmdPeriod.run
ServerTree.removeAll

