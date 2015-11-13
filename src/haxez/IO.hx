package haxez;

import haxez.Combinators as C;

using haxez.IO;

class IO<T> {

    public var unsafePerform(default, null) : Void -> T;

    public inline function new(unsafePerform : Void -> T) {
        this.unsafePerform = unsafePerform;
    }
}

class IOs {

    @:noUsing
    public static inline function of<T>(x : T) : IO<T> {
        return new IO(C.constant0(x));
    }

    public static inline function chain<A, B>(io : IO<A>, f : A -> IO<B>) : IO<B> {
        return new IO(function() : Void -> B {
            return f(io.unsafePerform()).unsafePerform();
        });
    }

    public static inline function map<A, B>(io : IO<A>, f : A -> B) : IO<B> {
        return io.chain(function(a : A) : IO<B> {
            return IOs.of(f(a));
        });
    }

    public static inline function ap<A, B>(io : IO<A -> B>, a : IO<A>) : IO<B> {
        return io.chain(function(f : A -> B) : IO<B> {
            return a.map(f);
        });
    }
}

