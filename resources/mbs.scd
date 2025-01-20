// eine funktion für model grains
// funktioniert nicht mit synthdefs,


~vbapDissent = { |azi = 0, ele = 0, spr = 0,
    baseFreq=80, baseAmp=0.5, baseRing= 0.1
    trg=4, punch=0.1, dec=1
    freqScale=1, decayScale=1,  amp= 0.3|
    var exc, sig, env, trig, freqMod;
    var freqs = Array.fill(4, {|n| baseFreq * (n+1)});
    var amps = Array.fill(4, {|n| baseAmp * [0.5, 0.24, 0.14, 0.423]});
    var rings = Array.fill(4, {|n| baseRing * (n+1)});
    //env = Env.perc(0.01, 4).kr(2);
    trig = Dust.kr(trg);
    freqMod = TRand.kr( 1, 5, trig)  ;
    exc = WhiteNoise.ar(punch) * Decay2.kr(trig, 0.001, dec);
    sig = DynKlank.ar(`[
        freqs,
        amps.ampdb.normalizeSum,
        rings
    ], exc, freqScale, 0, decayScale);
    sig = sig * amp ;
    VBAP.ar(4, sig, ~panbuf, azi, ele, spr);
};

// PanAz mit 4 Lautsprechern
~modelKlank = {
    |cat|
    var dur, pan, freqs;
    dur = rrand(1, 4);
    case
    {cat == \dis}{pan = 0.0; dur = 3; freqs = [146, 293, 370, 587, 1109]}
    {cat == \pr}{pan = 0.25; dur = 4; freqs = [130, 261, 523, 1046, 2093]}
    {cat == \con}{pan = 0.5; dur = 3; freqs = [98, 392, 493, 783, 1174]}
    {cat == \lec}{pan = 1.0; dur = 2; freqs = [329, 659, 987, 1397, 2637]}
    {cat == \ins}{pan = 1.5; dur = 2.2; freqs = [554, 698, 830, 987, 1108]}
    {true}{"no more panAz".postln};

    freqs.do({
        |base, i|

        Synth(\modelGrains, [\freq, Array.fill(4, {exprand(base, base * 2)}),
            \ring, [0.2, 0.1, 0.5, 0.1] * 5 ,
            \levels, rrand(0.1, 0.5) !4,
            \azi, pan, \level, 0.5,
            \dec, dur/3, \trg, rrand(2, 10),
            \rls, dur, \punch, rrand(0.08, 0.3), \amp, rrand(0.02, 0.4),
            \decayScale, 2 - (i* rrand(0.01, 0.15)), \freqScale, 1 - (i * rrand(0.2, 0.5)),
            \ffreq, 4500 - (i* rrand(110, 330)), \rq, 0.2,
            \out, 0
        ])
    })
};
(
/*{
    PanAz.ar(
        numChans: 4,
        in: ClipNoise.ar(0.1),
        pos: LFSaw.kr(0.2).range(-1, 1),
        level: 0.5,
        width: 1,
        orientation: 0.5
    );
}.scope;

x = {PanAz.ar(4, Dust.ar(10), MouseX.kr(0,1).poll, 1, 2, 0.0)}.play;
x.free;*/
);









~aziangles = Routine({
   loop{
        (-180, -175 .. 180).do({
            |ang|
             x.set(\azi, ang);
            0.11.wait;
        })
    }
});
/*
// circle Ramp
(
var speakerList, x=200, y=150, targx=200, targy=150;
var atorad = (2pi) / 360, rtoang = 360.0 / (2pi);
var targRotate, actRotate, targPoint, actPoint;
var maxShiftPerFrame = 20, frameInterval = 0.01;
var resched = false, count = 0;
var panBus, widthBus, recButton;
var panWidth = 30;
var a, b, c, e;
var sig;

maxShiftPerFrame = maxShiftPerFrame * atorad;
actPoint = Point(x, y) - Point(200, 200);
panBus = Bus.control;
widthBus = Bus.control.set(60);

w = Window.new("Quadro Panner", Rect(128, 64, 400, 450)).front;
w.view.background_(Color.grey(0.3));
w.view.decorator = FlowLayout(w.view.bounds);

speakerList = [[-30, "L"], [30, "R"], [-110, "Ls"], [110, "Rs"]];

e = EZSlider.new(w, Rect(380, 20), "Stereo Width", [0, 180].asSpec, {arg ez; widthBus.set(ez.value); w.refresh}, panWidth);
//e.labelView.setProperty(\stringColor,Color.grey(0.8));

c = UserView.new(w, Rect(0, 0, 400, 380));
c.canFocus = false;

c.drawFunc = {
    Color.grey(0.8).set;
    // draw the speaker layout
    Pen.translate(200,200);
    ((actPoint.theta + (0.5pi)).wrap2(pi) * rtoang).round(0.01).asString.drawCenteredIn(Rect.aboutPoint(0@170, 30, 10), GUI.font.new("Arial", 10), Color.grey(0.8));
    Pen.strokeOval(Rect.aboutPoint(0@0, 150, 150));
    Pen.rotate(pi);
    speakerList.do({|spkr|
        Pen.use({
            Pen.rotate(spkr[0] * atorad);
            Pen.moveTo(0@170);
            Pen.strokeRect(r = Rect.aboutPoint(0@170, 30, 10));
            if(spkr[0].abs < 90, {
                Pen.use({
                    Pen.translate(0, 170);
                    Pen.rotate(pi);
                    spkr[1].drawCenteredIn(Rect.aboutPoint(0@0, 30, 10),
                        GUI.font.new("Arial", 10), Color.grey(0.8));
                });
            },{
                spkr[1].drawCenteredIn(r, GUI.font.new("Arial", 10), Color.grey(0.8));
            });
        });
    });

    Pen.moveTo(0@0);

    // draw the pan point
    Pen.rotate(actPoint.theta + 0.5pi);
    targPoint = Point(x, y) - Point(200, 200);
    // trunc to avoid loops due to fp math
    targRotate = (targPoint.theta - actPoint.theta).trunc(1e-15);
    // wrap around
    if (targRotate.abs > pi, {targRotate = (2pi - targRotate.abs) * targRotate.sign.neg});
    actRotate = targRotate.clip2(maxShiftPerFrame).trunc(1e-15);
    actPoint = actPoint.rotate(actRotate);
    Pen.rotate(actRotate);
    Pen.lineTo(0@150);
    Pen.stroke;
    Pen.fillOval(Rect.aboutPoint(0@150, 7, 7));
    Pen.addWedge(0@0, 140, neg(e.value * 0.5) * atorad + 0.5pi, e.value * atorad);
    Pen.stroke;
    Color.grey(0.8).alpha_(0.1).set;
    Pen.addWedge(0@0, 140, neg(e.value * 0.5) * atorad + 0.5pi, e.value * atorad);
    Pen.fill;

    if((actRotate.abs > 0), {AppClock.sched(frameInterval, {w.refresh})}, {count = 0;});
    if(count%4 == 0, {panBus.set((actPoint.theta + (0.5pi)).wrap2(pi) * rtoang)});
};

c.mouseMoveAction_({|v,inx,iny| x = inx; y = iny; w.refresh;});
c.mouseDownAction_({|v,inx,iny| x = inx; y = iny; w.refresh;});


w.refresh;

// VBAP

a = VBAPSpeakerArray.new(2, speakerList.collect(_.first));
b = Buffer.loadCollection(s, a.getSetsAndMatrices;);


SynthDef(\sine, {
    var mem;
    mem = SinOsc.ar([440, 660], 0, Decay2.ar(Impulse.ar([1, 0.9]), 0.1, 0.2));
    Out.ar(\out.kr(~vbapIn), mem);
}).add;

sig = Synth(\sine, [\out,  ~vbapIn]);

SynthDef('VBAP 4 chan', { |azi = 0, ele = 0, spr = 0, panWidth, vbapBuf|
var panned, source;
//source = SinOsc.ar([440, 660], 0, Decay2.ar(Impulse.ar([1, 0.9]), 0.1, 0.2));
    source = In.ar(~vbapIn);
azi = azi.circleRamp;
panned = VBAP.ar(4, source, vbapBuf, [azi - (0.5 * panWidth), azi + (0.5 * panWidth)], ele, spr);
// 'standard' channel order for 5.1
[0, 1, 2, 3].do({arg bus, i; Out.ar(bus, panned[0][i])});
[0, 1, 2, 3].do({arg bus, i; Out.ar(bus, panned[1][i])});

}).play(s, [vbapBuf: b.bufnum, azi: panBus.asMap, width: widthBus.asMap]);

)

*/