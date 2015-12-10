package examples;

import haxez.Option;

using haxez.F1;

class OptionExample {

    public static function main() {
        var a : Option<Int> = OptionNative.Some(1);
        var b : OptionNative<Int> = a.map(inc.lift());

        var c = switch(b) {
            case Some(x): 'Some(${x})';
            case None: 'None()';
        }

        trace(c);
    }

    public static function inc(a : Int) : Int return a + 1;
}