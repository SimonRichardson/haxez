package examples;

import haxez.Functor;
import haxez.Id;

using haxez.F1;

class IdExample {

    public static function main() {
        var a : Id<Int> = IdNative.Id(1);
        var b : IdNative<Int> = a.map(inc.lift());

        var f = haxez.Id.functor();
        var c = f.map(inc.lift(), a);

        trace(b, c);
    }

    public static function inc(a : Int) : Int return a + 1;
}