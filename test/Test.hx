package ;

import haxe.ds.ObjectMap;
import haxe.unit.TestRunner;

using haxez.check.Arb;
using haxez.check.Env;
using haxez.check.QuickCheck;

class Test {
    public static function main() {
        var env = Env(500)
            .addBool()
            .addFloat()
            .addInt()
            .addString()
            .addAnyVal([Bool, Float, Int, String]);

        var runner = new TestRunner();
        runner.add(new haxez.CoyonedaTestCase(env));
        runner.add(new haxez.EitherTestCase(env));
        //runner.add(new haxez.FreeTestCase(env));
        runner.add(new haxez.IdTestCase(env));
        runner.add(new haxez.IOTestCase(env));
        runner.add(new haxez.MaybeTestCase(env));
        runner.run();
    }
}
