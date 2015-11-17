package haxez;

import haxez.Combinators as C;
import haxez.check.Arb;
import haxez.check.adapters.HaxeUnitTestCase;

using haxez.Option;
using haxez.check.QuickCheck;

class OptionTestCase extends HaxeUnitTestCase {

    private var env : QuickCheck;

    public function new(env : QuickCheck) {
        super();

        this.env = env;
    }

    public function test_Functor_identity() {
        assert(env.forAll(
            function(a : Int) : Bool {
                return equals(
                    Options.of(a).map(C.identity()), 
                    Options.of(a)
                );
            },
            Int
        ));
    }

    public function test_Functor_composition() {
        assert(env.forAll(
            function(a : String) : Bool {
                return equals(
                    Options.of(a).map(C.compose(C.identity())(C.identity())), 
                    Options.of(a).map(C.identity()).map(C.identity())
                );
            },
            String
        ));
    }

    private function equals<A, B>(a : Option<A>, b : Option<A>) : Bool {
        return switch(a) {
            case Some(x): 
                switch(b) {
                    case Some(y): x == y;
                    case None: false;
                }
            case None: 
                switch(b) {
                    case Some(_): false;
                    case None: true;
                }
        }
    }
}