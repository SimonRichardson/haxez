package haxez;

import haxez.Coyoneda;
import haxez.Either;
import haxez.F0;
import haxez.F1;
import haxez.F2;
import haxez.Functor;
import haxez.Id;
import haxez.Monad;
import haxez.NT;
import haxez.Option;
import haxez.T;

enum FreeNative<F, A> {
    Done(a : A);
    Suspend(a : _1<F, AbstractFree<F, A>>);
    Gosub<B>(a : AbstractFree<F, A>, f : F1<A, AbstractFree<F, B>>);
}
typedef FreeCata<F, A, Y> = {
    function Done(a : A) : Y;
    function Suspend(a : _1<F, AbstractFree<F, A>>) : Y;
    function Gosub(a : AbstractFree<F, A>, f : F1<A, AbstractFree<F, Dynamic>>) : Y;
}

class FreeNatives {

    inline public static function fromFree<F, A, B>(x : AbstractFree<F, A>) : FreeNative<F, A> {
        return x.cata({
            Done: function(a) return FreeNative.Done(a),
            Suspend: function(a) return FreeNative.Suspend(a),
            Gosub: function(a, f) return FreeNative.Gosub(a, f)
        });
    }

    inline public static function toFree<F, A>(x : FreeNative<F, A>) : AbstractFree<F, A> {
        return switch (x) {
            case Done(a): new Done(a);
            case Suspend(a): new Suspend(a);
            case Gosub(a, f): new Gosub(a, cast f);
        };
    }
}

class AbstractFree<F, A> implements _1<AbstractFree<F, Dynamic>, A> {

    private function new() {}

    @:noUsing
    inline public static function liftF<G, B>(value : _1<G, B>, g : IFunctor<G>) : AbstractFree<G, B> {
        // TODO : Remove the `cast`
        return new Suspend(g.map(new F1Lift(cast function(a) return new Done(a)), value));
    }

    @:noUsing
    inline public static function liftFC<S, B>(s : _1<S, B>) : AbstractFree<Coyoneda<S, Dynamic>, B> {
        return liftF(haxez.Coyoneda.lift(s), haxez.Coyoneda.functor());
    }

    inline public static function done<G, B>(b : B) : AbstractFree<G, B> return new Done(b);

    inline public static function suspend<G, B>(b : _1<G, AbstractFree<G, B>>) : AbstractFree<G, B> {
        return new Suspend(b);
    }

    inline public static function narrow<G, B>( f : _1<AbstractFree<G, Dynamic>, B>
                                                ) : AbstractFree<G, B> {
        return cast f;
    }

    inline public static function runFC<S, M, B>(   sa : AbstractFree<Coyoneda<S, Dynamic>, B>, 
                                                    interpreter : INaturalTransformation<S, M>, 
                                                    m : IMonad<M>
                                                    ) : _1<M, B> {
        return sa.foldMap(new AbstractFreeNT(sa, interpreter, m), haxez.Coyoneda.functor(), m);
    }

    inline public static function runFCId<S, B>(    sa : AbstractFree<Coyoneda<S, Dynamic>, B>, 
                                                    interpreter : INaturalTransformation<S, haxez.Id.Z>
                                                    ) : B {
        var id : Id<B> = cast runFC(sa, interpreter, haxez.Id.monad());
        return id.value();
    }

    inline public static function freeMonad<S>(f : IFunctor<S>) : IMonad<AbstractFree<S, Dynamic>> {
        return new FreeOfMonad();
    }

    inline public static function freeCoyonedaMonad<G>() : IMonad<AbstractFree<Coyoneda<G, Dynamic>, Dynamic>> {
        return freeMonad(haxez.Coyoneda.functor());
    }

    public function resume<X1, X2, F, A>(   current : AbstractFree<F, A>, 
                                            f : IFunctor<F>
                                            ) : Either<_1<F, AbstractFree<F, A>>, A> {
        while(true) {
            var x = current.cata({
                Done: function(a) return new Some(new Right(a)),
                Suspend: function(a) return new Some(cast new Left(a)),
                Gosub: function(y, g) {
                    var z = y.cata({
                        Done: function(b) {
                            return new Right(g.apply(b));
                        },
                        Suspend: function(b) {
                            return cast new Left(f.map(new F1Lift(function(o) return o.flatMap(cast g)), cast b));
                        },
                        Gosub: function(b, h) {
                            var sub : Gosub<F, X2, X1> = cast y;
                            return new Right(b.flatMap(new F1Lift(cast function(o) {
                                return h.apply(o).flatMap(cast g);
                            })));
                        }
                    });
                    
                    return switch(z.native()) {
                        case Left(_): new Some(z);
                        case Right(a): 
                            current = a;
                            new None();
                    }
                }
            });
            
            switch (x.native()) {
                case Some(x): return x;
                case None:
            }
        }
    }

    public function go( f : F1<_1<F, AbstractFree<F, A>>, AbstractFree<F, A>>, 
                        g : IFunctor<F>
                        ) : A {
        var current : AbstractFree<F, A> = this;
        while (true) {
            var either : Either<_1<F, AbstractFree<F, A>>, A> = current.resumeF(g);
            switch (either.native()) {
                case Left(a): current = cast f.apply(a);
                case Right(a): return a;
            }
        }
    }

    public function foldMap<G>( f : INaturalTransformation<F, G>, 
                                g : IFunctor<F>, 
                                m : IMonad<G>
                                ) : _1<G, A> {
        var either = resumeF(g);
        return switch (either.native()) {
            case Left(a):
                m.flatMap(new F1Lift(cast function(x) {
                    return x.foldMap(f, g, m);
                }), f.apply(a));
            case Right(a): m.point(new F0Lift(cast function() return a));
        };
    }

    public function flatMap<B>(f : F1<A, AbstractFree<F, B>>) : AbstractFree<F, B> {
        return Util.missing();
    }

    public function map<B>(f : F1<A, B>) : AbstractFree<F, B> {
        return flatMap(new F1Lift(cast function(a) return new Done(f.apply(a))));
    }

    public function resumeF(f : IFunctor<F>) : Either<_1<F, AbstractFree<F, A>>, A> {
        return resume(this, f);
    }

    public function cata<X>(cat : FreeCata<F, A, Dynamic>) : X return Util.missing();

    public function native() : FreeNative<F, A> return Util.missing();
}

@:allow(haxez.AbstractFree)
private class AbstractFreeNT<S, M, B> implements INaturalTransformation<Coyoneda<S, Dynamic>, M> {

    private var sa : AbstractFree<Coyoneda<S, Dynamic>, B>;
    private var interpreter : INaturalTransformation<S, M>;
    private var m : IMonad<M>;

    public function new(    sa : AbstractFree<Coyoneda<S, Dynamic>, B>, 
                            interpreter : INaturalTransformation<S, M>, 
                            m : IMonad<M>
                            ) {
        this.sa = sa;
        this.interpreter = interpreter;
        this.m = m;
    }

    public function apply<A>(cy : _1<Coyoneda<S, Dynamic>, A>) : _1<M, A> {
        var x : Coyoneda<S, A> = cast cy;
        return x.with(new F2Lift(function(fi, k) {
            return m.map(k, interpreter.apply(fi));
        }));
    }
}

private class FreeOfMonad<S> extends Monad<Free<S, Dynamic>> {

    public function new() super();

    override public function point<A>(a : F0<A>) : _1<Free<S, Dynamic>, A> {
        return AbstractFree.done(a.apply());
    }

    override public function flatMap<A, B>( f : F1<A, _1<Free<S, Dynamic>, B>>, 
                                            fa : _1<Free<S, Dynamic>, A>
                                            ) : _1<Free<S, Dynamic>, B> {
        return cast AbstractFree.narrow(fa).flatMap(new F1Lift(function(a) {
            return AbstractFree.narrow(f.apply(a));
        }));
    }
}

abstract Free<F, A>(AbstractFree<F, A>) from AbstractFree<F, A> to AbstractFree<F, A> {

    inline function new(x : AbstractFree<F, A>) this = x;

    @:noUsing
    inline public static function liftF<G, B>(value : _1<G, B>, g : IFunctor<G>) : Free<G, B> {
        return AbstractFree.liftF(value, g);
    }

    @:noUsing
    inline public static function liftFC<S, B>(s : _1<S, B>) : Free<Coyoneda<S, Dynamic>, B> {
        return AbstractFree.liftFC(s);
    }

    inline public static function done<G, B>(b : B) : Free<G, B> return AbstractFree.done(b);

    inline public static function suspend<G, B>(b : _1<G, Free<G, B>>) : Free<G, B> {
        return AbstractFree.suspend(b);
    }

    inline public static function narrow<G, B>(f : _1<Free<G, Dynamic>, B>) : Free<G, B> {
        return AbstractFree.narrow(f);
    }

    inline public static function runFC<S, M, B>(   sa : Free<Coyoneda<S, Dynamic>, B>, 
                                                    interpreter : INaturalTransformation<S, M>, 
                                                    m : IMonad<M>
                                                    ) : _1<M, B> {
        return AbstractFree.runFC(sa, interpreter, m);
    }

    @:access(haxez.Id.Z)
    inline public static function runFCId<S, B>(    sa : Free<Coyoneda<S, Dynamic>, B>, 
                                                    interpreter : INaturalTransformation<S, Id.Z>
                                                    ) : B {
        return AbstractFree.runFCId(sa, interpreter);
    }

    inline public static function freeMonad<S>(f : IFunctor<S>) : IMonad<Free<S, Dynamic>> {
        return AbstractFree.freeMonad(f);
    }

    inline public static function freeCoyonedaMonad<G>() : IMonad<Free<Coyoneda<G, Dynamic>, Dynamic>> {
        return AbstractFree.freeCoyonedaMonad();
    }

    inline public function resume<X1, X2, F, A>(    current : Free<F, A>, 
                                                    f : IFunctor<F>
                                                    ) : Either<_1<F, Free<F, A>>, A> {
        var x : AbstractFree<F, A> = this;
        return x.resume(current, f);
    }

    public function go<A>(  f : F1<_1<F, AbstractFree<F, A>>, AbstractFree<F, A>>, 
                            g : IFunctor<F>
                            ) : A {
        var x : AbstractFree<F, A> = this;
        return x.go(f, g);
    }

    public function foldMap<G>( f : INaturalTransformation<F, G>, 
                                g : IFunctor<F>, 
                                m : IMonad<G>
                                ) : _1<G, A> {
        var x : AbstractFree<F, A> = this;
        return x.foldMap(f, g, m);
    }

    public function flatMap<B>(f : F1<A, AbstractFree<F, B>>) : AbstractFree<F, B> {
        var x : AbstractFree<F, A> = this;
        return x.flatMap(f);
    }

    public function map<B>(f : F1<A, B>) : AbstractFree<F, B> {
        var x : AbstractFree<F, A> = this;
        return x.map(f);
    }

    public function resumeF(f : IFunctor<F>) : Either<_1<F, AbstractFree<F, A>>, A> {
        var x : AbstractFree<F, A> = this;
        return x.resumeF(f);
    }

    public function cata<X>(cat : FreeCata<F, A, Dynamic>) : X {
        var x : AbstractFree<F, A> = this;
        return x.cata(cat);
    }

    @:to
    inline public function toFreeNative() : FreeNative<F, A> return FreeNatives.fromFree(this);

    @:from
    inline public static function fromFreeNative<F, A>(x : FreeNative<F, A>) : Free<F, A> {
        return FreeNatives.toFree(x);
    }
}

class Done<F, A> extends AbstractFree<F, A> {

    private var x : A;

    public function new(x : A) {
        super();
        this.x = x;
    }

    override public function flatMap<B>(f : F1<A, AbstractFree<F, B>>) : AbstractFree<F, B> return new Gosub(this, f);

    override public function cata<X>(cat : FreeCata<F, A, Dynamic>) : X return cat.Done(this.x);

    override public function native() : FreeNative<F, A> return FreeNative.Done(this.x);
}

class Suspend<F, A> extends AbstractFree<F, A> {

    private var x : _1<F, AbstractFree<F, A>>;

    public function new(x : _1<F, AbstractFree<F, A>>) {
        super();
        this.x = x;
    }

    override public function flatMap<B>(f : F1<A, AbstractFree<F, B>>) : AbstractFree<F, B> return new Gosub(this, f);

    override public function cata<X>(cat : FreeCata<F, A, Dynamic>) : X return cat.Suspend(this.x);

    override public function native() : FreeNative<F, A> return FreeNative.Suspend(this.x);
}

class Gosub<F, A, B> extends AbstractFree<F, B> {

    private var x : AbstractFree<F, A>;
    private var y : F1<A, AbstractFree<F, B>>;

    public function new(x : AbstractFree<F, A>, y : F1<A, AbstractFree<F, B>>) {
        super();
        this.x = x;
        this.y = y;
    }

    override public function flatMap<C>(f : F1<B, AbstractFree<F, C>>) : AbstractFree<F, C> {
        return new Gosub(this.x, new F1Lift(cast function(a) return new Gosub(this.y.apply(a), f)));
    }

    override public function cata<X>(cat : FreeCata<F, B, Dynamic>) : X return cat.Gosub(cast this.x, cast this.y);

    override public function native() : FreeNative<F, B> return FreeNative.Gosub(cast this.x, cast this.y);
}