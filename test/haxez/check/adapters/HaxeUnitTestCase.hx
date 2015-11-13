package haxez.check.adapters;

import haxe.unit.TestCase;

using haxez.Option;
using haxez.check.QuickCheck;

class HaxeUnitTestCase extends TestCase {

    public function new() {
        super();
    }

    public function assert<A>(x : Option<Report<A>>) : Void {
        assertTrue(switch(x) {
            case Some(fail): 
                print('- Failed after ${fail.tries()} tries: ${fail.input().toString()}\n');
                false;
            case _: true;
        });
    }
}