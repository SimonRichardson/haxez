package haxez;

import haxez.Combinators as C;
import haxez.Types;

using haxez.Option;

typedef OptionType<T> = haxe.ds.Option<T>;
typedef OptionCata<A, B> = {
    function Some(v : A) : B;
    function None() : B;
}

abstract Option<T>(OptionType<T>) from OptionType<T> to OptionType<T> {

    inline function new(opt : OptionType<T>) {
        this = opt;
    }

    @:noUsing
    public static inline function of<T>(v : T) : Option<T> return Some(v);

    @:noUsing
    public static inline function empty<T>() : Option<T> return None;

    public function cata<B>(cat : OptionCata<T, B>) : B {
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

    public inline function orElse<B>(x : Option<B>) : Option<B> {
        return this.fold(
            function(x : T) : Option<B> return cast Some(x),
            C.constant0(x)
        );
    }

    public inline function getOrElse(x : T) : T {
        return this.fold(
            C.identity(),
            C.constant0(x)
        );
    }

    public inline function chain<B>(f : T -> Option<B>) : Option<B> {
        return this.fold(
            function(x : T) : Option<B> return f(x),
            C.constant0(Option.empty())
        );
    }

    public inline function map<B>(f : T -> B) : Option<B> {
        return this.chain(function(a : T) : Option<B> {
            return Option.of(f(a));
        });
    }

    public inline function ap<B>(a : Option<T>) : Option<B> {
        var opt : Option<T -> B> = cast this;
        return opt.chain(function(f : T -> B) : Option<B> {
            return a.map(f);
        });
    }
}
