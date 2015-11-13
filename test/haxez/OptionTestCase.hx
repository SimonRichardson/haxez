package haxez;

import haxez.Combinators as C;
import haxez.check.adapters.HaxeUnitTestCase;

using haxez.Option;
using haxez.check.QuickCheck;

class OptionTestCase extends HaxeUnitTestCase {

    private var env : QuickCheck;

    public function new(env : QuickCheck) {
        super();

        this.env = env;
    }

    public function test_map() {
        assert(env.forAll(
            function(a : String) : Bool return equals(Options.of(a).map(C.identity()), Options.of(a)),
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