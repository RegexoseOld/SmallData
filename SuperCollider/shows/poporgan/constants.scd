~numSlots = 16;
~storyIndex = 0;
~currentUttPattern = \mono;
~factor = 1;
~totalUtts = 0;
~t = TempoClock(80/60).permanent_(true);
///////
~fbVol = 0.07; //global Volume of feedback for incoming Utts
// values for addVolume
~volPlus = 0.06; // this much volume is added each time a category comes in
~addFac = 1.2; // factor of volPlus with vols below the threshold
~subFac = 1.8; // factor of volStep with vols below the threshold
~volMax = 0.55; // max Volume should be less than 1.0/5
~volMin = 0.002; // the min Volume for a faded Pattern
~volThres = 0.35; // Threshold managed by ~addVolume and ~continuousFade
~volStep = 0.004; //vol reduction in continuous FadeOut
~volMax = 0.45; // max Volume should be less than 1.0/5
~fadeVols = 0; //the volumes of all fading Patterns
~thresCont = 0.15; // threshold from which to continuously fade Out
