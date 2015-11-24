package haxez.check;

using haxez.Maybe;
using haxez.check.Env;
using haxez.check.QuickCheck;

class Arb {

    public static inline function addAnyVal(env : Env) : Env return ArbAnyVal.get().concat(env);

    public static inline function addBool(env : Env) : Env return ArbBool.get().concat(env);

    public static inline function addFloat(env : Env) : Env return ArbFloat.get().concat(env);

    public static inline function addInt(env : Env) : Env return ArbInt.get().concat(env);

    public static inline function addString(env : Env) : Env return ArbString.get().concat(env);
}

class AnyVal {}

class ArbAnyVal {

    public static function get() : Env return arb(Env(0));

    private static function arb(env : Env) : Env {
        return env.method("arb", Helpers.strictEquals(AnyVal), function(env : Env, args : Array<Dynamic>) : Dynamic {
            var values : Array<Dynamic> = [Bool, Float, Int, String];
            var index = Rnd.randomRange(0, values.length);
            var value = env.call("arb", [values[index]].concat([for (i in 1...args.length) args[i]]));
            return switch (value) {
                case Some(a): a;
                case None: throw "Unable to generate value for AnyVal";
            }
        });
    }
}

class ArbBool {

    public static function get() : Env return shrink(arb(Env(0)));

    private static function arb(env : Env) : Env {
        return env.method("arb", Helpers.strictEquals(Bool), function(env : Env, args : Array<Dynamic>) : Dynamic {
            return Rnd.randomRange(0, 1) == 1;
        });
    }

    private static function shrink(env : Env) : Env {
        return env.method("shrink", Helpers.isBool(), function(env : Env, args : Array<Dynamic>) : Dynamic {
            return [args[0]];
        });
    }
}

class ArbFloat {

    public static function get() : Env return shrink(arb(Env(0)));

    private static function arb(env : Env) : Env {
        return env.method("arb", Helpers.strictEquals(Float), function(env : Env, args : Array<Dynamic>) : Dynamic {
            var variance = Math.pow(2, 32) / env.goal();
            return Rnd.randomRangeF(-variance, variance);
        });
    }

    private static function shrink(env : Env) : Env {
        return env.method("shrink", Helpers.isFloat(), function(env : Env, args : Array<Dynamic>) : Dynamic {
            var a = cast(args[0], Float);
            var accum = [0.0];
            var x = a;

            while(x > 0) {
                x = x / 2;
                if(x > 0) {
                    accum.push(a - x);
                }
            }
            return accum;
        });
    }
}

class ArbInt {

    public static function get() : Env return shrink(arb(Env(0)));

    private static function arb(env : Env) : Env {
        return env.method("arb", Helpers.strictEquals(Int), function(env : Env, args : Array<Dynamic>) : Dynamic {
            var variance = Math.floor(Math.pow(2, 32) / env.goal());
            return Rnd.randomRange(-variance, variance);
        });
    }

    private static function shrink(env : Env) : Env {
        return env.method("shrink", Helpers.isInt(), function(env : Env, args : Array<Dynamic>) : Dynamic {
            var a = cast(args[0], Int);
            var accum = [0];
            var x = a;

            while(x > 0) {
                x = Math.floor(x / 2);
                if(x > 0) {
                    accum.push(a - x);
                }
            }
            return accum;
        });
    }
}

class ArbString {

    public static function get() : Env return shrink(arb(Env(0)));

    private static function arb(env : Env) : Env {
        return env.method("arb", Helpers.strictEquals(String), function(env : Env, args : Array<Dynamic>) : Dynamic {
            var accum = [];
            var length = Rnd.randomRange(0, cast(args[1], Int));
            for(i in 0...length) {
                accum.push(String.fromCharCode(Math.floor(Rnd.randomRange(32, 126))));
            }
            return accum.join("");
        });
    }

    private static function shrink(env : Env) : Env {
        return env.method("shrink", Helpers.isString(), function(env : Env, args : Array<Dynamic>) : Dynamic {
            var accum = [""];
            var str = cast(args[0], String);
            var x = str.length;

            while(x > 0) {
                x = Math.floor(x / 2);
                if(x > 0) {
                    accum.push(str.substr(0, str.length - x));
                }
            }
            return accum;
        });
    }
}

private class Helpers {

    public static function strictEquals<A, B>(x : A) : Env -> Array<B> -> Bool {
        return function(env : Env, y : Array<B>) : Bool {
            return cast y[0] == cast x;
        };
    }

    public static function isBool<A>() : Env -> Array<A> -> Bool {
        return function(env : Env, x : Array<A>) : Bool {
            return Std.is(x[0], Bool);
        };
    }

    public static function isFloat<A>() : Env -> Array<A> -> Bool {
        return function(env : Env, x : Array<A>) : Bool {
            return Std.is(x[0], Float);
        };
    }

    public static function isInt<A>() : Env -> Array<A> -> Bool {
        return function(env : Env, x : Array<A>) : Bool {
            return Std.is(x[0], Int);
        };
    }

    public static function isString<A>() : Array<A> -> Bool {
        return function(x : Array<A>) : Bool {
            return Std.is(x[0], String);
        };
    }
}

private class Rnd {
    public static function randomRange(a : Int, b : Int) : Int {
        return Math.floor(Math.random() * (b - a) + a);
    }

    public static function randomRangeF(a : Float, b : Float) : Float {
        return Math.random() * (b - a) + a;
    }
}
