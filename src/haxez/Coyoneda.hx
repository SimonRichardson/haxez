package haxez;

using haxez.F1;

using haxez.Morphism;
using haxez.Functor;
using haxez.Param;

class Coyoneda<A: Covariant<A, Dynamic>, B> {

    private var point: A;
    private var morph: Morphism<A, B>;

    public function new(point: A) {
        this.point = point;
        this.morph = Morphisms.new();
    }

    public function fmap<F: F1<A, B>>(f: F): Covariant<B> {
        return new Coyoneda(point, morph.tail(f));
    }

    public function run() : B {
        return point.fmap(function(a) morph.run(a));
    }
}