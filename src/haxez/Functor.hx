package haxez;

import haxe.ds.Option;
import haxe.ds.Either;

using haxez.F1;

typedef Covariant<A, B> = {
    function fmap<F: F1<A, B>>(f: F): Covariant<B>;
}

typedef Contravariant<A, B> = {
    function contramap<F: F1<B, B>>(f: F): Contravariant<B>;
}

typedef Invariant<A, B> = {
    function invmap<F: Iso<A, B>>(f: F): Invariant<B>;
}

typedef Bivariant<B> = {
    function xmap(): Bivariant<B>;
}

typedef NaturalTransform<T> = {
    fn transform(): T;
}

abstract CovariantOfOption<A, B>(Option<A>) from (Option<A>) to (Option<A>) {

    public function new(a) this = a;

    public function fmap<F: F1<A, B>>(f: F): Covariant<B> {
        return this.map(function(a) return f.apply(a));
    }
}

abstract CovariantOfEither<A, B, C>(Either<A, B>) from (Either<A, B>) to (Either<A, B>) {

    public function new(a) this = a;

    public function fmap<F: F1<B, C>>(f: F): Covariant<C> {
        return this.map(function(a) return f.apply(a));
    }
}

abstract NaturalTransformOfEither<A, B>(Either<A, B>) from (Either<A, B>) to (Either<A, B>) {

    public function new (a) this = a;

    public function transform(): Option<A> {
        return switch(this) {
            case Left(_): None;
            case Right(a): Some(a);
        };
    }
}