import herd.asynctest {
	AsyncTestContext
}
import ceylon.test {
	test
}
import herd.asynctest.match {
	ExceptionHasType,
	ExceptionHasMessage
}


class ExceptionMatchers() {
	
	class TestException( String msg ) extends Exception( msg ) {}
	String throwingMsg = "Message of exception";
	
	void toThrow() {
		throw TestException( throwingMsg );
	}
	
	test shared void checkThrow( AsyncTestContext context ) {
		context.assertThatException (
			toThrow,
			ExceptionHasType<TestException>().and( ExceptionHasMessage( throwingMsg ) ),
			"exception matching", true
		);
		context.complete();
	}
	
}

