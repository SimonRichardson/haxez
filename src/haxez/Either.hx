package haxez;

import haxez.Combinators as C;

using haxez.Either;

typedef Either<A, B> = haxe.ds.Either<A, B>;
typedef EitherCata<A, B, C> = {
    function Left(l : A) : C;
    function Right(r : B) : C;
}

class Eithers {

    @:noUsing
    public static inline function of<A, B>(v : B) : Either<A, B> {
        return Right(v);
    }

    public static function cata<A, B, C>(e : Either<A, B>, cat : EitherCata<A, B, C>) : C {
        return switch(e) {
            case Left(v): cat.Left(v);
            case Right(v): cat.Right(v);
        }
    }

    public static inline function fold<A, B, C>(e : Either<A, B>, f : A -> C, g : B -> C) : C {
        return e.cata({
            Left: f, 
            Right: g
        });
    }

    public static inline function swap<A, B>(e : Either<A, B>) : Either<B, A> {
        return e.fold(
            function(a : A) : Either<B, A> return Right(a),
            function(b : B) : Either<B, A> return Left(b)
        );
    }

    public static inline function bimap<A, B, C, D>(e : Either<A, B>, f : A -> C, g : B -> D) : Either<C, D> {
        return e.fold(
            function(a : A) : Either<C, D> return Left(f(a)),
            function(b : B) : Either<C, D> return Right(g(b))
        );
    }

    public static inline function chain<A, B, C>(e : Either<A, B>, f : B -> Either<A, C>) : Either<A, C> {
        return e.fold(
            function(a : A) : Either<A, C> return Left(a),
            f
        );
    }

    public static inline function map<A, B, C>(e : Either<A, B>, f : B -> C) : Either<A, C> {
        return e.chain(function(a : B) : Either<A, C> {
            return Eithers.of(f(a));
        });
    }

    public static inline function ap<A, B, C>(e : Either<A, B -> C>, a : Either<A, B>) : Either<A, C> {
        return e.chain(function(f : B -> C) : Either<A, C> {
            return a.map(f);
        });
    }
}
