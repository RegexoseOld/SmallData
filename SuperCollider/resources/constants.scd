~fx1Bus = Bus.audio(s,2);
~fx2Bus = Bus.audio(s,2);
~fx3Bus = Bus.audio(s,2);
~numSlots = 16;
~cat = "lecture";
~storyIndex = 0;
~currentUttPattern = \mono;
~factor = 1;
~totalUtts = 0;
~t = TempoClock(40/60).permanent_(true);
///////
~fbVol = 0.07; //global Volume of feedback for incoming Utts
// values for addVolume
~volPlus = 0.06; // this much volume is added each time a category comes in
~addFac = 1.2; // factor of volPlus with vols below the threshold
~subFac = 1.8; // factor of volStep with vols below the threshold
~volMax = 0.55; // max Volume should be less than 1.0/5
//~volMin = 0.0002; // the min Volume for a faded Pattern
~volMin = 0.002; // the min Volume for a faded Pattern
~volThres = 0.35; // Threshold managed by ~addVolume and ~continuousFade
~volStep = 0.004; //vol reduction in continuous FadeOut
~volMax = 0.45; // max Volume should be less than 1.0/5
~fadeVols = 0; //the volumes of all fading Patterns
~thresCont = 0.15; // threshold from which to continuously fade Out
~maxCatCounter = 15; // max value of categoryCounter (counter is reset if this value is reached

~fadingSynths = [\pr, \dis, \con, \lec, \ins];
~additionalSynths = List.new;
~faderControl = List.new; // Patterns controlled by MIDIFaders or OSC Controllers
// booleans
~patternsPlaying = false;
~categories = ['dissent', 'praise', 'insinuation', 'concession', 'lecture'];
~lastUtterances = Array.with("one", "two", "three");
~lastCategories = Array.with("praise", "dissent", "insinuation");
~fadePatterns = Dictionary.new;
~nameDict = Dictionary.new;
~buffers = Dictionary.new;
~utts = Dictionary.new;
~uttDict = Dictionary.new;
~uttSamples = Dictionary.new;
//~samplesPath = PathName(thisProcess.nowExecutingPath).parentPath ++ "samples/";



