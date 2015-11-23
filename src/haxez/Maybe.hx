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

    public function cata<B>(cat : MaybeCata<T, B>) : B {
        return switch(this) {
            case Some(v): cat.Some(v);
            case None: cat.None();
        }
    }

    public inline function fold<B>(f : T -> B, g : Void -> B) : B {
        return this.cata({
            Some: f, 
            None: g
        });
    }

    public inline function orElse<B>(x : Maybe<B>) : Maybe<B> {
        return this.fold(
            function(x : T) : Maybe<B> return cast Some(x),
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

    public inline function ap<B>(a : Maybe<T>) : Maybe<B> {
        var opt : Maybe<T -> B> = cast this;
        return opt.chain(function(f : T -> B) : Maybe<B> {
            return a.map(f);
        });
    }

    @:to
    public function toFunctor() : Functor<T> return new MaybeTypeOf(this);

    @:from
    public static function fromFunctor<T>(a : Functor<T>) : Maybe<T> return MaybeTypeOf.from(cast a);

    @:to
    public function toMonad() : Monad<T> return new MaybeTypeOf(this);

    @:from
    public static function fromMonad<T>(a : Monad<T>) : Maybe<T> return MaybeTypeOf.from(cast a);
}

private class MaybeTypeOf<T> {

    private var x : Maybe<T>;

    public function new(x : Maybe<T>) this.x = x;

    public static function from<T>(x : MaybeTypeOf<T>) : Maybe<T> return x.x;

    public function of(v : T) : Monad<T> return Maybe.of_(v);

    public function map<A>(f : T -> A) : Functor<A> {
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