package haxez;

import haxez.Combinators as C;
import haxez.Types;

using haxez.IO;

enum IOType<T> {
    IOType(unsafePerform : Void -> T);
}

abstract IO<T>(IOType<T>) from IOType<T> to IOType<T> {

    public inline function new(io : IOType<T>) {
        this = io;
    }

    @:noUsing
    public static inline function lift<T>(v : T) : IO<T> return IOType(C.constant0(v));

    public function of(v : T) : IO<T> return IO.lift(v);

    public inline function unsafePerform() : T {
        return switch(this) {
            case IOType(unsafePerform): unsafePerform();
        };
    }

    public inline function chain<A>(f : T -> IO<A>) : IO<A> {
        return IOType(function() : A {
            return f(this.unsafePerform()).unsafePerform();
        });
    }

    public inline function map<A>(f : T -> A) : IO<A> {
        return this.chain(function(a : T) : IO<A> {
            return IO.lift(f(a));
        });
    }

    public inline function ap<A>(a : IO<T>) : IO<A> {
        var io : IO<T -> A> = cast this;
        return io.chain(function(f : T -> A) : IO<A> {
            return a.map(f);
        });
    }

    @:to
    public function toFunctor() : Functor<T> return new IOOfFunctor(this);

    @:from
    public static function unsafeFromFunctor<T>(a : Functor<T>) : IO<T> return IOOfFunctor.from(cast a);

    @:to
    public function toMonad() : Monad<T> return new IOOfMonad(this);

    @:from
    public static function unsafeFromMonad<T>(a : Monad<T>) : IO<T> return IOOfMonad.from(cast a);
    
    @:to
    public function toApplicative() : Applicative<T> return new IOOfApplicative(this);

    @:from
    public static function unsafeFromApplicative<T>(a : Applicative<T>) : IO<T> return IOOfApplicative.from(cast a);
}

private class IOOfFunctor<T> {

    private var x : IO<T>;

    public function new(x : IO<T>) this.x = x;

    public static inline function from<T>(x : IOOfFunctor<T>) : IO<T> return x.x;

    public function map<A>(f : T -> A) : Functor<A> {
        var m : IOType<T> = this.x;
        var n : IO<A> = IOType(function() {
            return switch(m) {
                case IOType(unsafePerform): f(unsafePerform());
            };
        });
        return n;
    }
}

private class IOOfMonad<T> {

    private var x : IO<T>;

    public function new(x : IO<T>) this.x = x;

    public static inline function from<T>(x : IOOfMonad<T>) : IO<T> return x.x;

    public function of(v : T) : Monad<T> return IO.lift(v);

    public function map<A>(f : T -> A) : Monad<A> {
        var m : IOType<T> = this.x;
        var n : IO<A> = IOType(function() {
            return switch(m){
                case IOType(unsafePerform): f(unsafePerform());
            };
        });
        return n;
    }

    public function chain<A>(f : T -> Monad<A>) : Monad<A> {
        var m : IOType<T> = this.x;
        var n : IO<A> = switch(m) {
            case IOType(unsafePerform): f(unsafePerform());
        };
        return n;
    }
}

private class IOOfApplicative<T> {

    private var x : IO<T>;

    public function new(x : IO<T>) this.x = x;

    public static inline function from<T>(x : IOOfApplicative<T>) : IO<T> return x.x;

    public function of(v : T) : Applicative<T> return IO.lift(v);

    public function ap<A>(a : Applicative<T>) : Applicative<A> {
        var m : IOType<T> = this.x;
        var n : IO<A> = a.map(function(x) {
            var g : T -> A = cast switch(m) {
                case IOType(unsafePerform): unsafePerform();
            };
            return g(x);
        });
        return n;
    }

    public function map<A>(f : T -> A) : Applicative<A> {
        var m : IOType<T> = this.x;
        var n : IO<A> = IOType(function() {
            return switch(m) {
                case IOType(unsafePerform): f(unsafePerform());
            };
        });
        return n;
    }
}
