package haxez;

import haxez.Apply;
import haxez.F0;
import haxez.F1;
import haxez.T;
import haxez.Util;

interface IBind<F> extends IApply<F> {

    public function flatMap<A, B>(f : F1<A, _1<F, B>>, fa : _1<F, A>) : _1<F, B>;
}

class Bind<F> extends Apply<F> implements IBind<F> {

    public function new() {
        super();
    }

    override public function ap<A, B>(f : F0<_1<F, F1<A, B>>>, fa : F0<_1<F, A>>) : _1<F, B> {
        return flatMap(new F1Lift(function(x) return map(x, fa.apply())), f.apply());
    }

    public function flatMap<A, B>(f : F1<A, _1<F, B>>, fa : _1<F, A>) : _1<F, B> {
        return Util.missing();
    }
}