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
void testNull( "Context the test is performed on." AsyncTestContext context ) {
	context.start();
	
	context.assertThat( null, IsNull(), "is null with null" );
	context.assertThat( null, IsNotNull(), "is not null with null" );
	context.assertThat( "test", IsNull(), "is null with not null" );
	context.assertThat( "test", IsNotNull(), "is not null with not null" );
	
	context.complete();
}
