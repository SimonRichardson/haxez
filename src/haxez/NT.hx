package haxez;

import haxez.T;

interface INaturalTransformation<F, G> {

    public function apply<A>(fa : _1<F, A>) : _1<G, A>;
}

class NaturalTransformation {

    inline public static function id<T>() : INaturalTransformation<T, T> {
        return new NaturalIdentity();
    }
}

class NaturalIdentity<T> implements INaturalTransformation<T, T> {

    public function new() {}

    public function apply<A>(fa : _1<T, A>) : _1<T, A> return fa;
}