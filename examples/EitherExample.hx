package examples;

import haxez.Either;

using haxez.F1;

class EitherExample {

    public static function main() {
        var a : Either<String, Int> = EitherNative.Right(1);
        var b : EitherNative<String, Int> = a.flatMap(inc.lift());

        var c = switch(b) {
            case Left(x): 'Left(${x})';
            case Right(x): 'Right(${x})';
        }

        var f = haxez.Either.monad();
        var d = f.flatMap(cast inc.lift(), a);

        trace(c, d);
    }

    public static function inc(a : Int) : Either<String, Int> return new Right(a + 1);
}