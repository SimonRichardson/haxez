package haxez;

import haxez.Combinators as C;
import haxez.Types;

using haxez.Either;

typedef EitherType<A, B> = haxe.ds.Either<A, B>;
typedef EitherCata<A, B, C> = {
    function Left(l : A) : C;
    function Right(r : B) : C;
}

abstract Either<L, R>(EitherType<L, R>) from EitherType<L, R> to EitherType<L, R> {

    inline function new(eit : EitherType<L, R>) {
        this = eit;
    }

    @:noUsing
    public static inline function of_<L, R>(v : R) : Either<L, R> return Right(v);

    public function of(v : R) : Either<L, R> return Either.of_(v);

    public function cata<T>(cat : EitherCata<L, R, T>) : T {
        return switch(this) {
            case Left(v): cat.Left(v);
            case Right(v): cat.Right(v);
        };
    }

    public inline function fold<T>(f : L -> T, g : R -> T) : T {
        return this.cata({
            Left: f,
            Right: g
        });
    }

    public inline function chain<T>(f : R -> Either<L, T>) : Either<L, T> {
        return this.fold(
            function(x : L) : Either<L, T> return Left(x),
            f
        );
    }

    public inline function map<T>(f : R -> T) : Either<L, T> {
        return this.chain(function(a : R) : Either<L, T> {
            return Either.of_(f(a));
        });
    }

    public inline function ap<T>(a : Either<L, R>) : Either<L, T> {
        var eit : Either<L, R -> T> = cast this;
        return eit.chain(function(f : R -> T) : Either<L, T> {
            return a.map(f);
        });
    }

    @:to
    public function toFunctor() : Functor<R> return new EitherOfFunctor(this);

    @:from
    public static function unsafeFromFunctor<L, R>(a : Functor<R>) : Either<L, R> return EitherOfFunctor.from(cast a);
    
    @:to
    public function toMonad() : Monad<R> return new EitherOfMonad(this);

    @:from
    public static function unsafeFromMonad<L, R>(a : Monad<R>) : Either<L, R> return EitherOfMonad.from(cast a);

    @:to
    public function toApplicative() : Applicative<R> return new EitherOfApplicative(this);

    @:from
    public static function unsafeFromApplicative<L, R>(a : Applicative<R>) : Either<L, R> return EitherOfApplicative.from(cast a);
}

private class EitherOfFunctor<L, R> {

    private var x : Either<L, R>;

    public function new(x : Either<L, R>) this.x = x;

    public static inline function from<L, R>(x : EitherOfFunctor<L, R>) : Either<L, R> return x.x;

    public function map<T>(f : R -> T) : Functor<T> {
        var m : EitherType<L, R> = this.x;
        var n : Either<L, T> = switch(m) {
            case Left(a): Left(a);
            case Right(a): Right(f(a));
        };
        return n;
    }
}

private class EitherOfMonad<L, R> {

    private var x : Either<L, R>;

    public function new(x : Either<L, R>) this.x = x;

    public static inline function from<L, R>(x : EitherOfMonad<L, R>) : Either<L, R> return x.x;

    public function of(v : R) : Monad<R> return Either.of_(v);

    public function map<T>(f : R -> T) : Monad<T> {
        var m : EitherType<L, R> = this.x;
        var n : Either<L, T> = switch(m) {
            case Left(a): Left(a);
            case Right(a): Right(f(a));
        };
        return n;
    }

    public function chain<T>(f : R -> Monad<T>) : Monad<T> {
        var m : EitherType<L, R> = this.x;
        return switch(m) {
            case Right(a): f(a);
            case Left(a): 
                var n : Either<L, T> = Left(a);
                n;
        };
    }
}

private class EitherOfApplicative<L, R> {

    private var x : Either<L, R>;

    public function new(x : Either<L, R>) this.x = x;

    public static inline function from<L, R>(x : EitherOfApplicative<L, R>) : Either<L, R> return x.x;

    public function of(v : R) : Applicative<R> return Either.of_(v);

    public function ap<T>(a : Applicative<R>) : Applicative<T> {
        var m : EitherType<L, R> = this.x;
        return switch(m) {
            case Left(a): 
                var n : Either<L, T> = Left(a);
                n;
            case Right(f): a.map(function(x) {
                var g : R -> T = cast f;
                return g(x);
            });
        }
    }

    public function map<T>(f : R -> T) : Applicative<T> {
        var m : EitherType<L, R> = this.x;
        var n : Either<L, T> = switch(m) {
            case Left(a): Left(a);
            case Right(a): Right(f(a));
        };
        return n;
    }
}
