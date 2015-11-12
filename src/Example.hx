package ;

import Sys;

using haxez.Option;

class Example {
    static function main() {
        Sys.println(Some(1).cata({
            Some: function(a : Int) : Option<String> return None,
            None: function() : Option<String> return Some("B")
        }).getOrElse("C"));
    }
}