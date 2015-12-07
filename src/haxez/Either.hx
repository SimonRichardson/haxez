package haxez;

import haxez.F1;
import haxez.Monad;
import haxez.T;
import haxez.Util;

typedef EitherNative<L, R> = haxe.ds.Either<L, R>;
typedef EitherCata<L, R, B> = {
    function Left(a : L) : B;
    function Right(a : R) : B;
}

class EitherNatives {

    inline public static function fromEither<A, B>(x : AbstractEither<A, B>) : EitherNative<A, B> {
        return x.fold(
            new F1Lift(function(x) return EitherNative.Left(x)),
            new F1Lift(function(x) return EitherNative.Right(x))
        );
    }

    inline public static function toEither<A, B>(x : EitherNative<A, B>) : AbstractEither<A, B> {
        return switch(x) {
            case Left(a): new Left(a);
            case Right(a): new Right(a);
        };
    }
}

class AbstractEither<A, B> implements _1<AbstractEither<A, Dynamic>, B> {

    private function new() {}

    inline public static function monad<L>() : IMonad<AbstractEither<L, Dynamic>> {
        return new EitherOfMonad<L>();
    }

    public function bimap<C, D>(f : F1<A, C>, g : F1<B, D>) : AbstractEither<C, D> {
        return fold(
            new F1Lift(function(l) return left(f.apply(l))), 
            new F1Lift(function(r) return right(g.apply(r)))
        );
    }

    public function swap() : AbstractEither<B, A> return fold(new F1Lift(right), new F1Lift(left));

    public function fold<C>(f : F1<A, C>, g : F1<B, C>) : C return Util.missing();

    public function map<C>(f : F1<B, C>) : AbstractEither<A, C> return Util.missing();

    public function flatMap<C>(f : F1<B, AbstractEither<A, C>>) : AbstractEither<A, C> return Util.missing();

    public function cata<C>(cat : EitherCata<A, B, C>) : C return Util.missing();

    public function native() : EitherNative<A, B> return Util.missing();

    inline private function left<X, Y>(x : X) : AbstractEither<X, Y> return cast x;

    inline private function right<X, Y>(y : Y) : AbstractEither<X, Y> return cast y;
}

abstract Either<A, B>(AbstractEither<A, B>) from AbstractEither<A, B> to AbstractEither<A, B> {

    inline function new(x : AbstractEither<A, B>) this = x;

    inline public static function monad<L>() : IMonad<AbstractEither<L, Dynamic>> {
        return AbstractEither.monad();
    }

    inline public function bimap<C, D>(f : F1<A, C>, g : F1<B, D>) : Either<C, D> {
        var x : AbstractEither<A, B> = this;
        return x.bimap(f, g);
    }

    inline public function swap() : Either<B, A> {
        var x : AbstractEither<A, B> = this;
        return x.swap();   
    }

    inline public function fold<C>(f : F1<A, C>, g : F1<B, C>) : C {
        var x : AbstractEither<A, B> = this;
        return x.fold(f, g);
    }

    inline public function map<C>(f : F1<B, C>) : Either<A, C> {
        var x : AbstractEither<A, B> = this;
        return x.map(f);
    }

    inline public function flatMap<C>(f : F1<B, AbstractEither<A, C>>) : Either<A, C> {
        var x : AbstractEither<A, B> = this;
        return x.flatMap(f);
    }

    inline public function cata<C>(cat : EitherCata<A, B, C>) : C {
        var x : AbstractEither<A, B> = this;
        return x.cata(cat);
    }

    inline public function native() : EitherNative<A, B> {
        var x : AbstractEither<A, B> = this;
        return x.native();
    }

    @:to
    inline public function toEitherNative() : EitherNative<A, B> return EitherNatives.fromEither(this);

    @:from
    inline public static function fromEitherNative<A, B>(x : EitherNative<A, B>) : Either<A, B> {
        return EitherNatives.toEither(x);
    }
}

class Left<A, B> extends AbstractEither<A, B> {

    private var x : A;

    public function new(x : A) {
        super();
        this.x = x;
    }

    override public function fold<C>(f : F1<A, C>, g : F1<B, C>) : C return f.apply(this.x);

    override public function map<C>(f : F1<B, C>) : AbstractEither<A, C> return new Left(this.x);

    override public function flatMap<C>(f : F1<B, AbstractEither<A, C>>) : AbstractEither<A, C> return new Left(this.x);

    override public function cata<C>(cat : EitherCata<A, B, C>) : C return cat.Left(this.x);

    override public function native() : EitherNative<A, B> return EitherNative.Left(this.x);
}

class Right<A, B> extends AbstractEither<A, B> {

    private var x : B;

    public function new(x : B) {
        super();
        this.x = x;
    }

    override public function fold<C>(f : F1<A, C>, g : F1<B, C>) : C return g.apply(this.x);

    override public function map<C>(f : F1<B, C>) : AbstractEither<A, C> return new Right(f.apply(this.x));

    override public function flatMap<C>(f : F1<B, AbstractEither<A, C>>) : AbstractEither<A, C> return f.apply(this.x);

    override public function cata<C>(cat : EitherCata<A, B, C>) : C return cat.Right(this.x);

    override public function native() : EitherNative<A, B> return EitherNative.Right(this.x);
}

class EitherOfMonad<F> implements IMonad<AbstractEither<F, Dynamic>> {

    public function new() {}

    public function ap<A, B>(   f : F0<_1<AbstractEither<F, Dynamic>, F1<A, B>>>, 
                                fa : F0<_1<AbstractEither<F, Dynamic>, A>>
                                ) : _1<AbstractEither<F, Dynamic>, B> {
        return cast flatMap(new F1Lift(function(x) {
            return map(x, cast fa.apply());
        }), cast f.apply());
    }

    public function apply2<A1, A2, Z>(  a : F0<_1<AbstractEither<F, Dynamic>, A1>>, 
                                        b : F0<_1<AbstractEither<F, Dynamic>, A2>>, 
                                        f : F2<A1, A2, Z>
                                        ) : _1<AbstractEither<F, Dynamic>, Z> {
        return Util.missing();
    }

    public function map<A, B>(  f : F1<A, B>, 
                                fa : _1<AbstractEither<F, Dynamic>, A>
                                ) : _1<AbstractEither<F, Dynamic>, B> {
        var x : AbstractEither<F, A> = cast fa;
        return cast x.map(f);
    }

    public function point<A>(a : F0<A>) : _1<AbstractEither<F, Dynamic>, A> {
        return cast new Right(a.apply());
    }

    public function flatMap<A, B>(  f : F1<A, _1<AbstractEither<F, Dynamic>, B>>, 
                                    fa : _1<AbstractEither<F, Dynamic>, A>
                                    ) : _1<AbstractEither<F, Dynamic>, B> {
        var x : AbstractEither<F, A> = cast fa;
        return cast x.flatMap(new F1Lift(function(a) {
            return cast f.apply(a);
        }));
    }
}
