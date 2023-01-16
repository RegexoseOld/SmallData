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
    s.sync;

    /// load SynthDefs

	(~resourcePath ++ "constants.scd").load;
	(~resourcePath ++ "synths.scd").load;
	(~resourcePath ++ "functions.scd").load;
	~allocate = (~resourcePath ++ "allocate.scd").load;

    // make a name Dictionary

    s.sync;
    ServerTree.add(~makeNodes);
    ServerTree.run;
    "serverTree made nodes".postln;
    s.sync;


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

    s.sync;

    ~fadingSynths.do{| k| ~fadePatterns.add(k -> (\vol: 0.005))};
	(~fadingSynths ++ [\drm]).do{
        |name|
        var default;
        default = (name ++ "0").asSymbol;
        default.postln;
        Pbindef(name, *~states[name][default].asPairs);
    };

//~states[\pr]

    "done".postln;
});
)

((~dataPath ++ "allNotesOff.scd").load; ~allNotesOff.play)

// Testing
Pbindef(\lec).play
Pbindef(\pr).play
Pbindef(\ins).play
Pbindef(\con).play
Pbindef(\dis).play
Pbindef(\drm).play
~states[\ins][\ins0]

(
~sim = Routine(
    { loop ( {
        ~mock.();
        [2, 5].choose.wait;
        "mocked".postln;
        }
) }).play;
)
