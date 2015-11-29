package haxez;

import haxez.Combinators as C;
import haxez.Types;

using haxez.Coyoneda;

enum CoyonedaType<F, A> {
    CoyonedaType(fi : Functor<F>, k : F -> A);
}

abstract Coyoneda<F, A>(CoyonedaType<F, A>) from CoyonedaType<F, A> to CoyonedaType<F, A> {

    inline function new(coy : CoyonedaType<F, A>) {
        this = coy;
    }

    @:noUsing
    public static inline function lift<F, A>(fi : Functor<F>) : Coyoneda<F, A> {
        return CoyonedaType(fi, C.castIdentity());
    }

    public function map<B>(f : A -> B) : Coyoneda<F, B> {
        return switch(this) {
            case CoyonedaType(fi, k): CoyonedaType(fi, C.andThen(k)(f));
        };
    }

    public function lower() : Functor<A> {
        return switch(this) {
            case CoyonedaType(fi, k): fi.map(k);
        };
    }

    @:to
    public function toFunctor() : Functor<A> return new CoyonedaOfFunctor(this);

    @:from
    public static function unsafeFromFunctor<F, A>(a : Functor<F>) : Coyoneda<F, A> {
        return CoyonedaOfFunctor.from(cast a);
    }
}

private class CoyonedaOfFunctor<F, A> {

    private var x : Coyoneda<F, A>;

    public function new(x : Coyoneda<F, A>) this.x = x;

    public static inline function from<F, A>(x : CoyonedaOfFunctor<F, A>) : Coyoneda<F, A> {
        return x.x;
    }

    public function map<B>(f : A -> B) : Functor<B> {
        var m : CoyonedaType<F, A> = this.x;
        var n : Coyoneda<F, B> = switch(m) {
            case CoyonedaType(fi, k): CoyonedaType(fi, C.andThen(k)(f));
        };
        return n;
    }
}