package haxez;

import haxez.F1;
import haxez.T;

interface Functor<F> {
    public function map<A, B>(f : F1<A, B>, fa : _1<F, A>) : _1<F, B>;
}