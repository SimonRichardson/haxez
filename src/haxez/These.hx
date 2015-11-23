package haxez;

using haxez.Maybe;
using haxez.These;

enum These<A, B> {
    This(a : A);
    That(b : B);
    Both(a : A, b : B);
}
typedef TheseCata<A, B, C> = {
    function This(a : A) : C;
    function That(b : B) : C;
    function Both(a : A, b : B) : C;
}

class Theses {

    @:noUsing
    public static inline function of<A, B>(v : B) : These<A, B> {
        return That(v);
    }

    public static function cata<A, B, C>(the : These<A, B>, cat : TheseCata<A, B, C>) : C {
        return switch(the) {
            case This(a): cat.This(a);
            case That(b): cat.That(b);
            case Both(a, b): cat.Both(a, b);
        }
    }

    public static inline function bimap<A, B, C, D>(the : These<A, B>, f : A -> C, g : B -> D) : These<C, D> {
        return the.cata({
            This: function(a : A) : These<C, D> return This(f(a)),
            That: function(b : B) : These<C, D> return That(g(b)),
            Both: function(a : A, b : B) : These<C, D> return Both(f(a), g(b))
        });
    }

    public static inline function left<A, B>(the : These<A, B>) : Maybe<A> {
        return the.cata({
            This: function(a : A) : Maybe<A> return Some(a),
            That: function(b : B) : Maybe<A> return None,
            Both: function(a : A, b : B) : Maybe<A> return Some(a)
        });
    }

    public static inline function right<A, B>(the : These<A, B>) : Maybe<B> {
        return the.cata({
            This: function(a : A) : Maybe<B> return None,
            That: function(b : B) : Maybe<B> return Some(b),
            Both: function(a : A, b : B) : Maybe<B> return Some(b)
        });
    }

    public static inline function thisOrBoth<A, B>(a : A, b : Maybe<B>) : These<A, B> {
        return b.cata({
            Some: function(x : B) : These<A, B> return Both(a, x),
            None: function() : These<A, B> return This(a)
        });
    }

    public static inline function thatOrBoth<A, B>(a : B, b : Maybe<A>) : These<A, B> {
        return b.cata({
            Some: function(x : A) : These<A, B> return Both(x, a),
            None: function() : These<A, B> return That(a)
        });
    }
}