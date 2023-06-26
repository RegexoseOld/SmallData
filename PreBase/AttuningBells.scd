
(
Server.hardFreeAll;
~configFile = PathName(thisProcess.nowExecutingPath).parentPath ++ "config.scd";
~configFile.load;
~dataPath = PathName(thisProcess.nowExecutingPath).parentPath ++ "data/";

Server.default.options.numInputBusChannels_(0);
Server.default.options.outDevice_(~audioInterface);
Server.default.options.outDevice.postln;

ServerTree.removeAll; // löscht alle funktionen
s.newBusAllocators; // Busse machen
~fx1Bus = Bus.audio(s,2);
~fx2Bus = Bus.audio(s,2);
~fx3Bus = Bus.audio(s,2);
~cat = "";
~factor = 1;
~totalUtts = 0;
~t = TempoClock(40/60).permanent_(true);
///////
~fbVol = 0.35; //global Volume of feedback for incoming Utts
// values for addVolume
~volPlus = 0.03; // this much volume is added each time a category comes in
~volFac = 1.1; // factor of volPlus with vols below the threshold
~volMax = 0.55; // max Volume should be less than 1.0/5
~volMin = 0.0002; // the min Volume for a faded Pattern
~volThres = 0.3; // Threshold managed by ~addVolume and ~continuousFade
~volStep = 0.004; //vol reduction in continuous FadeOut
~fadeVols = 0; //the volumes of all fading Patterns
//fade Increase for fadePatterns
//~fadeInc = 0.04; //not needed

~fadingSynths = [\pr, \dis, \con, \lec, \ins];
~rauschSynths = [\imp, \perc1];
// booleans
~patternsPlaying = false;


s.waitForBoot({
    s.freeAll;
    Buffer.freeAll;
    Pbindef.all.do(_.clear);
    s.sync;
    MIDIClient.init;
    ~midiOut = MIDIOut.new(0);
    s.sync;

    /// load SynthDefs
    ~fadePatterns = Dictionary.new;
    (~dataPath ++ "SynthsAttuning.scd").load;
     (~dataPath ++ "attuneFunctions.scd").load;
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
    ~melPath = ~dataPath ++ "attune_melos.sc";
    ~melos = ~melos ? ();
    ~melos = thisProcess.interpreter.compileFile(~melPath.absolutePath).value;
    ~musarMel = ~melos[\melo][\ruzhim01];
    ~musarDur = ~melos[\duras][\ruzhim01];

    ~fadingSynths.do{| k| ~fadePatterns.add(k -> (\vol: 0.005))};
    ~patPath = ~dataPath ++ "attune_patterns.sc";
    ~reset = ~reset ? ();
    ~reset = thisProcess.interpreter.compileFile(~patPath.absolutePath).value;
    s.sync;

//zither constanten
~zC = (
    gM: false,
    gC: false,
    zChord: ~melos[\melo][\z_ruzhim01][0..3],
    cDur: ~t.tempo * 5, // duration of the godChord
    cPause: ~t.tempo * 8, //pause between two Chords
    mPause: ~t.tempo * 4, //pause between two melos
    zMelo: ~melos[\melo][\z_ruzhim01],
    zDur: ~melos[\duras][\z_ruzhim01]
);


    (~fadingSynths ++ ~rauschSynths ++ [\musar2, \musar, \drum]).do{
        |name|
        name.postln;
        Pbindef(name, *~reset[name].asPairs);
    };

    // set functions
    ~attCat = (~dataPath ++ "attuneCategory.scd").load;
    ~setRauschen = (~dataPath ++ "setRauschen.scd").load;
    ~setMusar = (~dataPath ++ "setMusar.scd").load;

    //[\musar2, \musar].do{|k| Pbindef(k).play(~t, quant:4)};
    "done".postln;


});
)

((~dataPath ++ "allNotesOff.scd").load; ~allNotesOff.play)


