package haxez.check;

import haxe.EnumTools;
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
    Env(goal : Int, arbs : Array<ArbType<Dynamic>>);
}

class QuickChecks {

    public static inline function goal(env : QuickCheck) : Int return EnumValueTools.getParameters(env)[0];

    public static inline function arbs<T>(env : QuickCheck) : Array<ArbType<Dynamic>> return EnumValueTools.getParameters(env)[1];

    public static function arb<A, B>(env : QuickCheck, type : Class<B>, size : Int) : Option<A> {
        var a = env.arbs().find(function(a : ArbType<Dynamic>) : Bool return a.is(type));
        var b = function(a : ArbType<Dynamic>) : A return a.generate(env, size);
        return to(a).map(b);
    } 
    
    public static function generateInput<A, B>(env : QuickCheck, type : Class<B>, size : Int) : Option<A> {
        return env.arb(type, size);
    }

    public static function findSmallest<A>(env : QuickCheck, property : A -> Bool, input : A) : Array<A> {
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

    public static function forAll<A>(env : QuickCheck, property : A -> Bool, type : Class<A>) : Option<Report<A>> {
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

    public static function shrink<A>(env : QuickCheck, input : A) : Array<A> {
        var possible = env.findArb(input);
        return possible.map(function(a : ArbType<Dynamic>) : Array<A> {
            return cast a.shrink(input);
        }).getOrElse([]);
    }

    public static function findArb<A>(env : QuickCheck, input : A) : Option<ArbType<Dynamic>> {
        return to(env.arbs().find(function(a : ArbType<Dynamic>) : Bool return a.match(input)));
    }

    private static function to<A>(a : Null<A>) : Option<A> return a != null ? Some(a) : None;

    private static function isSome<A>(a : Option<A>) : Bool {
        return switch(a) { 
            case Some(_): true;
            case None: false;
        };
    }
}
