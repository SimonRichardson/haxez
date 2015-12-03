package haxez;

import haxez.T;

interface NT<F, G> {

    public function apply<A>(_1<F, A> fa) : _1<G, A>;
}

class NaturalTransformation {

    inline public static function id<T>() : NT<T, T> return new NaturalIdentity();
}

class NaturalIdentity<T, T> {

    public function new() {}

    public function apply<A>(_1<T, A> fa) : _1<T, A> return fa;
}