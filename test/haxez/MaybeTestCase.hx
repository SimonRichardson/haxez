package haxez;

import haxez.Combinators as C;
import haxez.Types.Functor as F;
import haxez.Types.Monad as M;
import haxez.check.Arb;
import haxez.check.adapters.HaxeUnitTestCase;
import haxez.check.laws.Functor;
import haxez.check.laws.Monad;

using haxez.Maybe;
using haxez.check.Env;
using haxez.check.QuickCheck;

class MaybeTestCase extends HaxeUnitTestCase {

    private var env : Env;

    public function new(env : Env) {
        super();

        this.env = env;
    }

    public function test_FunctorLaws<A>() {
        var functor = Functor.laws(this.env);
        assert(functor(
            function(a : A) : F<A> {
                return Maybe.of_(a);
            },
            function(a : F<A>) : A {
                var b : Maybe<A> = a;
                return switch(b) {
                    case Some(c): c;
                    case _: throw "Invalid";
                };
            }
        ));
    }

    public function test_MonadLaws<A>() {
        var monad = Monad.laws(this.env);
        assert(monad(
            function() : M<A> {
                return Maybe.empty_();
            },
            function(a : M<A>) : A {
                var b : Maybe<A> = a;
                return switch(b) {
                    case Some(c): c;
                    case _: throw "Invalid";
                };
            }
        ));
    }
}