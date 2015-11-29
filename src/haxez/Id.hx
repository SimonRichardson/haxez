package haxez;

import haxez.Combinators as C;
import haxez.Types;

using haxez.Id;

enum IdType<T> {
    IdType(a : T);
}

abstract Id<T>(IdType<T>) from IdType<T> to IdType<T> {

    public inline function new(id : IdType<T>) {
        this = id;
    }

    @:noUsing
    public static inline function lift<T>(v : T) : Id<T> return IdType(v);

    public function of(v : T) : Id<T> return Id.lift(v);

    public inline function run() : T {
        return switch(this) {
            case IdType(a): a;
        };
    }

    public inline function chain<A>(f : T -> Id<A>) : Id<A> {
        return switch(this) {
            case IdType(a): f(a);
        };
    }

    public inline function map<A>(f : T -> A) : Id<A> {
        return this.chain(function(a : T) : Id<A> {
            return Id.lift(f(a));
        });
    }

    public inline function ap<A>(a : Id<T>) : Id<A> {
        var id : Id<T -> A> = cast this;
        return id.chain(function(f : T -> A) : Id<A> {
            return a.map(f);
        });
    }

    @:to
    public function toFunctor() : Functor<T> return new IdOfFunctor(this);

    @:from
    public static function unsafeFromFunctor<T>(a : Functor<T>) : Id<T> return IdOfFunctor.from(cast a);

    @:to
    public function toMonad() : Monad<T> return new IdOfMonad(this);

    @:from
    public static function unsafeFromMonad<T>(a : Monad<T>) : Id<T> return IdOfMonad.from(cast a);
    
    @:to
    public function toApplicative() : Applicative<T> return new IdOfApplicative(this);

    @:from
    public static function unsafeFromApplicative<T>(a : Applicative<T>) : Id<T> return IdOfApplicative.from(cast a);
}

private class IdOfFunctor<T> {

    private var x : Id<T>;

    public function new(x : Id<T>) this.x = x;

    public static inline function from<T>(x : IdOfFunctor<T>) : Id<T> return x.x;

    public function map<A>(f : T -> A) : Functor<A> {
        var m : IdType<T> = this.x;
        var n : Id<A> = switch(m) {
            case IdType(a): IdType(f(a));
        };
        return n;
    }
}

private class IdOfMonad<T> {

    private var x : Id<T>;

    public function new(x : Id<T>) this.x = x;

    public static inline function from<T>(x : IdOfMonad<T>) : Id<T> return x.x;

    public function of(v : T) : Monad<T> return Id.lift(v);

    public function map<A>(f : T -> A) : Monad<A> {
        var m : IdType<T> = this.x;
        var n : Id<A> = switch(m) {
            case IdType(a): IdType(f(a));
        };
        return n;
    }

    public function chain<A>(f : T -> Monad<A>) : Monad<A> {
        var m : IdType<T> = this.x;
        var n : Id<A> = switch(m) {
            case IdType(a): f(a);
        };
        return n;
    }
}

private class IdOfApplicative<T> {

    private var x : Id<T>;

    public function new(x : Id<T>) this.x = x;

    public static inline function from<T>(x : IdOfApplicative<T>) : Id<T> return x.x;

    public function of(v : T) : Applicative<T> return Id.lift(v);

    public function ap<A>(a : Applicative<T>) : Applicative<A> {
        var m : IdType<T> = this.x;
        var n : Id<A> = a.map(function(x) {
            var g : T -> A = cast switch(m) {
                case IdType(a): a;
            };
            return g(x);
        });
        return n;
    }

    public function map<A>(f : T -> A) : Applicative<A> {
        var m : IdType<T> = this.x;
        var n : Id<A> = switch(m) {
            case IdType(a): IdType(f(a));
        };
        return n;
    }
}
