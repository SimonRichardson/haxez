package haxez;

import haxez.Apply;
import haxez.F0;
import haxez.F1;
import haxez.T;
import haxez.Util;

interface IApplicative<F> extends IApply<F> {

    public function point<A>(a : F0<A>) : _1<F, A>;
}

class Applicative<F> extends Apply<F> implements IApplicative<F> {

    public function new() {
        super();
    }

    override public function map<A, B>(f : F1<A, B>, fa : _1<F, A>) : _1<F, B> {
        return ap(
            new F0Lift(function() return point(new F0Lift(function() return f))), 
            new F0Lift(function() return fa)
        );
    }

    public function point<A>(a : F0<A>) : _1<F, A> return Util.missing();
}