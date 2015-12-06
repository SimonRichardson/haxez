package examples;

import haxez.Coyoneda;
import haxez.Functor;
import haxez.T;

using haxez.F1;

class CoyonedaExample {

    public static function main() {
        // Coyoneda Fusion
        var a = haxez.Coyoneda.lift(new Seq([1, 2, 3]));
        var b = a.map(inc.lift()).map(inc.lift());

        trace(b.run(Seq.functor()));
    }

    public static function inc(a : Int) : Int return a + 1;
}

class Seq<A> implements _1<A, A> {

    private var a : Array<A>;

    public function new(a : Array<A>) this.a = a;

    inline public static function functor<Z>() : Functor<Z> return new SeqOfFunctor<Z>();

    @:arrayAccess
    public function get(x : Int) : A return a[x];

    @:arrayAccess
    public function set(x : Int, y : A) : A {
        a[x] = y;
        return y;
    }

    public function map<B>(f : F1<A, B>) : Seq<B> {
        return new Seq(a.map(function(x) {
            return f.apply(x);
        }));
    };
}

class SeqOfFunctor<T> implements Functor<T> {

    public function new() {}

    public function map<A, B>(f : F1<A, B>, fa : _1<T, A>) : _1<T, B> {
        var x : Seq<A> = cast fa;
        return cast x.map(f);
    }
}