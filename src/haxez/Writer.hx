package haxez;

using haxez.Tuple;
using haxez.Types;
using haxez.Writer;

class Writer<A, B:(Monoid<B>)> {
    
    public var run(default, null) : Void -> Tuple2<A, B>;

    public inline function new(run : Void -> Tuple2<A, B>) {
        this.run = run;
    }
}

class Writers {

    @:noUsing
    @:generic
    public static inline function of<A, B:(Monoid<B>)>(x : A) : Writer<A, B> {
        return new Writer(function() : Tuple2<A, B> {
            return Tuple2(x, new B());
        });
    }

    public static inline function chain<A, B, C:(Monoid<C>)>(w : Writer<A, C>, f : A -> Writer<B, C>) : Writer<B, C> {
        return new Writer(function() : Tuple2<B, C> {
            var result = w.run();
            var t = f(result._1()).run();
            return Tuple2(t._1(), result._2().concat(t._2()));
        });
    }

    public static inline function tell<A, B:(Monoid<B>)>(w : Writer<A, B>, y : B) : Writer<A, B> {
        return new Writer(function() : Tuple2<A, B> {
            var result = w.run();
            return Tuple2(null, result._2().concat(y));
        });
    }

    public static inline function map<A, B, C:(Monoid<C>)>(w : Writer<A, C>, f : A -> B) : Writer<B, C> {
        return w.chain(function(a : A) : Writer<B, C> {
            return Writers.of(f(a));
        });
    }

     public static inline function ap<A, B, C:(Monoid<C>)>(w : Writer<A -> B, C>, a : Writer<A, C>) : Writer<B, C> {
        return w.chain(function(f : A -> B) : Writer<B, C> {
            return a.map(f);
        });
    }
}