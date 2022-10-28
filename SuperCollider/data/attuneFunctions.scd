
~uttDict = Dictionary.new;
	['dissent', 'praise', 'insinuation', 'concession', 'lecture'].do({
		|cat|
		~uttDict.add(cat-> 0)
	});

~updateUtts = {
    |cat|
    postf("\n \n+++ ++++ ++++ \n\nnew UTT %\t \n", cat);
    ~totalUtts = ~totalUtts + 1;
    postf("\n \n+++ ++++ ++++ \n\nnew UTT %\t\t % \n", cat, ~totalUtts.postln);
    ~uttDict[cat].postln;
    ~uttDict[cat] = ~uttDict[cat] + 1;
    postf("\nupdated % to % ", cat, ~uttDict[cat]);
};

~addVolume = {
	|cat, add, max, thres|
	var c, editVol;
	editVol = ~fadePatterns[cat][\vol];
	postf("\n updating volume of %  from %  add %   max %   thres % \n ", cat, editVol, add, max, thres );
	c = case
    {editVol <= thres}{"double add".postln; ~fadePatterns[cat][\vol] = editVol + (add *2) }// double enhance when pattern is very quiet
	{(editVol<= max) && (editVol>= thres)}{"simple add".postln; ~fadePatterns[cat][\vol] = editVol + add}
	{editVol >= max}{"max - keep value".postln; ~fadePatterns[cat][\vol] = max}
	{true}{"end of addVolume".postln};
    Pbindef(cat, \amp, ~fadePatterns[cat][\vol]);
	postf("new vol of %  is % \n", cat, ~fadePatterns[cat][\vol]);

};

~continuousFadeOut = {
	|listOfPatterns, min, step, thres|
		//logarithmisch erst schnell, dann immer langsamer leiser

	listOfPatterns.do({
			|cat|
		var vol, c;
		vol = ~fadePatterns[cat][\vol];
		//postf("\nthe vol %  of the pattern   %\n", vol, cat);
		c = case
		{(vol > min) && (vol >= thres)} {~fadePatterns[cat][\vol] = vol - (step*4)} // loud volumes decrease fast
		{(vol <= thres) && (vol >= min)} {~fadePatterns[cat][\vol] = vol - step ;} // middle volumes decrease slower
		{vol <= min} {~fadePatterns[cat][\vol] = min}
		{true}{"end of fade cases"};
		Pbindef(cat, \amp, ~fadePatterns[cat][\vol]);
	});

};

~allocateSynth = {
		|s_name, count|
		var c;
    postf("\nallocating % with count %\n", s_name, count);
		c = case
    {s_name == 'praise'} {~attPraise.value(count)} // reverb
    {s_name == 'dissent'} {~attDissent.value(count)}
    {s_name == 'insinuation'} {~attInsinuation.value(count)}
    {s_name == 'lecture'} {~attLecture.value(count)}
    {s_name == 'concession'} {~attConcession.value(count)}
		{true}{"end of allocation".postln};

	};

~setGlobal = {
		var c;
    //~totalUtts.postln;
		c = case
		{(~totalUtts >= 41) && (~totalUtts <= 49)} {"starting knacks".postln; ~setObj04.value(~totalUtts) ; }
		{(~totalUtts >= 21) && (~totalUtts <= 29)} {"starting knacks".postln; ~setObj04.value(~totalUtts) ; }
		{(~totalUtts > 0) && (~totalUtts <= 10)} {~setMusar.(~cat, ~totalUtts)}
		{true} {"end of global settings".postln};
};

~mock = {
    var cat = ['dissent', 'praise', 'insinuation', 'concession', 'lecture'].choose;
    ~cat = cat;
    ~updateUtts.(cat);
	~allocateSynth.value(cat, ~uttDict[cat]);
	~setGlobal.value();
};



