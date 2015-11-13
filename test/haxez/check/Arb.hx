package haxez.check;

using haxez.check.QuickCheck;

typedef ArbType<A> = {
    function generate(env : QuickCheck, size : Int) : A;
    function shrink(a : A) : Array<A>;
    function is<B>(a : Class<B>) : Bool;
    function match<B>(a : B) : Bool;
}

class Arb {

    public static var String : ArbType<String> = new StringArb();

    public static var Int : ArbType<Int> = new IntArb();
}

private class Rnd {
    public static function randomRange(a : Int, b : Int) : Int {
        return Math.floor(Math.random() * (b - a) + a);
    }
}

class StringArb {

    public function new() {}
    
    public function generate(env : QuickCheck, size : Int) : String {
        var accum = [];
        var length = Rnd.randomRange(0, size);
        for(i in 0...length) {
            accum.push(String.fromCharCode(Math.floor(Rnd.randomRange(32, 126))));
        }
        return accum.join("");
    }
    
    public function shrink(a : String) : Array<String> {
        var accum = [""];
        var x = a.length;

        while(x > 0) {
            x = Math.floor(x / 2);
            if(x > 0) {
                accum.push(a.substr(0, a.length - x));
            }
        }
        return accum;
    }

    public function is<T>(a : Class<T>) : Bool {
        return Type.getClassName(a) == "String";
    }

    public function match<T>(a : T) : Bool {
        return Type.getClassName(Type.getClass(a)) == "String";
    }
}

class IntArb {

    public function new() {}
    
    public function generate(env : QuickCheck, size : Int) : Int {
        var variance = Math.floor(Math.pow(2, 53) / env.goal());
        return Rnd.randomRange(-variance, variance);
    }
    
    public function shrink(a : Int) : Array<Int> {
        var accum = [0];
        var x = a;

        while(x > 0) {
            x = Math.floor(x / 2);
            if(x > 0) {
                accum.push(a - x);
            }
        }
        return accum;
    }

    public function is<T>(a : Class<T>) : Bool {
        return Type.getClassName(a) == "String";
    }

    public function match<T>(a : T) : Bool {
        return Type.getClassName(Type.getClass(a)) == "String";
    }
}