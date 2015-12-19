package haxez;

import haxe.ds.GenericStack;
import haxe.ds.Vector;

import haxez.F0;
import haxez.PhantomData;

using haxez.Morphism;

enum Morphism<A, B> {
    Morphism(m: GenericStack<Vector<F0<Void>>>, p: Phantom<A, B>);
}

class Morphisms {

    @:noUsing
    public static inline function new<A>() : Morphism<A, A> {
        var m = new GenericStack();
        m.add(new Vector());
        return Morphism(m, new PhantomData<A, A>());
    }

    public static inline function run<A, B>(self: Morphism<A, B>, x: A): B {
        var res = x;
        for (fns in self.iterator()) {
            for (f in fns) {
                res = f(res);
            }
        }
        return res;
    }

    public static inline function iterator<A, B>(self: Morphism<A, B>): Iterator<A> {
        return switch (self) {
            case Morphism(m, _): m.iterator();
        };
    }
}