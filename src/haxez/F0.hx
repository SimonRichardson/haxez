package haxez;

typedef F0<A> = Void -> A;

class F0s {

    public static function apply<A>(f: F0<A>): A f();
}