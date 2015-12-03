package haxez;

import haxez.T;

interface F1<A, B> {

    public function apply(a : A) : B;

    public function andThen<C>(f : F1_<B, C>) : F1<A, C>;

    public function map<C>(f : F1<B, C>) : F1<A, C>;
}

class F1_<A, B> implements F1<A, B> {

    private var f : F1<A, B>;

    public function new(f : F1<A, B>) {
        this.f = f;
    }

    inline public static function id<A, B>() : F1<A, B> { 
        return new F1_<A, B>(new F1Lift<A, B>(function(a) return cast a));
    }

    inline public static function lift<A, B>(f : A -> B) : F1<A, B> {
        return new F1_<A, B>(new F1Lift<A, B>(f));
    }

    inline public static function constant<X, Y>(y : Y) : F1<X, Y> {
        return new F1_(new F1Lift(function(x) return y));
    }

    inline public static function narrow<A, B>(f : _1<F1<A, Dynamic>, B>) : F1<A, B> {
        return cast f;
    }

    public function andThen<C>(f : F1<B, C>) : F1<A, C> return map(f);

    public function contramap<C>(f : F1<C, A>) : F1<C, B> {
        return f.andThen(this);
    }

    public function flatMap<C>(f : F1<B, F1<A, C>>) : F1<A, C> {
        return new F1Lift(function(a : A) {
            return f.apply(apply(a)).apply(a);
        });
    }

    public function map<C>(f : F1<B, C>) : F1<A, C> {
        return new F1Lift(function(a) return f.apply(apply(a)));
    }

    public function apply(a : A) : B return f.apply(a);
}

class F1Lift<A, B> extends F1_<A, B> {

    private var g : A -> B;

    public function new(f : A -> B) {
        this.g = f;
        super(this);
    }

    override public function apply(a : A) : B return g(a);
}
