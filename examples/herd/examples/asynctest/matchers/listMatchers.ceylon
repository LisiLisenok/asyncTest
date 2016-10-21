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
	shared void listStart (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String list,
		"String to compare to" String subList
	) {
		context.assertThat( list, StartsWith( subList ), "list starts with", true );
		context.complete();
	}

	test parameterized( `value subListStrings` )
	shared void listEnd (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String list,
		"String to compare to" String subList
	) {
		context.assertThat( list, EndsWith( subList ), "list ends with", true );
		context.complete();
	}

	test parameterized( `value subListStrings` )
	shared void listBeginning (
		"Context the test is performed on." AsyncTestContext context,
		"String to be compared." String subList,
		"String to compare to" String list
	) {
		context.assertThat( subList, Beginning( list ), "list beginning", true );
		context.complete();
	}
	
}


test parameterized( `value subListStrings` )
void listFinishing (
	"Context the test is performed on." AsyncTestContext context,
	"String to be compared." String subList,
	"String to compare to" String list
) {
	context.assertThat( subList, Finishing( list ), "list finishing", true );
	context.complete();
}
