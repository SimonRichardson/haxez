package haxez;

interface F2<A, B, C> {

    public function apply(a : A, b : B) : C;

    public function swap() : F2<B, A, C>;
}

class F2_<A, B, C> implements F2<A, B, C> {

    private var f : F2<A, B, C>;

    public function new(f : F2<A, B, C>) {
        this.f = f;
    }

    public function apply(a : A, b : B) : C return f.apply(a, b);

    public function swap() : F2<B, A, C> {
        return new F2Lift(function(a, b) {
            return this.f.apply(b, a);
        });
    }
}

class F2Lift<A, B, C> extends F2_<A, B, C> {

    private var g : A -> B -> C;

    public function new(f : A -> B -> C) {
        this.g = f;
        super(this);
    }

    override public function apply(a : A, b : B) : C return g(a, b);
}
