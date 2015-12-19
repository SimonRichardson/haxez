package haxez;

typedef Iso<A, B> = {
    function to(a: A): B;
    function from(b: B): A;
}

class Iso<A, B> {

    private var f: F1<A, B>;
    private var g: F1<B, A>;

    public function new(f: F1<A, B>, g: F1<B, A>) {
        this.f = f;
        this.g = g;
    }

    public function to(a: A): B return f(a);

    public function from(b: B): A return g(b);
}