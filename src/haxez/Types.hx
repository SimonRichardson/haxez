package haxez;

typedef Semigroup<A> = {
    function concat(a : A) : A;
}

typedef Monoid<A> = {> Semigroup<A>,
    function new() : Void;
    function empty() : Monoid<A>;
}

typedef Functor<A> = {
    function map<B>(a : A -> B) : Functor<B>;
}

typedef Chain<A> = {
    function chain<B>(a : A -> Chain<B>) : Chain<B>;
}