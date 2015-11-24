package haxez.check.laws;

import haxez.Combinators as C;
import haxez.Types.Monad as M;

using haxez.Maybe;
using haxez.check.Env;
using haxez.check.QuickCheck;
using haxez.check.laws.Monad;

class Monad {

    public static function leftIdentity<T>(create : Void -> M<T>, f : M<T> -> T) : T -> Bool {
        var type = create();
        return function(a : T) : Bool {
            var x = type.of(a).chain(function(a) return type.of(a));
            var y = C.apply(type.of)(a);

            return f(x) == f(y);
        };
    }

    public static function rightIdentity<T>(create : Void -> M<T>, f : M<T> -> T) : T -> Bool {
        var type = create();
        return function(a : T) : Bool {
            var x = type.of(a).chain(type.of);
            var y = type.of(a);

            return f(x) == f(y);
        };
    }

    public static function associativity<T>(create : Void -> M<T>, f : M<T> -> T) : T -> Bool {
        var type = create();
        return function(a : T) : Bool {
            var x = type.of(a).chain(type.of).chain(type.of);
            var y = type.of(a).chain(function(x) return type.of(x).chain(type.of));

            return f(x) == f(y);
        };
    }

    public static function law1<T>(env : Env, type : Void -> M<T>, f : M<T> -> T) : Maybe<Report<T>> {
        return env.forAll(leftIdentity(type, f), Int);
    }

    public static function law2<T>(env : Env, type : Void -> M<T>, f : M<T> -> T) : Maybe<Report<T>> {
        return env.forAll(rightIdentity(type, f), Int);
    }

    public static function law3<T>(env : Env, type : Void -> M<T>, f : M<T> -> T) : Maybe<Report<T>> {
        return env.forAll(associativity(type, f), Int);
    }

    public static function laws<T>(env : Env) : (Void -> M<T>) -> (M<T> -> T) -> Maybe<Report<T>> {
        return function(type : Void -> M<T>, f : M<T> -> T) : Maybe<Report<T>> {
            var a = env.law1(type, f);
            var b = env.law2(type, f);
            var c = env.law3(type, f);

            return a.chain(function(x : Report<T>) : Maybe<Report<T>> {
                return b.chain(function(y : Report<T>) : Maybe<Report<T>> {
                    return c.map(function(z : Report<T>) : Report<T> {
                        return x.concat(y).concat(z);
                    });
                });
            });
        };
    }
}
