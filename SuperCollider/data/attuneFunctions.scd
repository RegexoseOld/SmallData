
~addVolume = {
	|cat, add, max, thres|
	var c, editVol;
	editVol = ~patterns[cat][\vol];
	postf("\n updating volume of %  from %  add %   max %   thres % \n ", cat, editVol, add, max, thres );
	c = case
	{editVol <= thres}{editVol = editVol + (add *2); ~patterns[cat][\vol] = editVol }// double enhance when pattern is very quiet
	{(editVol<= max) && (editVol>= thres)}{editVol = editVol + add; ~patterns[cat][\vol] = editVol}
	{editVol >= max}{editVol = max; ~patterns[cat][\vol] = max}
	{true}{"end of addVolume".postln};
    Pbindef(cat, \amp, editVol);
	postf("new vol of %  is % \n", cat, editVol);

};

~continuousFadeOut = {
	|listOfPatterns, min, step, thres|
		//logarithmisch erst schnell, dann immer langsamer leiser

	listOfPatterns.do({
			|cat|
		var vol, c;
		vol = ~patterns[cat][\vol];
		//postf("\nthe vol %  of the pattern   %\n", vol, cat);
		c = case
		{(vol > min) && (vol >= thres)} {~patterns[cat][\vol] = vol - (step*4); vol = vol-(step*4)} // loud volumes decrease fast
		{(vol <= thres) && (vol >= min)} {~patterns[cat][\vol] = vol - step ; vol = vol- step} // middle volumes decrease slower
		{vol <= min} {~patterns[cat][\vol] = min; vol = min}
		{true}{"end of fade cases"};
		Pbindef(cat, \amp, vol);
	});

};



