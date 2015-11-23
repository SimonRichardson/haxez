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

typedef Pointed<A> = {
    function of(a : A) : Pointed<A>;
}

typedef Monad<A> = {
    function of(a : A) : Monad<A>;
    function chain<B>(a : A -> Monad<B>) : Monad<B>;
}