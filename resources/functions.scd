
~updateUtts = {
    |utt, cat|
    //postf("\n \n+++ ++++ ++++ \n\nnew UTT %\t \n", cat);
    var lastUtts = ~lastUtterances.rotate(1), lastCats = ~lastCategories.rotate(1);
    lastUtts.put(0, utt);
    lastCats.put(0, cat);
    defer {3. do{|i|
        ~status[2][i].string = lastCats[i] ++ " : " ++ lastUtts[i]
    }};
    ~lastUtterances = lastUtts;
    ~lastCategories = lastCats;
    ~totalUtts = ~totalUtts + 1;
    if(~uttDict[cat] >= ~maxCatCounter, {~uttDict[cat] = 1}, {~uttDict[cat] = ~uttDict[cat] + 1} );
    ~uttsPerMinute[cat].add(~t.beats/~t.tempo); // add a timestamp to calculate utterances per minute
    defer{var index, count;
        index = ~fadingSynths.detectIndex({|it, i| it == ~categorySymbols[cat.asSymbol]});
        count =  ~uttDict[~cat].asString;
        //postf("\nupdating index % to count % ", index, count);
        ~mcLabels[1][index].string = cat ++ "\n" ++ count;
        ~mcLabels[1][5].string = "total utts" ++ "\n" ++ ~totalUtts ;
    }
};

~selectorAction = {
    |menu|
    var cat, pathToFile;
    cat = menu.name.asSymbol;
    pathToFile = ~samplePaths[cat][menu.value];
    Buffer.read(s, pathToFile.fullPath, action: {arg buffer;
        AppClock.sched(0, {
            ~uttSamples.put(cat, [buffer, 0, buffer.numFrames-1]); // update sample
            ~sliderButtons[1][cat][0].readFile(SoundFile.openRead(buffer.path), 0, buffer.numFrames); // update SoundFileView
            ~sliderButtons[1][cat][1].lo_(0); // reset low-end of Slider
            ~sliderButtons[1][cat][1].hi_(1); // reset hi-end of Slider
            ~sliderButtons[1][cat][1]  // update  start and end of sample
            .action_({ |slider|
                ~uttSamples[cat][1] = (slider.lo.lincurve(0, 1, 0 , buffer.numFrames, 0)).asInteger;
                ~uttSamples[cat][2] = (slider.hi.lincurve(0, 1, 0 , buffer.numFrames, 0)).asInteger;
            })
        });
    });
};

~blinkSelector = {
    AppClock.sched(0, {~utteranceSelectors[1][~cat].background_(Color.red)});
    AppClock.sched(1, {~utteranceSelectors[1][~cat].background_(Color.white)});
};


// adds incomming audio samples to the selectors and the ~samplePaths-dictionary
~addNewSample = {
    |pathString|
    var pathToFile, itemlist, itemName, samplesList, indexToRemove, currentValue;
    pathToFile = PathName(pathString ++ "/00_utterance.wav");
    itemName = pathToFile.folderName;
    itemlist = ~utteranceSelectors[1][~cat].items;
    samplesList = ~samplePaths[~cat];
    // remove last element if itemlist is too long (or the one before if the last one is active) to keep the number of choices fixed. Also make sure that the selected element remains correct and store the paths to the samples in ~samplePaths with the correct index
    AppClock.sched(0, {
        currentValue = ~utteranceSelectors[1][~cat].value;
        if (itemlist.size >= itemlist.maxSize,
            {
                if (currentValue == (itemlist.maxSize - 1),
                    {indexToRemove = (itemlist.maxSize - 2);},
                    {
                        indexToRemove = (itemlist.maxSize - 1);
                        currentValue = currentValue + 1;
                    }
                );
                itemlist.removeAt(indexToRemove);
                samplesList.removeAt(indexToRemove);
            },
            {currentValue = currentValue+1};
        );
        itemlist.addFirst(itemName);
        ~utteranceSelectors[1][~cat].items_(itemlist);
        ~utteranceSelectors[1][~cat].value_(currentValue);

        samplesList.addFirst(pathToFile);
        ~samplePaths[~cat] = samplesList;
    });
};


// a helper function to load all samples in the provided path
~addSample = {
    |pathSymbol|
    var path = pathSymbol.asString, samples = Dictionary.new;
    samples.add(
        PathName(path).fileName.asSymbol->
        Array.fill(
            PathName(path).entries.size,
            {
                |i|
                PathName(path).entries[i].postln;
                Buffer.read(s, PathName(path).entries[i].fullPath);
            }
        )
    );
    "updated Sample".postln;
    samples;
};

~runFx = {

    ~fx = (
        \rev: ~reverb.playfx(FxPatch(#[ \busfx, \vrb1 ], ~patches[\reverb2])),
        \ring : ~ringmod.playfx(FxPatch(#[\busfx, \ring1], ~patches[\ring])),
        \chor : ~chorus.playfx(FxPatch(#[\busfx, \chorus], ~patches[\chorus])),
        \mst_lim : ~master.playfx(FxPatch(#[\busfx, \limiter], ~patches[\limiter])),
        \ch1_cmp : ~ch1.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])),
        \ch2_cmp : ~ch2.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])),
        \ch3_cmp : ~ch3.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])),
        \ch4_cmp :~ch4.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])),
        \ch5_cmp : ~ch5.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])), //dieser macht den *** ERROR: SynthDef companderd#7HVwu not found
        \utt_cmp : ~utt.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander])),
        \perc_cmp : ~perc.playfx(FxPatch(#[\busfx, \companderd], ~patches[\companderd_beat])),
        \bass_cmp : ~bass.playfx(FxPatch(#[\busfx, \companderd], ~patches[\compander]))
    )
};

~bypass = {
    |key, on|
    if (on, {~fx[key].synth.run(false)}, {~fx[key].synth.run(true);})
};

~activateFaders = {
    var i = 0;
    ~sends.keys.asList.sort.do({
        |snd|
        if ("vrb".matchRegexp(snd.asString), {
            //("found  " ++ snd).postln;
            ~activateReverb.(snd, i, 89 );
            i = i+1;
        })
    });
    ~fadingSynths.do{|chan, idx| ~activatePitch.(chan, idx, 97)};
    ~faderControl.do{|chan, it| ~activateVolume.(chan, it)};
};

~checkFadeVols = {
    var allVolumes=List.new;
    ~fadingSynths.do{
        |n|
        allVolumes.add(~melos.amps[n]);
    };
    //"FadeVolumes Sum    %".format(allVolumes.sum).postln;
    ~fadeVols = allVolumes.sum;
    allVolumes.sum;
};

~addVolume = {
    |cat|
    var c, editVol, allVolumes=List.new;
    editVol =  ~melos[\amps][cat];
    //postf("\n updating volume of %  from %  add %   max %   thres % \n ", cat, editVol, add, max, thres );
    c = case
    {editVol <= ~volThres}{ ~melos[\amps][cat]= editVol + (~volPlus * ~addFac) }// double enhance when pattern is very quiet
    {(editVol<= ~volMax) && (editVol>= ~volThres)}{ ~melos[\amps][cat] = editVol + ~volPlus}
    {editVol >= ~volMax}{  ~melos[\amps][cat] = ~volMax}
    {true}{"end of addVolume".postln};
    //postf("new vol of %  is % \n", cat, ~fadePatterns[cat][\vol]);
    defer{var index, height, text;
        //"updating mc: index % height  % text  %".format(index, height, text);
        index = ~fadingSynths.detectIndex({|it, i| it == cat});
        height = ~melos[\amps][cat].linlin(0.001, 1.0, 10, 360);
        text =  ~melos[\amps][cat].trunc(0.001).asString;
        ~mcTrack[1][index].resizeTo(100, height);
        ~mcTrack[1][index].string = text;
    }
};

~continuousFadeOut = {
    |listOfPatterns|
    //TODO wann schaltet sich das ein und evtl auch wieder ab?
    listOfPatterns.do({
        |cat|
        var vol, c;
        vol = ~melos[\amps][cat];
        //postf("\nthe vol %  of the pattern   %\n", vol, cat);
        c = case
        {(vol > ~volMin) && (vol >= ~volThres)} {~melos[\amps][cat] = vol - (~volStep * ~subFac)} // loud volumes decrease fast
        {(vol <= ~volThres) && (vol >= ~volMin)} {~melos[\amps][cat]= vol - (~volStep * ~subFac)} // middle volumes decrease slower
        {vol <= ~volMin} {~melos[\amps][cat] = ~volMin}
        {true}{"end of fade cases"};
        Pbindef(cat, \amp, ~melos[\amps][cat]);
        defer{var index, height, text;
            //"updating mc: index % height  % text  %".format(index, height, text);
            index = ~fadingSynths.detectIndex({|it, i| it == cat});
            height = ~melos[\amps][cat].linlin(0.001, 1.0, 10, 360);
            text = ~melos[\amps][cat].trunc(0.001).asString;
            ~mcTrack[1][index].resizeTo(100, height);
            ~mcTrack[1][index].string = text;
        }
    });
};

~mum = {
    |cat, timestamps, waitTime|
    var key = ("mumble_" ++ cat.asString).asSymbol;
    [cat, timestamps, waitTime, key].postln;
    Routine({
        timestamps.do({
            |gr|
            var harm = ((gr.floor)%60) / 12;
            var buf = ~buffers[key].values.choose.normalize;
            harm = harm.lincurve(0, 5, -12, 12);
            //"harmonizing % to %".format(gr, harm).postln;

            Synth(\brPhsr, [\buf, buf, \harm, harm, \start, 0, \end, buf.numFrames, \out, ~utt]);
            waitTime.wait;
        })
    }).play;
};


~setGlobal = {
    var lastMinute=0, elapsed=0;
    if (~upm >= ~upmMax, {
        var cat, buf;
        "upmMax reached upm %, switching to Mumbles".format(~upm).postln;
        Pbindef.all.do({|p| p.stop});
        cat = ~categorySymbols[~cat];
        ~mum.(cat, ~uttsPerMinute[cat], 0.25);
    },{
        "below upm %, switching to Patterns".format(~upm).postln;

        ~allocate.(~categorySymbols[~cat], ~uttDict[~cat]);

    });
    c = case
    {~totalUtts == 90} {
        ~rain = Synth(\sampSt, [\buf, ~buffers[\atmos][\rain], \atk, 20, \sus, 30, \rls, 10,  \amp, 0.9, \thr, 0.5, \cgain, 1]);
    }
    {~totalUtts == 55}{
        ~pott = Synth(\sampSt, [\buf, ~buffers[\atmos][\dickerpott], \atk, 12, \sus, 30, \rls, 30,  \amp, 0.25, \thr, 0.5, \cgain, 1]);

    }
    {~totalUtts == 30} {
        ~birds.set(\rate, 0.7)
    }
    {~totalUtts == 27} {
        ~birds.set(\rate, 1.5)
    }
    {~totalUtts == 25}{
        //bird Atmosphere
        ~birds = Synth(\sampSt, [\buf, ~buffers[\atmos][\birds], \atk, 10, \sus, 25, \rls, 10, \amp, 0.9, \thr, 0.5, \cgain, 1.5]);
    }
    {~totalUtts == 5}{
        //bird Atmosphere
        ~birds = Synth(\sampSt, [\buf, ~buffers[\atmos][\birds], \atk, 20, \sus, 10, \rls, 15,  \amp, 0.9, \thr, 0.5, \cgain, 4]);
        "10 utts".postln;
    }
    {(~totalUtts > 1) && (~totalUtts < 10) }{
    }
    {(~totalUtts == 1)}{
        //"first utt".postln;
        ~runFx.();
        ~activateFaders.();
        //~fadingSynths.do{|name| Pbindef(name).play(~t, quant:0)};
        Pdefn(\melody).play(~t, quant:0);
        //[\kik02, \hh01, \bass].do{|n| Pbindef(n).play(~t, quant:4)};

        //init continuous Fadeout Function
        ~t.schedAbs(~t.nextTimeOnGrid, {
            if(~checkFadeVols.() >= ~thresCont, {
                ~continuousFadeOut.value(~fadingSynths); 1},
            {"not fading: fadeVols = %".format(~fadeVols).postln});

        });
        //initiate CategoriesPerMinute Counter EINMALIG, das funktioniert UNABHÄNGIG von einkommenden Utts
        ~t.schedAbs(~t.nextTimeOnGrid, {
            var upm=0;
            //"after % ".format((~t.beats/~t.tempo)).postln;
            if ((~t.beats/~t.tempo) >= ~lastMinute, {
                lastMinute = (~t.beats/~t.tempo) -  ;
                //scan all timestamp lists and only keep timestamps that are larger than lastMinute
                ~uttsPerMinute.keysValuesDo({|k,v|
                    v = v.select({|ts| ts >= lastMinute});
                    //"new opm % in %".format(v.size, k).postln;
                    ~uttsPerMinute[k] = v;
                });
                1;
            });
            ~uttsPerMinute.values.do({|l| upm = upm + l.size});
            ~upm = upm; // update ~upm
            "updated upm %".format(upm).postln;
            1;
        });
    }
    {true} {"end of global settings".postln};

    //add new timestamp in respective category list
    ~uttsPerMinute[~categorySymbols[~cat]].add((~t.beats/~t.tempo));
};

~mock = {
    var cat = ~categories.choose,
    m = NetAddr("127.0.0.1", 57120);
    m.sendMsg("/interpreter_input", ~story[~storyIndex % ~story.size], cat, ~resourcePath ++ "samples/lec01/");
    ~storyIndex = ~storyIndex +1;
};
