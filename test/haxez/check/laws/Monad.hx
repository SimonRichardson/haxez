package haxez.check.laws;

import haxez.Combinators as C;
import haxez.Types.Monad as M;

using haxez.Maybe;
using haxez.check.Env;
using haxez.check.QuickCheck;
using haxez.check.laws.Monad;

class Monad {

    public static function leftIdentity<A>(create : Void -> M<A>, f : M<A> -> A) : A -> Bool {
        var type = create();
        return function(a : A) : Bool {
            var x = type.of(a).chain(function(a) return type.of(a));
            var y = C.apply(type.of)(a);

            return f(x) == f(y);
        };
    }

    public static function rightIdentity<A>(create : Void -> M<A>, f : M<A> -> A) : A -> Bool {
        var type = create();
        return function(a : A) : Bool {
            var x = type.of(a).chain(type.of);
            var y = type.of(a);

            return f(x) == f(y);
        };
    }

    public static function associativity<A>(create : Void -> M<A>, f : M<A> -> A) : A -> Bool {
        var type = create();
        return function(a : A) : Bool {
            var x = type.of(a).chain(type.of).chain(type.of);
            var y = type.of(a).chain(function(x) return type.of(x).chain(type.of));

            return f(x) == f(y);
        };
    }

    public static function law1<A>(env : Env, type : Void -> M<A>, f : M<A> -> A) : Maybe<Report<A>> {
        return env.forAll(leftIdentity(type, f), Int);
    }

    public static function law2<A>(env : Env, type : Void -> M<A>, f : M<A> -> A) : Maybe<Report<A>> {
        return env.forAll(rightIdentity(type, f), Int);
    }

    public static function law3<A>(env : Env, type : Void -> M<A>, f : M<A> -> A) : Maybe<Report<A>> {
        return env.forAll(associativity(type, f), Int);
    }

    public static function laws<A>(env : Env) : (Void -> M<A>) -> (M<A> -> A) -> Maybe<Report<A>> {
        return function(type : Void -> M<A>, f : M<A> -> A) : Maybe<Report<A>> {
            var a = env.law1(type, f);
            var b = env.law2(type, f);
            var c = env.law3(type, f);

            return a.chain(function(x : Report<A>) : Maybe<Report<A>> {
                return b.chain(function(y : Report<A>) : Maybe<Report<A>> {
                    return c.map(function(z : Report<A>) : Report<A> {
                        return x.merge(y).merge(z);
                    });
                });
            });
        };
    }
}
