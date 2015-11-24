package haxez;

typedef Chain<T> = {
    function chain<A>(a : T -> Chain<A>) : Chain<A>;
}

typedef Morphism<T, A> = T -> A;

typedef Pointed<T> = {
    function of(a : T) : Pointed<T>;
}

typedef Semigroup<A> = {
    function concat(a : A) : Semigroup<A>;
}

// These are fully collapsed inheritance types.

typedef Functor<T> = {
    function map<A>(a : T -> A) : Functor<A>;
}

typedef Applicative<T> = {
    function of<A>(a : T) : Applicative<T>;
    function ap<A>(a : Applicative<T>) : Applicative<A>;
    function map<A>(a : T -> A) : Applicative<A>;
}

typedef Monad<T> = {
    function of(a : T) : Monad<T>;
    function map<A>(a : T -> A) : Monad<A>;
    function chain<A>(a : T -> Monad<A>) : Monad<A>;
}

typedef Monoid<A> = {
    function new() : Void;
    function empty() : Monoid<A>;
    function concat(a : A) : Monoid<A>;
}
