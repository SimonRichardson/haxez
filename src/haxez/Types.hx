package haxez;

typedef Semigroup<A> = {
    function concat(a : A) : A;
}

typedef Monoid<A> = {> Semigroup<A>,
    function new() : Void;
    function empty() : Monoid<A>;
}

typedef Functor<T> = {
    function map<A>(a : T -> A) : Functor<A>;
}

typedef Chain<A> = {> Functor<A>,
    function chain<B>(a : A -> Chain<B>) : Chain<B>;
}