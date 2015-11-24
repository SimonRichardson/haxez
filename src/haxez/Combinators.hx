package haxez;

class Combinators {

    // A - Combinator
    public inline static function apply<A, B>(f : A -> B) : (A -> B) {
        return function(x : A) : B {
            return f(x);
        };
    }

    // B - Combinator
    public inline static function compose<A, B, C>(f : B -> C) : (A -> B) -> (A -> C) {
        return function(g : A -> B) : A -> C {
            return function(x : A) : C {
                return f(g(x));
            };
        };
    }

    // K - Combinator (0 argument addition)
    public inline static function constant0<B>(v : B) : Void -> B {
        return function() : B {
            return v;
        };
    }

    // K - Combinator (1 argument addition)
    public inline static function constant1<A, B>(v : B) : A -> B {
        return function(x :  A) : B {
            return v;
        };
    }

    // I - Combinator
    public inline static function identity<A>() : A -> A {
        return function(x : A) : A {
            return x;
        };
    }

    // T - Combinator
    public inline static function thrush<A, B>(x : A) : (A -> B) -> B {
        return function(f : A -> B) : B {
            return f(x);
        };
    }
}