package haxez;

import haxez.Combinators as C;
import haxez.Types;

using haxez.Maybe;

typedef MaybeType<T> = haxe.ds.Option<T>;
typedef MaybeCata<A, B> = {
    function Some(v : A) : B;
    function None() : B;
}

abstract Maybe<T>(MaybeType<T>) from MaybeType<T> to MaybeType<T> {

    inline function new(opt : MaybeType<T>) {
        this = opt;
    }

    @:noUsing
    public static inline function of_<T>(v : T) : Maybe<T> return Some(v);

    @:noUsing
    public static inline function empty_<T>() : Maybe<T> return None;

    public function of(v : T) : Maybe<T> return Maybe.of_(v);

    public function empty() : Maybe<T> return Maybe.empty_();

    public function cata<A>(cat : MaybeCata<T, A>) : A {
        return switch(this) {
            case Some(v): cat.Some(v);
            case None: cat.None();
        }
    }

    public inline function fold<A>(f : T -> A, g : Void -> A) : A {
        return this.cata({
            Some: f, 
            None: g
        });
    }

    public inline function orElse<A>(x : Maybe<A>) : Maybe<A> {
        return this.fold(
            function(x : T) : Maybe<A> return Some(cast x),
            C.constant0(x)
        );
    }

    public inline function getOrElse(x : T) : T {
        return this.fold(
            C.identity(),
            C.constant0(x)
        );
    }

    public inline function chain<A>(f : T -> Maybe<A>) : Maybe<A> {
        return this.fold(
            function(x : T) : Maybe<A> return f(x),
            C.constant0(Maybe.empty_())
        );
    }

    public inline function map<A>(f : T -> A) : Maybe<A> {
        return this.chain(function(a : T) : Maybe<A> {
            return Maybe.of_(f(a));
        });
    }

    public inline function ap<A>(a : Maybe<T>) : Maybe<A> {
        var opt : Maybe<T -> A> = cast this;
        return opt.chain(function(f : T -> A) : Maybe<A> {
            return a.map(f);
        });
    }

    @:to
    public function toFunctor() : Functor<T> return new MaybeOfFunctor(this);

    @:from
    public static function unsafeFromFunctor<T>(a : Functor<T>) : Maybe<T> return MaybeOfFunctor.from(cast a);

    @:to
    public function toMonad() : Monad<T> return new MaybeOfMonad(this);

    @:from
    public static function unsafeFromMonad<T>(a : Monad<T>) : Maybe<T> return MaybeOfMonad.from(cast a);

    @:to
    public function toApplicative() : Applicative<T> return new MaybeOfApplicative(this);

    @:from
    public static function unsafeFromApplicative<T>(a : Applicative<T>) : Maybe<T> return MaybeOfApplicative.from(cast a);
}

private class MaybeOfFunctor<T> {

    private var x : Maybe<T>;

    public function new(x : Maybe<T>) this.x = x;

    public static inline function from<T>(x : MaybeOfFunctor<T>) : Maybe<T> return x.x;

    public function map<A>(f : T -> A) : Functor<A> {
        var m : MaybeType<T> = this.x;
        var n : Maybe<A> = switch(m) {
            case Some(a): Some(f(a));
            case None: None;
        };
        return n;
    }
}

private class MaybeOfMonad<T> {

    private var x : Maybe<T>;

    public function new(x : Maybe<T>) this.x = x;

    public static function from<T>(x : MaybeOfMonad<T>) : Maybe<T> return x.x;

    public function of(v : T) : Monad<T> return Maybe.of_(v);

    public function map<A>(f : T -> A) : Monad<A> {
        var m : MaybeType<T> = this.x;
        var n : Maybe<A> = switch(m) {
            case Some(a): Some(f(a));
            case None: None;
        };
        return n;
    }

    public function chain<A>(f : T -> Monad<A>) : Monad<A> {
        var m : MaybeType<T> = this.x;
        return switch(m) {
            case Some(a): f(a);
            case None: 
                var n : Maybe<A> = None;
                n;
        };
    }
}

private class MaybeOfApplicative<T> {

    private var x : Maybe<T>;

    public function new(x : Maybe<T>) this.x = x;

    public static inline function from<T>(x : MaybeOfApplicative<T>) : Maybe<T> return x.x;

    public function of(v : T) : Applicative<T> return Maybe.of_(v);

    public function ap<A>(a : Applicative<T>) : Applicative<A> {
        var m : MaybeType<T> = this.x;
        return switch(m) {
            case Some(f): a.map(function(x) {
                var g : T -> A = cast f;
                return g(x);
            });
            case None: 
                var n : Maybe<A> = None;
                n;
        }
    }

    public function map<A>(f : T -> A) : Applicative<A> {
        var m : MaybeType<T> = this.x;
        var n : Maybe<A> = switch(m) {
            case Some(a): Some(f(a));
            case None: None;
        };
        return n;
    }
}