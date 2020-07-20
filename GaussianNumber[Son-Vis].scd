//GaussianNumber

(
~gss = gauss(5, 5).round(1);
if (~gss.isNegative, {~gss = ~gss * (-1)});
~gss.postln;
)


//CONNECTION/////////////////////////MAKE_SURE_THE_IP_IS_CORRECT!!\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
~n = NetAddr("192.168.1.17", 12000);

//WAVETABLE
(
b = Signal.newClear(128);
b.waveFill({|num| gauss(0.0, num).postln});//Gaussian_RandomNumber
b = b.asWavetable;//^^^
//b.plot;//PowerOf2__^^^
b = Buffer.loadCollection(s, b); //-->ToABuffer
);

//Melodic_Example
(
//SynthDef--Melody--
SynthDef("qp", {
    |freq = 444, amp = 0.5, pan = 0|
    var sig, env, out, temp, sum;
    sum = 0;
    10.do{
        temp = LFTri.ar(freq * LFNoise1.kr(1).range(0.99, 1.01), Rand(0.444, 0.666), Rand(0.555, 0.666));
        sum = sum + temp * 0.666;
    };
    sig = sum;
    sig = FreeVerb.ar(sig, 0.33, 0.8, 0.1);
    env = Env.perc(1, 3).kr(doneAction:2);
    out = sig * env * amp ;
    Out.ar(0, Pan2.ar(out, pan))
}).add;

//SynthDef--Ambience--
SynthDef("wqw", {
    |freq = 444, amp = 0.5, pan = 0|
    var sig, env, out, sum, temp;
    sum = 0;
    5.do{
        temp = Osc.ar(b, freq * rand(0.99, 1.01)) * VarSaw.kr(freq/8 * rand(0.99, 1.01));
    sum = sum + temp;
    };
    sig = FreeVerb.ar(sum, 0.33, 0.8);
    sig = Resonz.ar(sig, 666, 1);
    env = Env.perc(1, 2).kr(doneAction:2);
    out = sig * env * amp;
    Out.ar(0, Pan2.ar(out, pan))
}).add;

{
    ~counter = 0;
    10.do{

        //Pdef-Stop_Every_4Sec
        Pdef(\hej).stop;
        Pdef(\hej0).stop;
        //RandomNUM_Generator_for_SCALE_&&_OSC-Send

~send = [

~gss = gauss(5, 5).round(1);
    if (~gss.value < 0, {~gss = ~gss * (-1)}, {~gss}),

~gss = gauss(5, 5).round(1);
    if (~gss.value < 0, {~gss = ~gss * (-1)}, {~gss}),

~gss = gauss(5, 5).round(1);
    if (~gss.value < 0, {~gss = ~gss * (-1)}, {~gss})
        ];

~send.postln;


        //Gendy-FX
        {
            1.do{
                if (~counter < 10 && ~counter > 5, {
                    if (~send[0] > 10, {
                        var js;
                        js = CombC.ar(WhiteNoise.ar(1) * Impulse.kr(4), 0.05, 0.15, 1);
                        //js = FreeVerb.ar(js, 0.666, 0.1, 0.9);
                        js = GVerb.ar(js, 1) * 0.3;
                        js = js * Env.perc(1, 2).kr(doneAction:2);
                        Out.ar(0, Pan2.ar(js * 0.3 , LFNoise1.kr(~send.choose.value)))
                    }.play
                    );
                })
            }
        }.fork;

    //Melody
       Pdef(\hej,
        Pbind(
            \instrument,
            \qp,
            \dur, Prand([0.5, 1, 0.25], inf),
            \scale, Scale.ionian,
            \degree, Prand([~send.choose.value, ~send.choose.value, ~send.choose.value], inf),
                \amp, Pwhite(0.222, 0.333, inf) * 0.443556 + (~send.choose.value /   12* 0.02),
            \octave, [4,5],
                \pan, ~send.choose.value * [-1, 1].choose / 20
        )).play;

    //Ambience
         Pdef(\hej0,
        Pbind(
            \instrument,
            \wqw,
            \dur, Prand([0.5, 1], inf),
            \scale, Scale.ionian,
            \degree, Prand([~send.choose.value, ~send.choose.value, ~send.choose.value], inf),
            \amp, Pwhite(0.222, 0.333, inf) * 0.466 + (~send.choose.value /   12* 0.02),
            \octave, [5],
                \pan, ~send.choose.value * [-1, 1].choose / 20
)).play;

    //Percussion
    if (~send[0] > 6, {
        (
            {
                var js;
                js = BPF.ar(ClipNoise.ar(0.366), 2333 * rrand(0.8, 1.5), 0.3, 10) * Impulse.kr([1, 2, 3, 4].choose);
                    js = CombC.ar(js, 0.2, 0.1, 3);
                js = js * Env.perc(0.01, 6).kr(doneAction:2);
                Out.ar(0, Pan2.ar(js * 0.666, -0.666))
            }.play
        )
    });

    //Filtered_Noise_SoundFX

        if (~send[0] > 8, {

            {
                var js;
                js = BPF.ar(PinkNoise.ar(1), Line.kr(Rand(1111, 3333), Rand(4444, 11111) , 3,  1, doneAction:0), 0.2);
                js = Gendy1.ar(~send.choose.value/10, ~send.choose.value/10, ~send.choose.value/5) * 0.5;
                js = FreeVerb.ar(js, 0.666, 0.9, 0.9);
                js = js * Env.perc(1, 6).kr(doneAction:2);
                Out.ar(0, Pan2.ar(js * 0.666, 0.9))
            }.play
        });



    //NotZero
    if( ~send[0] > 0, {
        ~n.sendMsg('gain', ~send[0]);
    });
    //If-->Zero
    if(~send[0] == 0, {
        ~n.sendMsg('gain', ~send[1]);
      if(~send[1] == 0, {
        ~n.sendMsg('gain', ~send[2]);
        });
        if(~send[2] == 0, {
        ~n.sendMsg('gain', [2, 4, 5, 7, 9, 11, 12].choose);
        })
    });

~send;
4.wait;

        ~counter = ~counter + 1;
        };



Pdef(\hej).stop;
Pdef(\hej0).stop;
 ~n.sendMsg('gain', 0);

}.fork
)
