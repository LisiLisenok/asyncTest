import herd.asynctest {
	AsyncTestContext
}
import ceylon.test {
	test
}
import herd.asynctest.match {
	ValueEquality
}
import herd.asynctest.parameterization {
	parameterized
}


"Checks value equality for `Integer` and `String`."
class ValueEqualityTest() {
	
	test parameterized( `value valueEqualityString` )
	shared void stringEquality (
		"Context the test is performed on." AsyncTestContext context,
		"String to be tested." String tested
	) {
		context.assertThat( tested, ValueEquality<String>( (String s) {String ret = s; return ret;} ), "string equality", true );
		context.complete();
	}
	
	test parameterized( `value valueEqualityInteger` )
	shared void integerEquality (
		"Context the test is performed on." AsyncTestContext context,
		"String to be tested." Integer tested
	) {
		context.assertThat( tested, ValueEquality<Integer>( (Integer s) {Integer ret = s; return ret;} ), "integer equality", true );
		context.complete();
	}
	
}
