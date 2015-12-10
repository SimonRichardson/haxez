package haxez;

import haxez.Monad;
import haxez.PlusEmpty;
import haxez.T;

interface IMonadPlus<F> extends IMonad<F> extends IPlusEmpty<F> {}

class MonadPlus<F> extends Monad<F> implements IMonadPlus<F> {

    public function new() {
        super();
    }

    public function empty<A>() : _1<F, A> return Util.missing();

    public function plus<A>(a1 : _1<F, A>, a2 : _1<F, A>) : _1<F, A> return Util.missing();
}