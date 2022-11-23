
(
Server.hardFreeAll;
~configPath = PathName(thisProcess.nowExecutingPath).parentPath ++ "config.scd";
~configPath.load;
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
~volStep = 0.002; //vol reduction in continuous FadeOut
~fadeVols = 0; //the volumes of all fading Patterns
//fade Increase for fadePatterns
//~fadeInc = 0.04; //not needed

~fadingSynths = [\pr, \dis, \con, \lec, \ins];
~rauschSynths = [\imp, \perc1];
// booleans
~patternsPlaying = false;
~setMus = false;



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
    (~dataPath ++ "attuneFunctions.scd").load;

    //[\musar2, \musar].do{|k| Pbindef(k).play(~t, quant:4)};
    "done".postln;


});
)
((~dataPath ++ "allNotesOff.scd").load; ~allNotesOff.play)


(
~sim = Routine({
    loop(
        {
            ~mock.();
            [8, 12].choose.wait;
            "mocked".postln;
        }
    )
}).play;

)
~sim.stop
~god.play;


~melos[\melo][\ruzhim][0..0];

(~fadingSynths.do{|name| Pbindef(name, \dur, 2, \amp, 0.2, \index, Pwhite(1, 15, inf), \bpfMul, Pwhite(1, 3, inf)).play(~t, quant:0)};)

//start fadingSynths with fade = 0, they are getting louder with the att* Functions
 (~fadingSynths ).do{|name| Pbindef(name).play(~t, quant:4)};


Pbindef(\dis, \amp, 0.53, \fade, 0.6).trace.play
Pbindef(\dis, \atk, 0.9, \rls, 1.4);
Pbindef(\ins, \resoFreq, 400)
Pbindef(\lec, \resoFreq, 500)
Pbindef(\con, \resoFreq, 500)

~allocateSynth.value(\dissent, 3)
~allocateSynth.value(\praise, 34)
~allocateSynth.value(\concession, 44)
~allocateSynth.value(\lecture, 1)
~allocateSynth.value(\insinuation, 1)

(
var vel;
~tNote = 64;
vel = ~melos[\zit][\vel][~tNote.asSymbol];
~midiOut.noteOn(0, ~tNote, vel)

)
~midiOut.noteOn(0, ~tNote, 0);


~reverb = Synth(\reverb, [\lofr, 100, \hifr, 200])

