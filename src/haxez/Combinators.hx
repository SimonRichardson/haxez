package haxez;

class Combinators {

    public inline static function identity<A>() : A -> A {
        return function(x : A) : A {
            return x;
        }
    }

    public inline static function constant0<B>(v : B) : Void -> B {
        return function() : B {
            return v;
        };
    }

    public inline static function constant1<A, B>(v : B) : A -> B {
        return function(x :  A) : B {
            return v;
        };
    }
}