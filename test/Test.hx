package ;

import haxe.unit.TestRunner;
import haxez.OptionTestCase;

using haxez.check.Arb;
using haxez.check.QuickCheck;

class Test {
    public static function main() {
        var env = Env(100, [
            Arb.String => String
        ]);

        var runner = new TestRunner();
        runner.add(new OptionTestCase(env));
        runner.run();
    }
}
