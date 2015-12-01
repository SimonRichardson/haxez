package examples;

using haxez.Coyoneda;

class CoyonedaExample {

    public static function main() {
        var arr = [1, 2, 3, 4, 5, 6, 7, 8, 9];
        var coy = Coyoneda.lift(arr);

        var res = coy.map(inc).map(toString);

        Sys.println(res.lower());
    }

    public static function inc(x : Int) return x + 1;

    public static function toString(x : Int) return '${x}';
}