package haxez;

import haxez.Combinators as C;
import haxez.Types;

using haxez.Coyoneda;
using haxez.Either;

enum FreeType<T> {
    Return(x : T);
    Suspend(x : T);
    Chain<B>(x : T, f : T -> Free<B>);
}
typedef FreeCata<T, B, C> = {
    function Return(x : T) : C;
    function Suspend(x : T) : C;
    function Chain(x : Free<T>, f : T -> Free<B>) : C;
}

abstract Free<T>(FreeType<T>) from FreeType<T> to FreeType<T> {

    inline function new(fre : FreeType<T>) {
        this = fre;
    }

    @:noUsing
    public static inline function lift<T>(v : T) : Free<T> return Return(v);

    @:noUsing
    public static inline function liftF<T>(v : Functor<T>) : Free<T> {
        return Suspend(v.map(function(a) return Return(a)));
    }

    @:noUsing
    public static inline function liftFC<T>(c : Functor<T>) : Free<T> {
        return Free.liftF(Coyoneda.lift(c));
    }

    public static function runFC<T, A, B>(m : Free<T>, f : A -> B, p : Class<Pointed<B>>) : B {
        return m.foldMap(p, function(coyo) return f(coyo.k()).map(coyo.fi()));
    }

    public function of(v : T) : Free<T> return Free.lift(v);

    public function cata<B, C>(cat : FreeCata<T, B, C>) : C {
        return switch(this) {
            case Return(v): cat.Return(v);
            case Suspend(v): cat.Suspend(v);
            case Chain(v, f): cat.Chain(v, f);
        };
    }

    public function chain<A>(f : T -> Free<A>) : Free<A> {
        var g = function(_) : Free<A> return Chain(this, f);
        return this.cata({
            Return: g,
            Suspend: g,
            Chain: function(x, g) {
                return Chain(x, function(y) {
                    return Chain(g(y), f);
                });
            }
        });
    }

    public function map<A>(f : T -> A) : Free<A> {
        return this.chain(function(x) return Return(f(x)));
    }

    public function andThen<A>(x : Free<A>) : Free<A> {
        return this.chain(function(_) return x);
    }

    public function fold<A, B>(f : A -> B, g : T -> B) : B {
        return this.resume().fold(f, g);
    }

    public function foldMap<A>(p : Class<Pointed<B>>, f : A -> Free<B>) : B {
        return this.resume().cata({
            Left: function(x) {
                return f(x).chain(function(y) {
                    return y.foldMap(p, f);
                });
            Right: function(x) return p.of(x);
        });
    }

    public function resume<L, R>() : Either<L, R> {
        return this.cata({
            Return: function(x) return Either.Right(x),
            Suspend: function(x) return Either.Left(x),
            Chain: function(x, f) {
                return x.cata({
                    Return: function(y) return f(y).resume();
                    Suspend: function(y) {
                        return Left(y.map(function(z) return z.chain(f)));
                    },
                    Chain: function(y, g) {
                        return y.chain(function(z) return g(z).chain(f)).resume();
                    }
                });
            }
        });
    }
}
