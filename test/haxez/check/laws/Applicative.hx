package haxez.check.laws;

import haxez.Combinators as C;
import haxez.Types.Applicative as A;

using haxez.Maybe;
using haxez.check.Env;
using haxez.check.QuickCheck;
using haxez.check.laws.Applicative;

// TODO: Workout away to do this without casting everywhere!
class Applicative {

    public static function id<T>(create : Void -> A<T>, f : A<T> -> T) : T -> Bool {
        var type = create();
        return function(a : T) : Bool {
            var x = type.of(cast C.identity()).ap(type.of(a));
            var y = type.of(a);

            return f(x) == f(y);
        };
    }

    public static function composition<T>(create : Void -> A<T>, f : A<T> -> T) : T -> Bool {
        var type = create();
        return function(a : T) : Bool {
            var x = type.of(cast C.compose).ap(type.of(cast C.identity())).ap(type.of(cast C.identity())).ap(type.of(a));
            var y = type.of(cast C.identity()).ap(type.of(cast C.identity()).ap(type.of(a)));

            return f(x) == f(y);
        };
    }

    public static function homomorphism<T>(create : Void -> A<T>, f : A<T> -> T) : T -> Bool {
        var type = create();
        return function(a : T) : Bool {
            var x = type.of(cast C.identity()).ap(type.of(a));
            var y = type.of(cast C.identity()(a));

            return f(x) == f(y);
        };
    }

    public static function interchange<T>(create : Void -> A<T>, f : A<T> -> T) : T -> Bool {
        var type = create();
        return function(a : T) : Bool {
            var x = type.of(cast C.identity()).ap(type.of(a));
            var y = type.of(cast C.thrush(a)).ap(type.of(cast C.identity()));

            return f(x) == f(y);
        };
    }

    public static function law1<T>(env : Env, type : Void -> A<T>, f : A<T> -> T) : Maybe<Report<T>> {
        return env.forAll(id(type, f), Int);
    }

    public static function law2<T>(env : Env, type : Void -> A<T>, f : A<T> -> T) : Maybe<Report<T>> {
        return env.forAll(composition(type, f), Int);
    }

    public static function law3<T>(env : Env, type : Void -> A<T>, f : A<T> -> T) : Maybe<Report<T>> {
        return env.forAll(homomorphism(type, f), Int);
    }

    public static function law4<T>(env : Env, type : Void -> A<T>, f : A<T> -> T) : Maybe<Report<T>> {
        return env.forAll(interchange(type, f), Int);
    }

    public static function laws<T>(env : Env) : (Void -> A<T>) -> (A<T> -> T) -> Maybe<Report<T>> {
        return function(type : Void -> A<T>, f : A<T> -> T) : Maybe<Report<T>> {
            var a = env.law1(type, f);
            var b = env.law2(type, f);
            var c = env.law3(type, f);
            var d = env.law4(type, f);

            return a.chain(function(w : Report<T>) : Maybe<Report<T>> {
                return b.chain(function(x : Report<T>) : Maybe<Report<T>> {
                    return c.chain(function(y : Report<T>) : Maybe<Report<T>> {
                        return d.map(function(z : Report<T>) : Report<T> {
                            return w.concat(x).concat(y).concat(z);
                        });
                    });
                });
            });
        };
    }
}
