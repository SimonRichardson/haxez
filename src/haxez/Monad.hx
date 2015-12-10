package haxez;

import haxez.Applicative;
import haxez.Bind;
import haxez.F0;
import haxez.F1;
import haxez.Functor;
import haxez.T;
import haxez.Util;

interface IMonad<F> extends IApplicative<F> extends IBind<F> {}

class Monad<F> extends Bind<F> implements IMonad<F> {

    public function new() {
        super();
    }

    public function point<A>(a : F0<A>) : _1<F, A> return Util.missing();

    override public function map<A, B>(f : F1<A, B>, fa : _1<F, A>) : _1<F, B> {
        return flatMap(new F1Lift(function(a) {
            return point(new F0Lift(function() return f.apply(a)));
        }), fa);
    }
}