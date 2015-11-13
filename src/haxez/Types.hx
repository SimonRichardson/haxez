package haxez;

typedef Semigroup<A> = {
    function concat(a : A) : A;
}

typedef Monoid<A> = {> Semigroup<A>,
    function new() : Void;
    function empty() : Monoid<A>;
}