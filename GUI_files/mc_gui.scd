var mcWindow, mcTop, mcToplevel, mcCatwidth, mcCatheight;

mcCatwidth = 100;
mcCatheight = 120;
mcWindow = ~buildWindow.("MC", 10, 10, mcCatwidth*6+500, mcCatheight + 380);
mcTop = ~buildTopLevel.(mcWindow, 10, 10, mcCatwidth*5+ 720, mcCatheight*5+360);

// frame for MC Track
~mcTrack = ~buildMcTrack.(mcTop, 10, 0,  mcCatwidth*5+20, mcCatheight *3, 5, mcCatwidth);
~mcLabels = ~buildMcLabels.(mcTop, 10, mcCatheight *3 + 30, mcCatwidth*6 , 60, mcCatwidth, ~uttDict);
~status = ~buildStatus.(mcWindow, mcCatwidth*6 +50, 20, mcCatwidth * 3, mcCatheight * 3.5, ~lastUtterances);

CmdPeriod.add({
	mcWindow.close;
});
