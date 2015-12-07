package haxez;

import haxez.F0;
import haxez.F1;
import haxez.T;
import haxez.Util;

typedef OptionNative<A> = haxe.ds.Option<A>;
typedef OptionCata<A, B> = {
    function Some(a : A) : B;
    function None() : B;
}

class OptionNatives {

    inline public static function fromOption<A>(x : AbstractOption<A>) : OptionNative<A> {
        return x.fold(
            new F1Lift(function(x) return OptionNative.Some(x)),
            new F0Lift(function() return OptionNative.None)
        );
    }

    inline public static function toOption<A>(x : OptionNative<A>) : AbstractOption<A> {
        return switch(x) {
            case Some(a): new Some(a);
            case None: new None();
        };
    }
}

class OptionZ {}

class AbstractOption<A> implements _1<OptionZ, A> {

    private function new() {}

    public function fold<B>(f : F1<A, B>, g : F0<B>) : B return Util.missing();

    public function cata<B>(cat : OptionCata<A, B>) : B return Util.missing();

    public function native() : OptionNative<A> return Util.missing();
}

abstract Option<A>(AbstractOption<A>) from AbstractOption<A> to AbstractOption<A> {

    inline function new(x : AbstractOption<A>) this = x;

    inline public function cata<B>(cat : OptionCata<A, B>) : B {
        var x : AbstractOption<A> = this;
        return x.cata(cat);
    }

    inline public function native() : OptionNative<A> {
        var x : AbstractOption<A> = this;
        return x.native();
    }

    @:to
    inline public function toOptionNative() : OptionNative<A> return OptionNatives.fromOption(this);

    @:from
    inline public static function fromOptionNative<A>(x : OptionNative<A>) : Option<A> {
        return OptionNatives.toOption(x);
    }
}

class Some<A> extends AbstractOption<A> {

    private var a : A;

    public function new(a : A) {
        super();
        this.a = a;
    }

    override public function fold<B>(f : F1<A, B>, g : F0<B>) : B return f.apply(this.a);

    override public function cata<B>(cat : OptionCata<A, B>) : B return cat.Some(this.a);

    override public function native() : OptionNative<A> return OptionNative.Some(this.a);
}

class None<A> extends AbstractOption<A> {

    public function new() {
        super();
    }

    override public function fold<B>(f : F1<A, B>, g : F0<B>) : B return g.apply();

    override public function cata<B>(cat : OptionCata<A, B>) : B return cat.None();

    override public function native() : OptionNative<A> return OptionNative.None;
}