import ceylon.test {

	parameters,
	test
}
import herd.asynctest {

	AsyncTestContext
}
import herd.asynctest.match {

	StartsWith,
	EndsWith,
	Beginning,
	Finishing
}


test parameters( `value subListStrings` )
void testListStart (
	"Context the test is performed on." AsyncTestContext context,
	"String to be compared." String list,
	"String to compare to" String subList
) {
	context.start();
	context.assertThat( list, StartsWith( subList ), "start with" );
	context.complete();
	
}


test parameters( `value subListStrings` )
void testListEnd (
	"Context the test is performed on." AsyncTestContext context,
	"String to be compared." String list,
	"String to compare to" String subList
) {
	context.start();
	context.assertThat( list, EndsWith( subList ), "end with" );
	context.complete();
	
}


test parameters( `value subListStrings` )
void testListBeginning (
	"Context the test is performed on." AsyncTestContext context,
	"String to be compared." String subList,
	"String to compare to" String list
) {
	context.start();
	context.assertThat( subList, Beginning( list ), "beginning" );
	context.complete();
	
}


test parameters( `value subListStrings` )
void testListFinishing (
	"Context the test is performed on." AsyncTestContext context,
	"String to be compared." String subList,
	"String to compare to" String list
) {
	context.start();
	context.assertThat( subList, Finishing( list ), "finishing" );
	context.complete();
}
