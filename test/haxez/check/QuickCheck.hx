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

enum QuickCheck {
    Env(goal : Int, arbs : ObjectMap<ArbType<Dynamic>, Class<Dynamic>>);
}

class QuickChecks {

    public static inline function goal(env : QuickCheck) : Int return EnumValueTools.getParameters(env)[0];

    public static inline function arbs(env : QuickCheck) : ObjectMap<ArbType<Dynamic>, Class<Dynamic>> return EnumValueTools.getParameters(env)[1];

    public static function forAll<A, B>(env : QuickCheck, property : A -> Bool, type : Class<B>) : Option<Report<A>> {
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
            

            if (isSome(result)) {
                return result;
            }
        }
        return None;
    }

    private static function generateInput<A, B>(env : QuickCheck, type : Class<B>, size : Int) : Option<A> {
        return env.arb(type, size);
    }

    private static function arb<A, B>(env : QuickCheck, type : Class<B>, size : Int) : Option<A> {
        return env.findArbFromType(type).map(function(a : ArbType<Dynamic>) : A { 
            return a.generate(env, size); 
        });
    } 
    
    private static function findSmallest<A>(env : QuickCheck, property : A -> Bool, input : A) : Array<A> {
        var shrunken = env.shrink(input);
        var smallest = [input];

        for (i in 0...shrunken.length) {
            var arg = shrunken[(shrunken.length - 1) - i];
            smallest.push(arg);
            if(property(arg)) 
                break;
        }

        return smallest;
    }

    private static function shrink<A>(env : QuickCheck, input : A) : Array<A> {
        return env.findArbFromInput(input).map(function(a : ArbType<Dynamic>) : Array<A> {
            return cast a.shrink(input);
        }).getOrElse([]);
    }

    private static function findArbFromType<A>(env : QuickCheck, type : Class<A>) : Option<ArbType<A>> {
        var arbs = env.arbs();
        return cast arbs.keys().array().find(function(a : ArbType<Dynamic>) : Bool {
            return type == arbs.get(a);
        }).option();
    }

    private static function findArbFromInput<A>(env : QuickCheck, input : A) : Option<ArbType<A>> {
        var arbs = env.arbs();
        return cast arbs.keys().array().find(function(a : ArbType<Dynamic>) : Bool {
            return Type.getClass(input) == arbs.get(a);
        }).option();
    }

    private static function option<A>(a : Null<A>) : Option<A> return a != null ? Some(a) : None;

    private static function isSome<A>(a : Option<A>) : Bool {
        return switch(a) { 
            case Some(_): true;
            case None: false;
        };
    }

    private static function array<A>(it:Iterator<A>) : Array<A> {
        var r = new Array<A>();
        for (e in it) r.push(e);
        return r;
    }
}
