package haxez;

import haxez.Combinators as C;
import haxez.Types;

using haxez.Coyoneda;
using haxez.Either;
using haxez.Free;

enum FreeType<T> {
    Return(x : T);
    Suspend(x : Free<T>);
    Chain<A>(x : Free<T>, f : T -> Free<A>);
}
typedef FreeCata<T, B> = {
    function Return(x : T) : B;
    function Suspend(x : Free<T>) : B;
    function Chain<A>(x : Free<T>, f : T -> Free<A>) : B;
}

abstract Free<T>(FreeType<T>) from FreeType<T> to FreeType<T> {

    inline function new(fre : FreeType<T>) {
        this = fre;
    }

    @:noUsing
    public static inline function lift<T>(v : T) : Free<T> return Return(v);

    @:noUsing
    public static inline function liftF<T>(v : Functor<T>) : Free<T> {
        return cast Suspend(v.map(function(a) return Return(a)));
    }

    @:noUsing
    public static inline function liftFC<T>(c : Functor<T>) : Free<T> {
        return Free.liftF(Coyoneda.lift(c));
    }

    public static function runFC<T, A, B>(m : Free<T>, f : A -> Functor<B>, p : T -> B) : B {
        return m.foldMap(p, function(coyo) return f(coyo.k()).map(coyo.fi()));
    }

    public function of(v : T) : Free<T> return Free.lift(v);

    public function cata<B>(cat : FreeCata<T, B>) : B {
        return switch(this) {
            case Return(v): cat.Return(v);
            case Suspend(v): cat.Suspend(v);
            case Chain(v, f): cat.Chain(v, f);
        };
    }

    public function chain<A>(f : T -> Free<A>) : Free<A> {
        return cast this.cata({
            Return: function(x) return Chain(this, f),
            Suspend: function(x) return Chain(this, f),
            Chain: function(x, g) {
                return Chain(x, function(y) {
                    return Chain(cast g(y), f);
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

    public function foldMap<A, B>(p : T -> B, f : A -> Free<B>) : B {
        return cast this.resume().cata({
            Left: function(x) {
                return f(x).chain(function(y) {
                    var a : Free<T> = cast y;
                    return cast a.foldMap(p, f);
                });
            },
            Right: function(x) return cast p(x)
        });
    }

    public function resume<L, R>() : Either<L, R> {
        return cast this.cata({
            Return: function(x) return Right(x),
            Suspend: function(x) return Left(x),
            Chain: function(x, f) {
                return cast x.cata({
                    Return: function(y) return f(y).resume(),
                    Suspend: function(y) {
                        return Left(y.map(function(z) {
                            var a : Free<T> = cast z;
                            return a.chain(f);
                        }));
                    },
                    Chain: function(y, g) {
                        return y.chain(function(z) {
                            return g(z).chain(cast f);
                        }).resume();
                    }
                });
            }
        });
    }

    @:to
    public function toFunctor() : Functor<T> return new FreeOfFunctor(this);

    @:from
    public static function unsafeFromFunctor<T>(a : Functor<T>) : Free<T> {
        return FreeOfFunctor.from(cast a);
    }

    @:to
    public function toMonad() : Monad<T> return new FreeOfMonad(this);

    @:from
    public static function unsafeFromMonad<T>(a : Monad<T>) : Free<T> return FreeOfMonad.from(cast a);
}

private class FreeOfFunctor<F> {

    private var x : Free<F>;

    public function new(x : Free<F>) this.x = x;

    public static inline function from<F>(x : FreeOfFunctor<F>) : Free<F> {
        return x.x;
    }

    public function map<A>(f : F -> A) : Functor<A> {
        var m : FreeType<A> = this.x.map(f);
        var n : Free<A> = m;
        return n;
    }
}

private class FreeOfMonad<T> {

    private var x : Free<T>;

    public function new(x : Free<T>) this.x = x;

    public static inline function from<T>(x : FreeOfMonad<T>) : Free<T> return x.x;

    public function of(v : T) : Monad<T> return Free.lift(v);

    public function map<A>(f : T -> A) : Monad<A> {
        var m : FreeType<A> = this.x.map(f);
        var n : Free<A> = m;
        return n;
    }

    public function chain<A>(f : T -> Monad<A>) : Monad<A> {
        var m : FreeType<A> = this.x.chain(cast f);
        var n : Free<A> = m;
        return n;
    }
}