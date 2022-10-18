
~continuousFadeOut = {
	|min, step|
		//logarithmisch erst schnell, dann immer langsamer leiser

	~patternDict.keys.do({
			|cat|
		var vol, c;
		vol = ~synthDict[cat][\patternVol];
		//postf("\nthe vol %  of the pattern   %\n", vol, cat);
		c = case
		{(vol > min) && (vol >= ~fadeThres)} {~synthDict[cat][\patternVol] = vol - (step*4); vol = vol-(step*4)}
		{(vol <= ~fadeThres) && (vol >= min)} { ~synthDict[cat][\patternVol] = vol - step ; vol = vol- step} // slower fade when below thres
		{vol <= min} {~synthDict[cat][\patternVol] = min; vol = min}
		{true}{"end of fade Cases"};
		//if (vol > min, {~synthDict[cat][\pattern] = vol - step; vol = vol-step}, {~synthDict[cat][\pattern] = min; vol = min});
		Pbindef(cat, \amp, vol);
	});
		//"+++ ++++\t \t +++ ++++".postln;/*
		//("tempo = " + t.tempo).postln;*/
};

~printSomething = {|it|
	postf("% is printed as %, indeed", it, it)
}
