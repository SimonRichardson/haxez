package haxez;

typedef F1<A, B> = A -> B;

class F1s {

    public static function apply<A, B>(f: F1<A, B>, a: A): B f(a);
}