import io.vertx.ceylon.core {
	Verticle,
	vertx,
	Vertx
}
import io.vertx.ceylon.core.eventbus {
	Message
}
import herd.asynctest {
	AsyncTestContext
}
import herd.asynctest.match {
	EqualTo
}
import ceylon.test {
	test
}


"Verticle which listens to [[address]] and replies with received `String` message"
class EchoVerticle(AsyncTestContext context, String address) extends Verticle() {
	shared actual void start() {
		vertx.eventBus().consumer (
			address,
			(Message<String?> message) {
  				message.reply(message.body());
			}
		);
	}
}


"Starts Vertx, deployes [[EchoVerticle]], sends `String` message to, verifies reply and stops Vertx."
by( "Lis" )
shared test void testEchoVerticle(AsyncTestContext context) {
	String address = "receiver";
	Vertx vertxInstance = vertx.vertx();
	EchoVerticle(context, address).deploy (
		vertxInstance,
		null,
		(String|Throwable res) {
			if (is Throwable res) {
				context.fail(res);
				context.complete();
			}
			else {
				vertxInstance.eventBus().send (
					address, address,
					(Throwable|Message<String?> rep) {
						vertxInstance.close();
						switch (rep)
						case (is Throwable) {
							context.fail(rep);
							
						}
						case (is Message<String?>) {
							if (exists str = rep.body()) {
								context.assertThat(str, EqualTo(address), "", true);
							}
							else {
								context.fail(AssertionError("Empty message has been received"));
							}
						}
						context.complete();
					}
				);
			}
		}
	);
}
