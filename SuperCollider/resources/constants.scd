~fx1Bus = Bus.audio(s,2);
~fx2Bus = Bus.audio(s,2);
~fx3Bus = Bus.audio(s,2);
~numSlots = 16;
~cat = "lecture";

~currentUttPattern = \mono;
~factor = 1;
~totalUtts = 0;
~t = TempoClock(40/60).permanent_(true);
///////
~fbVol = 0.25; //global Volume of feedback for incoming Utts
// values for addVolume
~volPlus = 0.12; // this much volume is added each time a category comes in
~volFac = 1.0; // factor of volPlus with vols below the threshold
~volMax = 0.55; // max Volume should be less than 1.0/5
//~volMin = 0.0002; // the min Volume for a faded Pattern
~volMin = 0.001; // the min Volume for a faded Pattern
~volThres = 0.35; // Threshold managed by ~addVolume and ~continuousFade
~volStep = 0.004; //vol reduction in continuous FadeOut
~volPlus = 0.18; // this much volume is added each time a category comes in
~volFac = 1; // factor of volPlus with vols below the threshold
~volMax = 0.55; // max Volume should be less than 1.0/5
//~volMin = 0.0002; // the min Volume for a faded Pattern
~volMin = 0.09; // the min Volume for a faded Pattern
~volThres = 0.22; // Threshold managed by ~addVolume and ~continuousFade
~volStep = 0.0003; //vol reduction in continuous FadeOut
~fadeVols = 0; //the volumes of all fading Patterns
~fadingSynths = [\pr, \dis, \con, \lec, \ins];
~additionalSynths = List.new;
~faderControl = List.new; // Patterns controlled by MIDIFaders or OSC Controllers
// booleans
~patternsPlaying = false;

~fadePatterns = Dictionary.new;
~nameDict = Dictionary.new;
~buffers = Dictionary.new;
~samplesPath = PathName(thisProcess.nowExecutingPath).parentPath ++ "samples/";
~uttSample = Buffer.read(s, ~samplesPath +/+ "zahlen/01eins.wav");



