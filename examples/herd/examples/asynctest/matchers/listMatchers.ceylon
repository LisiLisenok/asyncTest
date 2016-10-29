import ceylon.test {

	test
}
import herd.asynctest {

	AsyncTestContext,
	parameterized
}
import herd.asynctest.match {

	StartsWith,
	EndsWith,
	Beginning,
	Finishing
}


"Verify List Matchers"
class ListMatchers() {
	
	test parameterized( `value subListStrings` )
	shared void listStartsWith (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String list,
		"String to compare to" String subList
	) {
		context.assertThat( list, StartsWith( subList ), "", true );
		context.complete();
	}

	test parameterized( `value subListStrings` )
	shared void listEndsWith (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String list,
		"String to compare to" String subList
	) {
		context.assertThat( list, EndsWith( subList ), "", true );
		context.complete();
	}

	test parameterized( `value subListStrings` )
	shared void listBeginning (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String subList,
		"String to compare to" String list
	) {
		context.assertThat( subList, Beginning( list ), "", true );
		context.complete();
	}
	
}


test parameterized( `value subListStrings` )
void listFinishing (
	"Context the test is performed on." AsyncTestContext context,
	"String to be compared." String subList,
	"String to compare to" String list
) {
	context.assertThat( subList, Finishing( list ), "", true );
	context.complete();
}
