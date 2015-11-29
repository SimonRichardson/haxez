package haxez;

import haxez.Combinators as C;
import haxez.Types.Functor as F;
import haxez.check.Arb;
import haxez.check.adapters.HaxeUnitTestCase;
import haxez.check.laws.Functor;

using haxez.Id;
using haxez.Coyoneda;
using haxez.check.Env;
using haxez.check.QuickCheck;

class CoyonedaTestCase extends HaxeUnitTestCase {

    private var env : Env;

    public function new(env : Env) {
        super();

        this.env = env;
    }

    private inline function get<T:(F<A>), A>(a : Coyoneda<T, A>) : T {
        var x : F<A> = a.lower();
        var y : Id<A> = x;
        var z : A = y.run();
        return cast z;
    }

    public function test_FunctorLaws<T:(F<A>), A>() {
        var functor = Functor.laws(this.env);
        assert(functor(
            function(a : T) : F<T> {
                var x : F<T> = Id.lift(a);
                var y : F<T> = Coyoneda.lift(cast x);
                return y;
            },
            function(a : F<T>) : T {
                var b : Coyoneda<T, A> = a;
                return get(b);
            }
        ));
    }
}