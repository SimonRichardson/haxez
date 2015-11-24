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

using haxez.Either;
using haxez.check.Env;
using haxez.check.QuickCheck;

class EitherTestCase extends HaxeUnitTestCase {

    private var env : Env;

    public function new(env : Env) {
        super();

        this.env = env;
    }

    private inline function get<L, R>(a : Either<L, R>) : R {
        return switch(a) {
            case Right(b): b;
            case _: throw "Invalid";
        };
    }

    public function test_FunctorLaws<L, R>() {
        var functor = Functor.laws(this.env);
        assert(functor(
            function(a : R) : F<R> {
                return Either.of_(a);
            },
            function(a : F<R>) : R {
                var b : Either<L, R> = a;
                return get(b);
            }
        ));
    }
    
    public function test_MonadLaws<L, R>() {
        var monad = Monad.laws(this.env);
        assert(monad(
            function() : M<R> {
                // This is clearly wrong, but how do you generate a empty either?
                return Either.of_(cast 0);
            },
            function(a : M<R>) : R {
                var b : Either<L, R> = a;
                return get(b);
            }
        ));
    }
    
    public function test_ApplicativeLaws<L, R>() {
        var applicative = Applicative.laws(this.env);
        assert(applicative(
            function() : A<R> {
                return Either.of_(cast 0);
            },
            function(a : A<R>) : R {
                var b : Either<L, R> = a;
                return get(b);
            }
        ));
    }
}