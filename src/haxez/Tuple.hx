package haxez;

import haxe.EnumTools;

enum Tuple2<A, B> {
    Tuple2(a : A, b : B);
}

class Tuples2 {

    public static inline function _1<A, B>(t : Tuple2<A, B>) : A return EnumValueTools.getParameters(t)[0];

    public static inline function _2<A, B>(t : Tuple2<A, B>) : B return EnumValueTools.getParameters(t)[1];
}