package haxez.check;

using haxez.Maybe;
using haxez.check.Env;
using haxez.check.QuickCheck;

class Arb {

    public static inline function addAnyVal(env : Env) : Env {
        return ArbAnyVal.add(env);
    }

    public static inline function addBool(env : Env) : Env {
        return ArbBool.add(env);
    }

    public static inline function addFloat(env : Env) : Env {
        return ArbFloat.add(env);
    }

    public static inline function addInt(env : Env) : Env {
        return ArbInt.add(env);
    }

    public static inline function addString(env : Env) : Env {
        return ArbString.add(env);
    }
}

class AnyVal {}

class ArbAnyVal {

    public static function add(env : Env) : Env {
        return env.method("arb", Helpers.strictEquals(AnyVal), function(args : Array<Dynamic>) : Dynamic {
            var values : Array<Dynamic> = [Bool, Float, Int, String];
            var index = Rnd.randomRange(0, values.length);
            var value = env.call("arb", [values[index]].concat([for (i in 1...args.length) args[i]]));
            return switch (value) {
                case Some(a): a;
                case None: throw "Unable to generate value";
            }
        });
    }
}

class ArbBool {

    public static function add(env : Env) : Env {
        return env.method("arb", Helpers.strictEquals(Bool), function(args : Array<Dynamic>) : Dynamic {
            return Rnd.randomRange(0, 1) == 1;
        })
        .method("shrink", Helpers.isBool(), function(args : Array<Dynamic>) : Dynamic {
            return [args[0]];
        });
    }
}

class ArbFloat {

    public static function add(env : Env) : Env {
        return env.method("arb", Helpers.strictEquals(Float), function(args : Array<Dynamic>) : Dynamic {
            var variance = Math.pow(2, 32) / env.goal();
            return Rnd.randomRangeF(-variance, variance);
        })
        .method("shrink", Helpers.isFloat(), function(args : Array<Dynamic>) : Dynamic {
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

    public static function add(env : Env) : Env {
        return env.method("arb", Helpers.strictEquals(Int), function(args : Array<Dynamic>) : Dynamic {
            var variance = Math.floor(Math.pow(2, 32) / env.goal());
            return Rnd.randomRange(-variance, variance);
        })
        .method("shrink", Helpers.isInt(), function(args : Array<Dynamic>) : Dynamic {
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

    public static function add(env : Env) : Env {
        return env.method("arb", Helpers.strictEquals(String), function(args : Array<Dynamic>) : Dynamic {
            var accum = [];
            var length = Rnd.randomRange(0, cast(args[1], Int));
            for(i in 0...length) {
                accum.push(String.fromCharCode(Math.floor(Rnd.randomRange(32, 126))));
            }
            return accum.join("");
        })
        .method("shrink", Helpers.isString(), function(args : Array<Dynamic>) : Dynamic {
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

    public static function strictEquals<A, B>(x : A) : Array<B> -> Bool {
        return function(y : Array<B>) : Bool {
            return cast y[0] == cast x;
        };
    }

    public static function isBool<A>() : Array<A> -> Bool {
        return function(x : Array<A>) : Bool {
            return Std.is(x[0], Bool);
        };
    }

    public static function isFloat<A>() : Array<A> -> Bool {
        return function(x : Array<A>) : Bool {
            return Std.is(x[0], Float);
        };
    }

    public static function isInt<A>() : Array<A> -> Bool {
        return function(x : Array<A>) : Bool {
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
