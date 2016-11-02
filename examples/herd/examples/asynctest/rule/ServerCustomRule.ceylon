import herd.asynctest {
	arguments,
	AsyncPrePostContext,
	AsyncTestContext,
	async,
	timeout
}
import herd.asynctest.rule {
	testRule,
	SuiteRule
}
import ceylon.http.client {
	ClientRequest = Request
}
import ceylon.http.server {
	Status, 
	Endpoint,
	ServerResponse = Response,
	ServerRequest = Request, 
	startsWith,
	stopped,
	started,
	newServer,
	Server
}
import ceylon.buffer.charset {
	utf8
}
import ceylon.http.common {
	contentType
}
import ceylon.io {
	SocketAddress
}
import ceylon.test {
	test
}
import ceylon.uri {
	parse
}
import herd.asynctest.match {
	EqualObjects
}
	
	
"Host and port a server to be started, path server to respond and response."
[String, Integer, String, String] serverParameters() => ["localhost", 8080, "/hello", "Hello, World!"];


"Example of custom rule which initialize `ceylon.http.server::Server` and runs it in background."
arguments( `function serverParameters` )
timeout(60k)
class ServerCustomRule (
	"Host the server to listen." String host,
	"Port the server to listen." Integer port,
	"Path of the server endpoint." String path,
	"Response the server sends when requested at `path`." String responseString
) {
	
	String baseUri = "http://" + host + ":" + port.string;
	
	shared testRule object server satisfies SuiteRule {
		variable Server? server = null;
		
		shared actual void dispose(AsyncPrePostContext context) {
			if (exists s = server) {
				s.addListener (
					(Status status) {
						if (status==stopped) {
							context.proceed();
						}
					}
				);
				server = null;
				s.stop();
			}
		}
		
		shared actual void initialize(AsyncPrePostContext context) {
			Server s = newServer {
				Endpoint {
					path = startsWith(path);
					service = void(ServerRequest request, ServerResponse response) {
						response.addHeader(contentType("text/plain", utf8));
						response.writeString(responseString);
					};
				}
			};
			server = s;
			s.addListener (
				(Status status) {
					if (status==started) {
						context.proceed();
					}
				}
			);
			s.startInBackground(SocketAddress(host, port));
		}
	}
	
	
	shared test async void defaultGet(AsyncTestContext context) {
		value req = ClientRequest(parse(baseUri + "/hello"));
		Integer start = system.milliseconds;
		value content = req.execute().contents;
		Integer end = system.milliseconds;
		context.assertThat(content, EqualObjects(responseString), "", true);
		context.succeed("request-response has been taking ``end-start``ms");
		context.complete();
	}
	
}
