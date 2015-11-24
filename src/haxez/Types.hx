package haxez;

typedef Semigroup<A> = {
    function concat(a : A) : A;
}

typedef Monoid<A> = {> Semigroup<A>,
    function new() : Void;
    function empty() : Monoid<A>;
}

typedef Chain<T> = {>Functor<T>,
    function chain<A>(a : T -> Chain<A>) : Chain<A>;
}

typedef Pointed<T> = {
    function of(a : T) : Pointed<T>;
}

// These are fully collapsed inheritance types.

typedef Functor<T> = {
    function map<A>(a : T -> A) : Functor<A>;
}

typedef Applicative<T> = {
    function of<A>(a : T -> A) : Applicative<T>;
    function ap<A>(a : Applicative<T>) : Applicative<A>;
    function map<A>(a : T -> A) : Applicative<A>;
}

typedef Monad<T> = {
    function of(a : T) : Monad<T>;
    function map<A>(a : T -> A) : Monad<A>;
    function chain<A>(a : T -> Monad<A>) : Monad<A>;
}