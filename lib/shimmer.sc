FxShimmer : FxBase {

    *new { 
        var ret = super.newCopyArgs(nil, \none, (
            freq: 1000,
            res: 0.1,
            gain: 1.0,
            type: 0,
            noiseLevel: 0.0003,
            room: 0.5,
            damp: 0.5,
            windowSize: 0.5,
            pitchRatio: 2.0,
            pitchDispersion: 0.0,
            timeDispersion: 0.02,
            shimmer: 0.0,
        ), nil, 0.5);
        ^ret;
    }

    *initClass {
        FxSetup.register(this.new);
    }

    subPath {
        ^"/fx_shimmer";
    }  

    symbol {
        ^\fxShimmer;
    }

    addSynthdefs {
        SynthDef(\fxShimmer, {|inBus, outBus|
            var dry, wet, shifted, fbk, mix;
            dry = DFM1.ar(In.ar(inBus, 2), \freq.kr(1000), \res.kr(0.1), 1, \type.kr(0), \noiseLevel.kr(0.0003)).tanh;
            fbk = LocalIn.ar(2);
            mix = (dry + fbk) * -6.dbamp;
            wet = FreeVerb2.ar(mix[0], mix[1], 1, \room.kr(0.8), \damp.kr(0.7), 6.dbamp);
            wet = LeakDC.ar(wet);
            shifted = PitchShift.ar(wet, 0.5, \pitchRatio.kr(2.0), \pitchDispersion.kr(0.0), \timeDispersion.kr(0.02));
            LocalOut.ar(shifted * \shimmer.kr(0.0));
            Out.ar(outBus, wet);
        }).add;
    }

}