package haxez.check;

import haxe.Constraints;

using Lambda;
using haxez.Maybe;
using haxez.check.Arb;
using haxez.check.Env;
using haxez.check.QuickCheck;

enum Env {
    Env(goal : Int);
    Values(check : Env, values : Map<String, Array<PropMethod>>);
}

class Envs {

    public static inline function goal(env : Env) : Int {
        return switch(env) {
            case Env(x): x;
            case Values(x, _): x.goal();
        };
    }

    public static inline function values(env : Env) : Map<String, Array<PropMethod>> {
        return switch (env) {
            case Env(_): new Map();
            case Values(x, y): Helpers.extend(Helpers.extend(new Map(), x.values()), y);
        }
    }

    public static function method<A>(env : Env, name : String, predicate : Function, f : Function) : Env {
        var method = [Method(predicate, f)];
        return switch (env) {
            case Env(goal): Values(env, [name => method]);
            case Values(check, values): 
                var x = Helpers.copy(values);
                var y = [name => (x.exists(name) ? x.get(name).concat(method) : method)];
                Values(check, Helpers.extend(x, y));
        }
    }

    public static function call<A>(env : Env, name : String, args : Array<Dynamic>) : Maybe<A> {
        return env.findRegistered(name, args).map(function(f : Function) : A {
            return f(args);
        });
    }

    private static function findRegistered<A>(env : Env, name : String, args : Array<Dynamic>) : Maybe<Function> {
        return Helpers.option(env.values().get(name)).chain(function(a : Array<PropMethod>) : Maybe<Function> {
            var possible = Helpers.option(a.find(function(a : PropMethod) : Bool {
                return switch (a) {
                    case Method(predicate, _): predicate(args);
                };
            }));
            return possible.map(function(a : PropMethod) : Function {
                return switch (a) {
                    case Method(_, f): f; 
                };
            });
        });
    }
}

private enum PropMethod {
    Method(predicate : Function, f : Function);
}

private class Helpers {

    public static function option<A>(a : Null<A>) : Maybe<A> return a != null ? Some(a) : None;

    public static function extend<K, V>(a : Map<K, V>, b : Map<K, V>) : Map<K, V> {
        for (i in b.keys()) a.set(i, b[i]);
        return a;
    }

    public static function copy(a : Map<String, Array<PropMethod>>) : Map<String, Array<PropMethod>> {
        var b = new Map<String, Array<PropMethod>>();
        for (i in a.keys()) b.set(i, a[i]);
        return b;
    }
}
