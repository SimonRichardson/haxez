package haxez.check.laws;

import haxez.Combinators as C;
import haxez.Types.Functor as F;

using haxez.Option;
using haxez.check.Env;
using haxez.check.QuickCheck;
using haxez.check.laws.Functor;

class Functor {

    public static function id<A>(create : A -> F<A>, f : F<A> -> A) : A -> Bool {
        return function(a : A) : Bool {
            Sys.println(create(a));
            var x = create(a).map(C.identity());
            var y = create(a);

            return f(x) == f(y);
        }
    }

    public static function composition<A>(create : A -> F<A>, f : F<A> -> A) : A -> Bool {
        return function(a : A) : Bool {
            var x = create(a).map(C.compose(C.identity())(C.identity()));
            var y = create(a).map(C.identity()).map(C.identity());

            return f(x) == f(y);
        }
    }

    public static function law1<A>(env : Env, create : A -> F<A>, f : F<A> -> A) : Option<Report<A>> {
        return env.forAll(id(create, f), Int);
    }

    public static function law2<A>(env : Env, create : A -> F<A>, f : F<A> -> A) : Option<Report<A>> {
        return env.forAll(composition(create, f), Int);
    }

    public static function laws<A>(env : Env) : (A -> F<A>) -> (F<A> -> A) -> Option<Report<A>> {
        return function(create : A -> F<A>, f : F<A> -> A) : Option<Report<A>> {
            var a = env.law1(create, f);
            var b = env.law2(create, f);

            return a.chain(function(x : Report<A>) : Option<Report<A>> {
                return b.map(function(y : Report<A>) : Report<A> {
                    return x.merge(y);
                });
            });
        };
    }
}
