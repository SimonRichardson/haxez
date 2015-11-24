package haxez.check;

import haxe.Constraints;
import haxe.EnumTools;
import haxe.ds.ObjectMap;
import haxe.unit.TestCase;

using Lambda;
using haxez.Maybe;
using haxez.check.Arb;
using haxez.check.Env;
using haxez.check.QuickCheck;

enum Report<A> {
    Failure(input : Array<A>, tries : Int);
}

class Reports {

    public static inline function input<A>(rep : Report<A>) : Array<A> return EnumValueTools.getParameters(rep)[0];

    public static inline function tries<A>(rep : Report<A>) : Int return EnumValueTools.getParameters(rep)[1];

    public static function concat<A>(a : Report<A>, b : Report<A>) : Report<A> {
        return Failure(a.input().concat(b.input()), a.tries() + b.tries());
    }
}

class QuickCheck {

    private var env : Env;

    public function new(env : Env) {
        this.env = env;
    }

    public static function forAll<A, B>(env : Env, property : A -> Bool, type : Dynamic) : Maybe<Report<A>> {
        var check = new QuickCheck(env);

        for (i in 0...check.goal()) {
            var result = check.generateInput(type, i).chain(
                function(input : A) : Maybe<Report<A>> {
                    if (!property(input)) {
                        return Some(Failure(
                            check.findSmallest(property, input),
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

    private function goal() : Int {
        return this.env.goal();
    }

    private function generateInput<A, B>(type : Dynamic, size : Int) : Maybe<A> {
        return this.env.call("arb", [type, size]);
    }

    private function findSmallest<A>(property : A -> Bool, input : A) : Array<A> {
        var smallest = [input];
        return this.env.call("shrink", smallest).map(function(shrunken : Array<A>) : Array<A> {
            for (i in 0...shrunken.length) {
                var arg = shrunken[(shrunken.length - 1) - i];
                smallest.push(arg);
                if(property(arg)) 
                    break;
            }

            return smallest;
        }).getOrElse([]);
    }
}

private class Helpers {

    public static function isSome<A>(a : Maybe<A>) : Bool {
        return switch(a) { 
            case Some(_): true;
            case None: false;
        };
    }
}
