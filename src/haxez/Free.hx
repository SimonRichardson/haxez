package haxez;

import haxez.F1;
import haxez.F2;
import haxez.Monad;
import haxez.T;

enum FreeNative<F, A> {
    Done(a : A);
    Suspend(a : _1<F, AbstractFree<F, A>>);
    Gosub(a : AbstractFree<F, A>, f : F1<A, AbstractFree<F, B>>);
}
typedef FreeCata<F, A, B> = {
    function Done(a : A) : B;
    function Suspend(a : _1<F, AbstractFree<F, A>>) : B;
    function Gosub(a : AbstractFree<F, A>, f : F1<A, AbstractFree<F, B>>);
}

class FreeNatives {

    inline public static function fromFree<F, A>(x : AbstractFree<F, A>) : FreeNative<A, B> {
        return x.cata({
            Done: function(a) return FreeNative.Done(a),
            Suspend: function(a) return FreeNative.Suspend(a),
            Gosub: function(a, f) return FreeNative.Gosub(a, f);
        });
    }

    inline public static function toFree<F, A>(x : FreeNative<F, A>) : AbstractFree<F, A> {
        return switch (x) {
            case Done(a): new Done(a);
            case Suspend(a): new Suspend(a);
            case Gosub(a, f): new Gosub(a, f);
        };
    }
}

class AbstractFree<F, A> implements _1<AbstractFree<F, Dynamic>, A> {

    private function new() {}

    @:noUsing
    inline public static function liftF<G, B>(value : _1<G, B>, g : Functor<G>) : AbstractFree<G, B> {
        return new Suspend(g.map(function(a) return new Done(a), value));
    }

    @:noUsing
    inline public static function liftFC<S, B>(s : _1<S, B>) : AbstractFree<Coyoneda<S, Dynamic>, B> {
        return liftF(Coyoneda.lift(s), Coyoneda.functor());
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
                                                    interpreter : NT<S, M>, 
                                                    m : Monad<M>
                                                    ) : _1<M, B> {
        return sa.foldMap(new AbstractFreeNT(sa, interpreter, m), Coyoneda.functor(), m);
    }

    @:access(haxez.Id.Z)
    inline public static function runFCId<S, B>(    sa : AbstractFree<Coyoneda<S, Dynamic>, B>, 
                                                    interpreter : NT<S, Id.Z>
                                                    ) : B {
        var id : Id<B> = runFC(sa, interpreter, Id.monad);
        return id.value();
    }

    inline public static function freeMonad<S>(f : Functor<S>) : Monad<AbstractFree<S, Dynamic>> {
        return new FreeOfMonad();
    }

    inline public static function freeCoyonedaMonad<G>() : Monad<AbstractFree<Coyoneda<G, Dynamic>, Dynamic>> {
        return freeMonad(Coyoneda.functor());
    }

    inline public function resume<X1, X2, F, A>(    current : AbstractFree<F, A>, 
                                                    f : Functor<F>
                                                    ) : Either<_1<F, AbstractFree<F, A>>, A> {
        while(true) {
            var x = current.native();
            switch (x) {
                case Done(a): return Right(a);
                case Suspend(a): return Left(a);
                case Gosub(y, g):
                    switch (y) {
                        case Done(b): current = g.apply(b);
                        case Suspend(b): Left(f.map(function(o) return o.flatMap(g), b));
                        case Gosub(b, h):
                            var sub : Gosub<F, X2, X1> = cast y;
                            current = b.flatMap(function(o) {
                                return h.apply(o).flatMap(g);
                            });
                    }
            }
        }
    }

    public function go<A>(  f : F1<_1<F, AbstractFree<F, A>>, AbstractFree<F, A>>, 
                            g : Functor<F>
                            ) : A {
        var current : AbstractFree<F, A> = this;
        while (true) {
            var either : Either<_1<F, AbstractFree<F, A>>, A> = current.resume(g);
            switch (either.native()) {
                case Left(a): current = f.apply(a);
                case Right(a): return a;
            }
        }
    }

    public function foldMap<G>(f : NT<F, G>, g : Functor<F>, m : Monad<G>) : _1<G, A> {
        var either = resume(g);
        return switch (either.native()) {
            case Left(a):  g.flatMap(function(x) return x.foldMap(f, g, m), f.apply(a));
            case Right(a): g.point(function() return a);
        };
    }

    public function flatMap<B>(f : F1<A, AbstractFree<F, B>>) : B return missing();

    public function map<B>(f : F1<A, B>) : AbstractFree<F, B> {
        return flatMap(function(a) return new Done(f.apply(a)));
    }

    public function resume(f : Functor<F>) : Either<_1<F, AbstractFree<F, A>>, A> {
        return resume(this, f);
    }

    public function cata<B>(cat : FreeCata<F, A, B>) : B return missing();

    public function native() : FreeNative<F, A> return missing();

    inline private function missing<C>() : C throw "Missing Implementation";
}

@:allow(haxez.AbstractFree)
private class AbstractFreeNT<S, M, B> implements NT<Coyoneda<S, Dynamic>, M> {

    private var sa : AbstractFree<Coyoneda<S, Dynamic>, B>;
    private var interpreter : NT<S, M>;
    private var m : Monad<M>;

    public function new(    sa : AbstractFree<Coyoneda<S, Dynamic>, B>, 
                            interpreter : NT<S, M>, 
                            m : Monad<M>
                            ) {
        this.sa = sa;
        this.interpreter = interpreter;
        this.m = m;
    }

    public function apply<A>(cy : _1<Coyoneda<S, Dynamic>, A>) : _1<M, A> {
        var x : Coyoneda<S, A> = cast cy;
        return x.with(function(fi, k) {
            return this.m.map(k, interpreter.apply(fi));
        });
    }
}

abstract Free<F, A>(AbstractFree<F, A>) from AbstractFree<F, A> to AbstractFree<F, A> {

    inline function new(x : AbstractFree<F, A>) this = x;

    @:noUsing
    inline public static function liftF<G, B>(value : _1<G, B>, g : Functor<G>) : Free<G, B> {
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
                                                    interpreter : NT<S, M>, 
                                                    m : Monad<M>
                                                    ) : _1<M, B> {
        return AbstractFree.runFC(sa, interpreter, m);
    }

    @:access(haxez.Id.Z)
    inline public static function runFCId<S, B>(    sa : Free<Coyoneda<S, Dynamic>, B>, 
                                                    interpreter : NT<S, Id.Z>
                                                    ) : B {
        return AbstractFree.runFCId(sa, interpreter);
    }

    inline public static function freeMonad<S>(f : Functor<S>) : Monad<Free<S, Dynamic>> {
        return AbstractFree.freeMonad();
    }

    inline public static function freeCoyonedaMonad<G>() : Monad<Free<Coyoneda<G, Dynamic>, Dynamic>> {
        return AbstractFree.freeCoyonedaMonad();
    }

    inline public function resume<X1, X2, F, A>(    current : Free<F, A>, 
                                                    f : Functor<F>
                                                    ) : Either<_1<F, Free<F, A>>, A> {
        return AbstractFree.resume();
    }

    public function go<A>(  f : F1<_1<F, AbstractFree<F, A>>, AbstractFree<F, A>>, 
                            g : Functor<F>
                            ) : A {
        var x : AbstractFree<F, A> = this;
        return x.go(f, g);
    }

    public function foldMap<G>( f : NT<F, G>, 
                                g : Functor<F>, 
                                m : Monad<G>
                                ) : _1<G, A> {
        var x : AbstractFree<F, A> = this;
        return x.foldMap(f, g);
    }

    public function flatMap<B>(f : F1<A, AbstractFree<F, B>>) : B {
        var x : AbstractFree<F, A> = this;
        return x.flatMap(f);
    }

    public function map<B>(f : F1<A, B>) : AbstractFree<F, B> {
        var x : AbstractFree<F, A> = this;
        return x.map(f);
    }

    public function resume(f : Functor<F>) : Either<_1<F, AbstractFree<F, A>>, A> {
        var x : AbstractFree<F, A> = this;
        return x.resume(f);
    }

    public function cata<B>(cat : FreeCata<F, A, B>) : B {
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

    override public function flatMap<B>(f : F1<A, AbstractFree<F, B>>) : AbstractFree<F, B> return new Done(this.x);

    override public function cata<B>(cat : FreeCata<F, A, B>) : B return cat.Done(this.x);

    override public function native() : FreeNative<F, A> return FreeNative.Done(this.x);
}

class Suspend<F, A> extends AbstractFree<F, A> {

    private var x : _1<F, AbstractFree<F, A>>;

    public function new(x : _1<F, AbstractFree<F, A>>) {
        super();
        this.x = x;
    }

    override public function flatMap<B>(f : F1<A, AbstractFree<F, B>>) : AbstractFree<F, B> return new Gosub(this, f);

    override public function cata<B>(cat : FreeCata<F, A, B>) : B return cat.Suspend(this.x);

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
        return new Gosub(this.x, function(a) return new Gosub(this.y.apply(a), f));
    }

    override public function cata<B>(cat : FreeCata<F, A, B>) : B return cat.Gosub(this.x, this.y);

    override public function native() : FreeNative<F, A> return FreeNative.Gosub(this.x, this.y);
}