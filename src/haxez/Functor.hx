package haxez;

import haxez.F1;
import haxez.T;
import haxez.Util;

interface IFunctor<F> {
    public function map<A, B>(f : F1<A, B>, fa : _1<F, A>) : _1<F, B>;
}

class Functor<F> implements IFunctor<F> {

    public function new() {}

    public function map<A, B>(f : F1<A, B>, fa : _1<F, A>) : _1<F, B> return Util.missing();
}