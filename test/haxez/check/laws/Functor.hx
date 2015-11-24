package haxez.check.laws;

import haxez.Combinators as C;
import haxez.Types.Functor as F;

using haxez.Maybe;
using haxez.check.Env;
using haxez.check.QuickCheck;
using haxez.check.laws.Functor;

class Functor {

    public static function id<T>(create : T -> F<T>, f : F<T> -> T) : T -> Bool {
        return function(a : T) : Bool {
            var x = create(a).map(C.identity());
            var y = create(a);

            return f(x) == f(y);
        }
    }

    public static function composition<T>(create : T -> F<T>, f : F<T> -> T) : T -> Bool {
        return function(a : T) : Bool {
            var x = create(a).map(C.compose(C.identity())(C.identity()));
            var y = create(a).map(C.identity()).map(C.identity());

            return f(x) == f(y);
        }
    }

    public static function law1<T>(env : Env, create : T -> F<T>, f : F<T> -> T) : Maybe<Report<T>> {
        return env.forAll(id(create, f), Int);
    }

    public static function law2<T>(env : Env, create : T -> F<T>, f : F<T> -> T) : Maybe<Report<T>> {
        return env.forAll(composition(create, f), Int);
    }

    public static function laws<T>(env : Env) : (T -> F<T>) -> (F<T> -> T) -> Maybe<Report<T>> {
        return function(create : T -> F<T>, f : F<T> -> T) : Maybe<Report<T>> {
            var a = env.law1(create, f);
            var b = env.law2(create, f);

            return a.chain(function(x : Report<T>) : Maybe<Report<T>> {
                return b.map(function(y : Report<T>) : Report<T> {
                    return x.concat(y);
                });
            });
        };
    }
}
