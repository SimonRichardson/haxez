package ;

import Sys;

using haxez.Option;
using haxez.These;
using haxez.Writer;

class Example {
    static function main() {
        var f = function(a : Int) : Int return a + 1;
        Sys.println(Some(f).ap(Some(1)));

        Sys.println(This(1).left());

        var w : Writer<String, Str> = Writers.of("Hello");
        Sys.println(w.run());
    }
}

class Str {

    private var val : String;

    public function new() {
        this.val = "";
    }

    public function empty() : Str {
        return new Str();
    }

    public function concat(a : Str) : Str {
        var x = new Str();
        x.val = this.val + a.val;
        return x;
    }
}
