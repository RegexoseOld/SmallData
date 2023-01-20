(
Server.hardFreeAll;
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
	/*MIDIClient.init;
	~midiOut = MIDIOut.new(0);*/

	/// load SynthDefs, Constants, Functions
	(~resourcePath ++ "synths.scd").load;
	(~resourcePath ++ "constants.scd").load;
	(~resourcePath ++ "functions.scd").load;

	~allocate = (~resourcePath ++ "allocate.scd").load;

	ServerTree.add(~makeNodes);
	ServerTree.run;
	"serverTree made nodes".postln;
	s.sync;

//make Dictionary with effekt Patches
	~patches = (~resourcePath ++ "fx_patches.scd").load;


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
				categorySymbol = \drm;
			}
		);
		~states.put(categorySymbol, patternStates[\patterns]);
	});

	~fadingSynths.do{| k| ~fadePatterns.add(k -> (\vol: 0.005))};
	(~fadingSynths ++ [\drm]).do{
		|name|
		var default;
		default = (name ++ "0").asSymbol;
		//default.postln;
		Pbindef(name, *~states[name][default].asPairs);
	};

	// Send Objekte machen
	~sends = ~sends ? ();

	[~ch1, ~ch2, ~ch3, ~ch4, ~ch5].do{
		|ch, i|
		var sendName;
		//postf("channel %\t i %\n", ch, i);
		[~reverb, ~ringmod].do {
			|fx|
			sendName = "ch" ++ (i+1).asString ++ "_send_" ++ fx.asString[13..16];
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
			~allocateSynth.value(msg[2], ~uttDict[msg[2]]);
			~setGlobal.value();
		},
		'/interpreter_input'
	);


	"done".postln;
});

)

//  load patches
~runFx.();

Window.closeAll;
~sends[\ch1_send_ring].level = 0.9;
~sends[\ch1_send_verb].level = 0.2;
~sends[\ch5_send_ring].levelTo(0.99, 5);
~sends[\ch5_send_verb].level = 0.1;



// Testing
Pbindef(\lec, \dur, 1).play
Pbindef(\pr, \dur, 0.5, \amp, 0.05, \atk, 0.02, \rls, 0.1).play
Pbindef(\ins,  \dur, 0.33, \amp, 0.1).play
Pbindef(\con, \dur, 0.33, \amp, 0.3).play
Pbindef(\dis, \dur, 0.5, \atk, 0.03, \rls, 0.1, \amp, 0.3, \ffreq, Pwhite(100, 1000, inf)).play
Pbindef(\drm).stop

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
