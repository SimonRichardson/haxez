package ;

import Sys;

using haxez.Option;

class Example {
    static function main() {
        var f = function(a : Int) : Int return a + 1;
        Sys.println(Some(f).ap(Some(1)));
    }
}