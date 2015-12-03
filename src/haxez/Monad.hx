package haxez;

import haxez.F0;
import haxez.F1;
import haxez.Functor;
import haxez.T;

interface Monad<F> extends Functor<F> {

    public function point<A>(a : F0<A>) : _1<F, A>;

    public function flatMap<A, B>(f : F1<A, _1<F, B>>, fa : _1<F, A>) : _1<F, B>;
}