import ceylon.test {

	test
}
import herd.asynctest {

	AsyncTestContext
}
import herd.asynctest.match {

	IsNull,
	IsNotNull
}


test
void nullMatchers( "Context the test is performed on." AsyncTestContext context ) {
	context.start();
	
	context.assertThat( null, IsNull(), "is null with null", true );
	context.assertThat( null, IsNotNull(), "is not null with null", true );
	context.assertThat( "test", IsNull(), "is null with not null", true );
	context.assertThat( "test", IsNotNull(), "is not null with not null", true );
	
	context.complete();
}
