package haxez;

import haxez.F0;
import haxez.F1;
import haxez.Functor;
import haxez.T;
import haxez.Util;

interface IApply<F> extends IFunctor<F> {

    public function ap<A, B>(f : F0<_1<F, F1<A, B>>>, fa : F0<_1<F, A>>) : _1<F, B>;

    public function apply2<A1, A2, Z>(  a : F0<_1<F, A1>>, 
                                        b : F0<_1<F, A2>>, 
                                        f : F2<A1, A2, Z>
                                        ) : _1<F, Z>;
}

class Apply<F> extends Functor<F> implements IApply<F> {

    public function new() {
        super();
    }

    public function ap<A, B>(f : F0<_1<F, F1<A, B>>>, fa : F0<_1<F, A>>) : _1<F, B> {
        return Util.missing();
    }

    public function apply2<A1, A2, Z>(  a : F0<_1<F, A1>>, 
                                        b : F0<_1<F, A2>>, 
                                        f : F2<A1, A2, Z>
                                        ) : _1<F, Z> {
        // TODO : Remove the `cast`
        return ap(
            cast new F0Lift(function() {
                return map(new F1Lift(function(a1) {
                    return new F1Lift(function(a2) {
                        return f.apply(a1, a2);
                    });
                }), a.apply());
            }),
            b
        );
    }
}
