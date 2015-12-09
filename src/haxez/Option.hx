package haxez;

import haxez.F0;
import haxez.F1;
import haxez.MonadPlus;
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

    public static function none<A>() : Option<A> return new None();

    inline public static function monadPlus() : IMonadPlus<OptionZ> {
        return new OptionOfMonadPlus<OptionZ>();
    }

    public function map<B>(f : F1<A, B>) : AbstractOption<B> return Util.missing();

    public function flatMap<B>(f : F1<A, AbstractOption<B>>) : AbstractOption<B> return Util.missing();

    public function fold<B>(f : F1<A, B>, g : F0<B>) : B return Util.missing();

    public function cata<B>(cat : OptionCata<A, B>) : B return Util.missing();

    public function getOrElse(a : F0<A>) : A return Util.missing();

    public function orElse(a : Option<A>) : Option<A> return Util.missing();

    public function native() : OptionNative<A> return Util.missing();
}

abstract Option<A>(AbstractOption<A>) from AbstractOption<A> to AbstractOption<A> {

    inline function new(x : AbstractOption<A>) this = x;

    inline public static function none<A>() : Option<A> return AbstractOption.none();

    inline public function map<B>(f : F1<A, B>) : Option<B> {
        var x : AbstractOption<A> = this;
        return x.map(f);
    }

    inline public function flatMap<B>(f : F1<A, Option<B>>) : Option<B> {
        var x : AbstractOption<A> = this;
        return x.flatMap(f);
    }

    inline public function fold<B>(f : F1<A, B>, g : F0<B>) : B {
        var x : AbstractOption<A> = this;
        return x.fold(f, g);
    }

    inline public function cata<B>(cat : OptionCata<A, B>) : B {
        var x : AbstractOption<A> = this;
        return x.cata(cat);
    }

    inline public function getOrElse(a : F0<A>) : A {
        var x : AbstractOption<A> = this;
        return x.getOrElse(a);
    }

    inline public function orElse(a : Option<A>) : Option<A> {
        var x : AbstractOption<A> = this;
        return x.orElse(a);
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

    override public function map<B>(f : F1<A, B>) : AbstractOption<B> {
        return new Some(f.apply(a));
    }

    override public function flatMap<B>(f : F1<A, AbstractOption<B>>) : AbstractOption<B> {
        return f.apply(a);
    }

    override public function fold<B>(f : F1<A, B>, g : F0<B>) : B return f.apply(this.a);

    override public function cata<B>(cat : OptionCata<A, B>) : B return cat.Some(this.a);

    override public function getOrElse(a : F0<A>) : A return this.a;

    override public function orElse(a : Option<A>) : Option<A> return this;

    override public function native() : OptionNative<A> return OptionNative.Some(this.a);
}

class None<A> extends AbstractOption<A> {

    public function new() {
        super();
    }

    override public function map<B>(f : F1<A, B>) : AbstractOption<B> return cast this;

    override public function flatMap<B>(f : F1<A, AbstractOption<B>>) : AbstractOption<B> {
        return cast this;
    }

    override public function fold<B>(f : F1<A, B>, g : F0<B>) : B return g.apply();

    override public function cata<B>(cat : OptionCata<A, B>) : B return cat.None();

    override public function getOrElse(a : F0<A>) : A return a.apply();

    override public function orElse(a : Option<A>) : Option<A> return a;

    override public function native() : OptionNative<A> return OptionNative.None;
}

class OptionOfMonadPlus<T> extends MonadPlus<T> {

    public function new() super();

    override public function empty<A>() : _1<T, A> {
        return cast AbstractOption.none();
    }

    override public function plus<A>(a1 : _1<T, A>, a2 : _1<T, A>) : _1<T, A> {
        var x : AbstractOption<A> = cast a1;
        var y : AbstractOption<A> = cast a2;
        return cast x.orElse(y);
    }
}