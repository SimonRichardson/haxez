package ;

import haxe.ds.ObjectMap;
import haxe.unit.TestRunner;
import haxez.MaybeTestCase;

using haxez.check.Arb;
using haxez.check.Env;
using haxez.check.QuickCheck;

class Test {
    public static function main() {
        var env = Env(100)
            .addBool()
            .addFloat()
            .addInt()
            .addString()
            .addAnyVal();

        var runner = new TestRunner();
        runner.add(new MaybeTestCase(env));
        runner.run();
    }
}
