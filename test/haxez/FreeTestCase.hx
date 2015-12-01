package haxez;

import haxez.Combinators as C;
import haxez.Types.Functor as F;
import haxez.Types.Monad as M;
import haxez.check.Arb;
import haxez.check.adapters.HaxeUnitTestCase;
import haxez.check.laws.Functor;
import haxez.check.laws.Monad;

using haxez.Id;
using haxez.Free;
using haxez.check.Env;
using haxez.check.QuickCheck;

class FreeTestCase extends HaxeUnitTestCase {

    private var env : Env;

    public function new(env : Env) {
        super();

        this.env = env;
    }

    private inline function get<T>(a : Free<T>) : T {
        var x : Id<T> = Free.runFC(a, C.identity(), Id.lift);
        return x.run();
    }

    public function test_FunctorLaws<T>() {
        var functor = Functor.laws(this.env);
        assert(functor(
            function(a : T) : F<T> {
                var y : F<T> = Free.lift(a);
                return y;
            },
            function(a : F<T>) : T {
                var b : Free<T> = a;
                return get(b);
            }
        ));
    }

    public function test_MonadLaws<T>() {
        var monad = Monad.laws(this.env);
        assert(monad(
            function() : M<T> {
                return Free.lift(cast 0);
            },
            function(a : M<T>) : T {
                var b : Free<T> = a;
                return get(b);
            }
        ));
    }
}