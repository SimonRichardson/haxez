package haxez;

import haxez.Combinators as C;
import haxez.Types.Functor as F;
import haxez.check.Arb;
import haxez.check.adapters.HaxeUnitTestCase;
import haxez.check.laws.Functor;

using haxez.Option;
using haxez.check.Env;
using haxez.check.QuickCheck;

class OptionTestCase extends HaxeUnitTestCase {

    private var env : Env;

    public function new(env : Env) {
        super();

        this.env = env;
    }

    public function test_FunctorLaws<A>() {
        var functor = Functor.laws(this.env);
        assert(functor(
            function(a : A) : Option<A> {
                return Option.of(a);
            },
            function(a : Option<A>) : A {
                return switch(a) {
                    case Some(b): b;
                    case _: throw "Invalid";
                };
            }
        ));
    }
}