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
            function(a : A) : F<A> {
                return cast Option.of(a);
            }, 
            function(a : F<A>) : A {
                var o : Option<A> = cast a;
                return switch(o) {
                    case Some(a): a;
                    case _: throw "Invalid";
                };
            }
        ));
    }
}