package examples;

import haxez.Coyoneda;
import haxez.Either;
import haxez.F0;
import haxez.F1;
import haxez.F2;
import haxez.Free;
import haxez.Id;
import haxez.Monad;
import haxez.NT;
import haxez.T;
import haxez.Util;

import haxe.Http;

using examples.FreeExample;

class FreeExample {

    public static function main() {
        var either : Either<HttpError, String> = cast Free.runFC(Http.files(), Http.interpreter(), Either.monad());
        switch(either.native()) {
            case Left(error): trace(error.code, error.url);
            case Right(result): trace(result);
        };
    }
}

private class Z {}

typedef HttpCata<A, B> = {
    function Get(url : String, action : F1<String, A>) : B;
    function Post(url : String, action : F1<String, A>) : B;
}

@:allow(examples.HttpInterpreterNT)
class Http<A> implements _1<Z, A> {

    private var url : String;
    private var action : F1<String, A>;

    public function new(url : String, action : F1<String, A>) {
        this.url = url;
        this.action = action;
    }

    inline public static function get<F>(url : String) : Free<Coyoneda<Z, Dynamic>, String> {
        trace("get", url);
        return Free.liftFC(new Get(url, F1_.id()));
    }

    inline public static function post<F>(url : String) : Free<Coyoneda<Z, Dynamic>, String> {
        return Free.liftFC(new Post(url, F1_.id()));
    }

    inline public static function monad() : IMonad<Free<Coyoneda<Z, Dynamic>, Dynamic>> { 
        return Free.freeCoyonedaMonad();
    }

    private static var rawURL = "http://www.google.co.uk/";

    private static function freeMonadRaw(file) {
        return '${rawURL}${file}';
    }

    public static function files() : Free<Coyoneda<Z, Dynamic>, String> {
        return cast monad().apply2(
            new F0Lift(cast function() return get(freeMonadRaw("robots.txt"))),
            new F0Lift(cast function() return get(freeMonadRaw("humans.txt"))),
            new F2Lift(function(a, b) return a + b)
        );
    }

    public static function interpreter() : INaturalTransformation<Z, Either<HttpError, Dynamic>> {
        return new HttpInterpreterNT();
    }

    public function cata<B>(cat : HttpCata<A, B>) : B return Util.missing();
}

class HttpInterpreterNT implements INaturalTransformation<Z, Either<HttpError, Dynamic>> {

    public function new() {}

    public function apply<A>(fa : _1<Z, A>) : _1<Either<HttpError, Dynamic>, A> {
        trace("NT");
        var http : Http<A> = cast fa;
        var request : HttpMethod = http.cata({
            Get: function(url, action) return HttpMethod.Get(url),
            Post: function(url, action) return HttpMethod.Post(url)
        });

        var response = HttpClient.createDefault().execute(request);
        return if (response.code < 300) {
            return new Right(http.action.apply(response.body));
        } else {
            return new Left(new HttpError(response.url, response.code, response.body));
        }
    }
}

class Get<A> extends Http<A> {
    public function new(url : String, action : F1<String, A>) {
        super(url, action);
    }

    override public function cata<B>(cat : HttpCata<A, B>) : B {
        return cat.Get(this.url, this.action);
    }
}

class Post<A> extends Http<A> {
    public function new(url : String, action : F1<String, A>) {
        super(url, action);
    }

    override public function cata<B>(cat : HttpCata<A, B>) : B {
        return cat.Post(this.url, this.action);
    }
}

class HttpResponse {

    public var url : String;
    public var code : Int;
    public var body : String;

    public function new(url : String, code : Int, body : String) {
        this.url = url;
        this.code = code;
        this.body = body;
    }
}

class HttpError {

    public var url : String;
    public var code : Int;
    public var body : String;

    public function new(url : String, code : Int, body : String) {
        this.url = url;
        this.code = code;
        this.body = body;
    }
}

enum HttpMethod {
    Get(url : String);
    Post(url : String);
}

class HttpMethods {

    inline public static function post(m : HttpMethod) : Bool {
        return switch(m) {
            case Get(_): false;
            case Post(_): true;
        };
    }
}

class HttpClient {

    private function new() {}

    public static function createDefault() : HttpClient {
        return new HttpClient();
    }

    public function execute(request : HttpMethod) : HttpResponse {
        var url = switch(request) {
            case Get(url): url;
            case Post(url): url;
        };

        trace(url);

        var response = new HttpResponse(url, 0, "");
        
        var req = new haxe.Http(url);
        req.onData = function(data) response.body += data;
        req.onStatus = function(status) response.code = status;
        req.onError = function(msg) response.body = msg;
        req.request(request.post());

        return response;
    }
}