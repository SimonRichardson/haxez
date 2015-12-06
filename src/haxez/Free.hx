package haxez;

enum FreeNative<F, A> {
    Done(a : A);
    Suspend(a : _1<F, Free<F, A>>);
    Gosub(a : Free<F, A>, f : F1<A, Free<F, B>>);
}

class AbstractFree<F, A> implements _1<Free<F, Dynamic>, A> {

    private function new() {}

    @:noUsing
    inline public static function liftF<G, B>(value : _1<G, B>, g : Functor<G>) : Free<G, B> {
        return new Suspend(g.map(function(a) return new Done(a), value));
    }

    @:noUsing
    inline public static function liftFC<S, B>(s : _1<S, B>) : Free<Coyoneda<S, Dynamic>, B> {
        return liftF(Coyoneda.lift(s), Coyoneda.functor());
    }

    inline public static function done<G, B>(b : B) : Free<G, B> return new Done(b);

    inline public static function suspend<G, B>(b : _1<G, Free<G, B>>) : Free<G, B> return new Suspend(b);

    inline public static function narrow<G, B>(f : _1<Free<G, Dynamic>, B>) : Free<G, B> return cast f;

    inline public static function runFC<S, M, B>(sa : Free<Coyoneda<S, Dynamic>, B>, interpreter : NT<S, M>, m : Monad<M>) : _1<M, B> {
        return sa.foldMap(new AbstractFreeNT(sa, interpreter, m), Coyoneda.functor(), m);
    }

    @:access(haxez.Id.Z)
    inline public static function runFCId<S, B>(sa : Free<Coyoneda<S, Dynamic>, B>, interpreter : NT<S, Id.Z>) : B {
        var id : Id<B> = runFC(sa, interpreter, Id.monad);
        return id.value();
    }

    inline public static function freeMonad<S>(f : Functor<S>) : Monad<Free<S, Dynamic>> return new FreeOfMonad();

    inline public static function freeCoyonedaMonad<G>() : Monad<Free<Coyoneda<G, Dynamic>, Dynamic>> {
        return freeMonad(Coyoneda.functor());
    }

    inline public function resume<X1, X2, F, A>(current : Free<F, A>, f : Functor<F>) : Either<_1<F, Free<F, A>>, A> {
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

    public function go<A>(f : F1<_1<F, Free<F, A>>, Free<F, A>>, g : Functor<F>) : A {
        var current : Free<F, A> = this;
        while (true) {
            var either : Either<_1<F, Free<F, A>>, A> = current.resume(g);
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

    public function flatMap<B>(f : F1<A, Free<F, B>>) : B return missing();

    public function map<B>(f : F1<A, B>) : Free<F, B> return flatMap(function(a) return new Done(f.apply(a)));

    public function resume(f : Functor<F>) : Either<_1<F, Free<F, A>>, A> return resume(this, f);

    inline private function missing<C>() : C throw "Missing Implementation";
}

@:allow(haxez.AbstractFree)
private class AbstractFreeNT<S, M, B> implements NT<Coyoneda<S, Dynamic>, M> {

    private var sa : Free<Coyoneda<S, Dynamic>, B>;
    private var interpreter : NT<S, M>;
    private var m : Monad<M>;

    public function new(sa : Free<Coyoneda<S, Dynamic>, B>, interpreter : NT<S, M>, m : Monad<M>) {
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

class Done<F, A> extends AbstractFree<F, A> {

    private var x : A;

    public function new(x : A) {
        super();
        this.x = x;
    }

    override public function flatMap<B>(f : F1<A, AbstractFree<F, B>>) : AbstractFree<F, B> return new Done(this.x);

    override public function native() : FreeNative<F, A> return FreeNative.Done(this.x);
}

class Suspend<F, A> extends AbstractFree<F, A> {

    private var x : _1<F, Free<F, A>>;

    public function new(x : _1<F, Free<F, A>>) {
        super();
        this.x = x;
    }

    override public function flatMap<B>(f : F1<A, AbstractFree<F, B>>) : AbstractFree<F, B> return new Gosub(this, f);

    override public function native() : FreeNative<F, A> return FreeNative.Suspend(this.x);
}

class Gosub<F, A, B> extends AbstractFree<F, B> {

    private var x : Free<F, A>;
    private var y : F1<A, Free<F, B>>;

    public function new(x : Free<F, A>, y : F1<A, Free<F, B>>) {
        super();
        this.x = x;
        this.y = y;
    }

    override public function flatMap<C>(f : F1<B, AbstractFree<F, C>>) : AbstractFree<F, C> {
        return new Gosub(this.x, function(a) return new Gosub(this.y.apply(a), f));
    }

    override public function native() : FreeNative<F, A> return FreeNative.Gosub(this.x, this.y);
}