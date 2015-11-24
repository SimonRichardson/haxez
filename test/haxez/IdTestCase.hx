package haxez;

import haxez.Combinators as C;
import haxez.Types.Applicative as A;
import haxez.Types.Functor as F;
import haxez.Types.Monad as M;
import haxez.check.Arb;
import haxez.check.adapters.HaxeUnitTestCase;
import haxez.check.laws.Applicative;
import haxez.check.laws.Functor;
import haxez.check.laws.Monad;

using haxez.IO;
using haxez.check.Env;
using haxez.check.QuickCheck;

class IdTestCase extends HaxeUnitTestCase {

    private var env : Env;

    public function new(env : Env) {
        super();

        this.env = env;
    }

    private inline function get<T>(a : Id<T>) : T {
        return a.run();
    }

    public function test_FunctorLaws<T>() {
        var functor = Functor.laws(this.env);
        assert(functor(
            function(a : T) : F<T> {
                return Id.of_(a);
            },
            function(a : F<T>) : T {
                var b : Id<T> = a;
                return get(b);
            }
        ));
    }

    public function test_MonadLaws<T>() {
        var monad = Monad.laws(this.env);
        assert(monad(
            function() : M<T> {
                return Id.of_(cast 0);
            },
            function(a : M<T>) : T {
                var b : Id<T> = a;
                return get(b);
            }
        ));
    }

    public function test_ApplicativeLaws<T>() {
        var applicative = Applicative.laws(this.env);
        assert(applicative(
            function() : A<T> {
                return Id.of_(cast 0);
            },
            function(a : A<T>) : T {
                var b : Id<T> = a;
                return get(b);
            }
        ));
    }
}