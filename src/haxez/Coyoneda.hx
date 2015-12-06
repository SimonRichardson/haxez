package haxez;

import haxez.F1;
import haxez.Functor;
import haxez.T;

enum CoyonedaNative<F, A> {
    Coyoneda(fi : _1<F, Dynamic>, k : F1<Dynamic, A>);
}

class CoyonedaNatives {

    inline public static function fromCoyoneda<F, A>(x : AbstractCoyoneda<F, A>) : CoyonedaNative<F, A> {
        return CoyonedaNative.Coyoneda(x.fi, x.k);
    }

    inline public static function toCoyoneda<F, A>(x : CoyonedaNative<F, A>) : AbstractCoyoneda<F, A> {
        return switch(x) {
            case Coyoneda(fi, k): new AbstractCoyoneda(fi, k);
        };
    }
}

@:allow(haxez.CoyonedaNatives.fromCoyoneda)
class AbstractCoyoneda<F, A> implements _1<Coyoneda<F, Dynamic>, A> {

    private var fi : _1<F, Dynamic>;
    private var k : F1<Dynamic, A>;

    public function new(fi : _1<F, Dynamic>, k : F1<Dynamic, A>) {
        this.fi = fi;
        this.k = k;
    }

    inline public static function functor<G>() : Functor<Coyoneda<G, Dynamic>> {
        return new CoyonedaOfFunctor();
    }

    inline public static function lift<S, B>(s : _1<S, B>) : Coyoneda<S, B> {
        return new AbstractCoyoneda(s, F1_.id());
    }

    public function map<B>(f : F1<A, B>) : AbstractCoyoneda<F, B> {
        return new AbstractCoyoneda(fi, k.andThen(cast f));
    }

    public function run(f : Functor<F>) : _1<F, A> return f.map(this.k, this.fi);

    public function with<X, Y>(f : F2<_1<F, X>, F1<X, A>>) : Y {
        var x : _1<F, X> = cast fi;
        var y : F1<X, A> = cast k;
        return f.apply(x, y);
    }
}

abstract Coyoneda<F, A>(AbstractCoyoneda<F, A>) from AbstractCoyoneda<F, A> to AbstractCoyoneda<F, A> {

    inline function new(x : AbstractCoyoneda<F, A>) this = x;

    inline public static function functor<G>() : Functor<Coyoneda<G, Dynamic>> {
        return AbstractCoyoneda.functor();
    }

    inline public static function lift<S, B>(s : _1<S, B>) : Coyoneda<S, B> {
        return AbstractCoyoneda.lift(s);
    }

    inline public function map<B>(f : F1<A, B>) : Coyoneda<F, B> {
        var x : AbstractCoyoneda<F, A> = this;
        return x.map(f);
    }

    inline public function run(f : Functor<F>) : _1<F, A> {
        var x : AbstractCoyoneda<F, A> = this;
        return x.run(f);
    }

    inline public function with<X, Y>(f : F2<_1<F, X>, F1<X, A>>) : Y {
        var x : AbstractCoyoneda<F, A> = this;
        return x.with(f);
    }

    @:to
    inline public function toCoyonedaNative() : CoyonedaNative<F, A> return CoyonedaNatives.fromCoyoneda(this);

    @:from
    inline public static function fromCoyonedaNative<F, A>(x : CoyonedaNative<F, A>) : Coyoneda<F, A> {
        return CoyonedaNatives.toCoyoneda(x);
    }
}

class CoyonedaOfFunctor<G> implements Functor<Coyoneda<G, Dynamic>> {

    public function new() {}

    public function map<A, B>(f : F1<A, B>, fa : _1<Coyoneda<G, Dynamic>, A>) : _1<Coyoneda<G, Dynamic>, B> {
        var x : AbstractCoyoneda<Coyoneda<G, Dynamic>, A> = cast fa;
        return cast x.map(f);
    }
}