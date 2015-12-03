package examples;

import haxez.Id;

using haxez.F1;

class IdExample {

    public static function main() {
        var a : Id<Int> = IdNative.Id(1);
        var b : IdNative<Int> = a.map(inc.lift());

        Sys.println(b);
    }

    public static function inc(a : Int) : Int return a + 1;
}