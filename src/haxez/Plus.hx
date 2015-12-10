package haxez;

import haxez.T;

interface IPlus<F> {

    public function plus<A>(a1 : _1<F, A>, a2 : _1<F, A>) : _1<F, A>;
}