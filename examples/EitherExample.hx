package examples;

import haxez.Either;

using haxez.F1;

class EitherExample {

    public static function main() {
        var a : Either<String, Int> = EitherNative.Right(1);
        var b : EitherNative<String, Int> = a.map(inc.lift());

        var c = switch(b) {
            case Left(x): 'Left(${x})';
            case Right(x): 'Right(${x})';
        }

        trace(c);
    }

    public static function inc(a : Int) : Int return a + 1;
}