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

class IOTestCase extends HaxeUnitTestCase {

    private var env : Env;

    public function new(env : Env) {
        super();

        this.env = env;
    }

    private inline function get<T>(a : IO<T>) : T {
        return a.unsafePerform();
    }

    public function test_FunctorLaws<T>() {
        var functor = Functor.laws(this.env);
        assert(functor(
            function(a : T) : F<T> {
                return IO.lift(a);
            },
            function(a : F<T>) : T {
                var b : IO<T> = a;
                return get(b);
            }
        ));
    }

    public function test_MonadLaws<T>() {
        var monad = Monad.laws(this.env);
        assert(monad(
            function() : M<T> {
                return IO.lift(cast 0);
            },
            function(a : M<T>) : T {
                var b : IO<T> = a;
                return get(b);
            }
        ));
    }

    public function test_ApplicativeLaws<T>() {
        var applicative = Applicative.laws(this.env);
        assert(applicative(
            function() : A<T> {
                return IO.lift(cast 0);
            },
            function(a : A<T>) : T {
                var b : IO<T> = a;
                return get(b);
            }
        ));
    }
}