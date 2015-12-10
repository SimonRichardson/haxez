package haxez;

import haxez.Plus;
import haxez.T;

interface IPlusEmpty<F> extends IPlus<F> {

    public function empty<A>() : _1<F, A>;
}