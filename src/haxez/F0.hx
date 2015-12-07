package haxez;

import haxez.F1;
import haxez.Functor;
import haxez.T;

class F0z {}

interface F0<A> extends _1<F0z, A> {

    public function apply() : A;

    public function map<B>(f : F1<A, B>) : F0<B>;

    public function flatMap<B>(f : F1<A, F0<B>>) : F0<B>;
}

class F0_<A> implements _1<F0z, A> implements F0<A> {

    private var f : F0<A>;

    public function new(f : F0<A>) {
        this.f = f;
    }

    inline public static function lift<A>(f : Void -> A) : F0_<A> {
        return new F0_<A>(new F0Lift<A>(f));
    }

    inline public static function functor() : IFunctor<F0z> return new F0OfFunctor();

    public function map<B>(f : F1<A, B>) : F0<B> {
        return new F0Lift(function() return f.apply(this.apply()));
    }

    public function flatMap<B>(f : F1<A, F0<B>>) : F0<B> {
        return new F0Lift(function() return f.apply(this.apply()).apply());
    }

    public function apply() : A return f.apply();
}

private class F0OfFunctor implements IFunctor<F0z> {

    public function new() {}

    public function map<A, B>(f : F1<A, B>, fa : _1<F0z, A>) : F0<B> {
        var x : F0_<A> = cast fa;
        return x.map(f);
    }
}

class F0Lift<A> extends F0_<A> {

    private var g : Void -> A;

    public function new(f : Void -> A) {
        this.g = f;
        super(this);
    }

    override public function apply() : A return g();
}