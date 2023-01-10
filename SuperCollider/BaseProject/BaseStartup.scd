// from AttuningBells ...
//
(
Server.hardFreeAll;
~configFile = PathName(thisProcess.nowExecutingPath).parentPath ++ "configBase.scd";
~configFile.load;
~dataPath = PathName(thisProcess.nowExecutingPath).parentPath ++ "data/";

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

    (~dataPath ++ ~constantsfile).load;
    (~dataPath ++ ~synthsfile).load;
    (~dataPath ++ ~functionsfile).load;

    // make a name Dictionary
    ~makeDict.();


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
    ~melPath = ~dataPath ++ ~melodyfile;
    ~melos = ~melos ? ();
    ~melos = thisProcess.interpreter.compileFile(~melPath.absolutePath).value;


    // load state patterns into 5 global files

    //~patPath = ~dataPath ++ "praiseStates.scd";
   ~states = ~states ? ();
   ~statesFiles.do{
        |file|
        var patPath, categoryStates;
        patPath = ~dataPath ++ file;
        categoryStates = thisProcess.interpreter.compileFile(patPath.absolutePath).value;
        /*~nameDict[file].asSymbol.postln;
        categoryStates[\patterns].postln;*/
        ~states.put(~nameDict[file].asSymbol, categoryStates[\patterns]);
    };
    s.sync;


    ~fadingSynths.do{| k| ~fadePatterns.add(k -> (\vol: 0.005))};
    ~fadingSynths.do{
        |name|
        var default;
        default = (name ++ "0").asSymbol;
        default.postln;
        Pbindef(name, *~states[name][default].asPairs);
    };

    "done".postln;
});
)

((~dataPath ++ "allNotesOff.scd").load; ~allNotesOff.play)

// Testing
Pbindef(\lec).play
Pbindef(\lec, *~states[\lec][\lec1].asPairs)

