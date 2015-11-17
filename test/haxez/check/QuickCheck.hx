package haxez.check;

import haxe.EnumTools;
import haxe.ds.ObjectMap;
import haxe.unit.TestCase;

using Lambda;
using haxez.Option;
using haxez.check.Arb;
using haxez.check.QuickCheck;
using haxez.check.QuickCheck.Report;

enum Report<A> {
    Failure(input : Array<A>, tries : Int);
}

class Reports {

    public static inline function input<A>(rep : Report<A>) : Array<A> return EnumValueTools.getParameters(rep)[0];

    public static inline function tries<A>(rep : Report<A>) : Int return EnumValueTools.getParameters(rep)[1];
}

enum PropMethod<A, B> {
    Method(predicate : A -> Bool, f : Array<Dynamic> -> B);
}

enum QuickCheck {
    Env(goal : Int);
    Values(check : QuickCheck, values : Map<String, Array<PropMethod<Dynamic, Dynamic>>>);
}

class QuickChecks {

    public static inline function goal(env : QuickCheck) : Int {
        return switch(env) {
            case Env(x): x;
            case Values(x, _): x.goal();
        };
    }

    public static inline function values(env : QuickCheck) : Map<String, Array<PropMethod<Dynamic, Dynamic>>> {
        return switch (env) {
            case Env(_): new Map();
            case Values(x, y): Helpers.extend(Helpers.extend(new Map(), x.values()), y);
        }
    }

    public static function method<A>(env : QuickCheck, name : String, predicate : Dynamic -> Bool, f : Array<Dynamic> -> A) : QuickCheck {
        var method = [Method(predicate, f)];
        return switch (env) {
            case Env(goal): Values(env, [name => method]);
            case Values(check, values): 
                var x = Reflect.copy(values);
                var y = [name => (x.exists(name) ? x.get(name).concat(method) : method)];
                Values(check, Helpers.extend(x, y));
        }
    }

    public static function forAll<A, B>(env : QuickCheck, property : A -> Bool, type : Dynamic) : Option<Report<A>> {
        for (i in 0...env.goal()) {
            var result = env.generateInput(type, i).chain(
                function(input : A) : Option<Report<A>> {
                    if (!property(input)) {
                        return Some(Failure(
                            env.findSmallest(property, input),
                            i
                        ));
                    }
                    return None;
                }
            );
            

            if (Helpers.isSome(result)) {
                return result;
            }
        }
        return None;
    }

    private static function generateInput<A, B>(env : QuickCheck, type : Dynamic, size : Int) : Option<A> {
        return env.call("arb", [type, size]);
    }

    private static function call<A>(env : QuickCheck, name : String, args : Array<Dynamic>) : Option<A> {
        return findRegistered(env, name, args).map(function(f : Array<Dynamic> -> A) : A {
            return f(args);
        });
    }

    private static function findSmallest<A>(env : QuickCheck, property : A -> Bool, input : A) : Array<A> {
        var smallest = [input];
        return env.call("shrink", smallest).map(function(shrunken : Array<A>) : Array<A> {
            for (i in 0...shrunken.length) {
                var arg = shrunken[(shrunken.length - 1) - i];
                smallest.push(arg);
                if(property(arg)) 
                    break;
            }

            return smallest;
        }).getOrElse([]);
    }

    private static function findRegistered<A>(env : QuickCheck, name : String, args : Array<Dynamic>) : Option<Array<Dynamic> -> A> {
        return Helpers.option(env.values().get(name)).chain(function(a : Array<PropMethod<Dynamic, Dynamic>>) : Option<Array<Dynamic> -> A> {
            var possible = Helpers.option(a.find(function(a : PropMethod<Dynamic, Dynamic>) : Bool {
                return switch (a) {
                    case Method(predicate, _): predicate(args);
                };
            }));
            return possible.map(function(a : PropMethod<Dynamic, Dynamic>) : Array<Dynamic> -> A {
                return switch (a) {
                    case Method(_, f): f; 
                };
            });
        });
    }
}

private class Helpers {

    public static function option<A>(a : Null<A>) : Option<A> return a != null ? Some(a) : None;

    public static function isSome<A>(a : Option<A>) : Bool {
        return switch(a) { 
            case Some(_): true;
            case None: false;
        };
    }

    public static function array<A>(it:Iterator<A>) : Array<A> {
        var r = new Array<A>();
        for (e in it) r.push(e);
        return r;
    }

    public static function extend<K, V>(a : Map<K, V>, b : Map<K, V>) : Map<K, V> {
        for (i in b.keys()) a.set(i, b[i]);
        return a;
    }
}
