package haxez;

import haxez.Combinators as C;

using haxez.Option;

typedef Option<T> = haxe.ds.Option<T>;
typedef OptionCata<A, B> = {
    function Some(v : A) : B;
    function None() : B;
}

class Options {

    @:noUsing
    public static inline function of<T>(v : T) : Option<T> {
        return Some(v);
    }

    @:noUsing
    public static inline function empty<T>() : Option<T> {
        return None;
    }

    public static function cata<A, B>(opt : Option<A>, cat : OptionCata<A, B>) : B {
        return switch(opt) {
            case Some(v): cat.Some(v);
            case None: cat.None();
        }
    }

    public static inline function fold<A, B>(opt : Option<A>, f : A -> B, g : Void -> B) : B {
        return opt.cata({
            Some: f, 
            None: g
        });
    }

    public static inline function orElse<A, B>(opt : Option<A>, x : Option<B>) : Option<B> {
        return opt.fold(
            function(x : A) : Option<B> return cast Some(x),
            C.constant0(x)
        );
    }

    public static inline function getOrElse<A, B>(opt : Option<A>, x : A) : A {
        return opt.fold(
            C.identity(),
            C.constant0(x)
        );
    }

    public static inline function chain<A, B>(opt : Option<A>, f : A -> Option<B>) : Option<B> {
        return opt.fold(
            function(x : A) : Option<B> return f(x),
            C.constant0(Option.None)
        );
    }

    public static inline function map<A, B>(opt : Option<A>, f : A -> B) : Option<B> {
        return opt.chain(function(a : A) : Option<B> {
            return Options.of(f(a));
        });
    }

    public static inline function ap<A, B>(opt : Option<A -> B>, a : Option<A>) : Option<B> {
        return opt.chain(function(f : A -> B) : Option<B> {
            return a.map(f);
        });
    }
}
