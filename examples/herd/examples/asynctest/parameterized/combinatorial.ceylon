import herd.asynctest.parameterization {
	zipping,
	zippedSource,
	permutationSource,
	mixing
}
import herd.asynctest {
	AsyncTestContext
}
import herd.asynctest.match {
	Greater
}
import ceylon.test {
	test
}


Integer[] firstArgument => [1,2,3];
Integer[] secondArgument => [10,20,30];
String[] signArgument => ["+","-"];


"Zipping testing."
shared test zipping
void testZipping (
	AsyncTestContext context,
	zippedSource(`value firstArgument`) Integer arg1,
	zippedSource(`value secondArgument`) Integer arg2
) {
	context.assertThat(arg2, Greater(arg1), "", true);
	context.complete();
}


"Mixing testing."
shared test mixing
void testMixing (
	AsyncTestContext context,
	zippedSource(`value firstArgument`) Integer arg1,
	permutationSource(`value signArgument`) String arg2,
	zippedSource(`value secondArgument`) Integer arg3
) {
	context.succeed( "``arg1````arg2````arg3``" );
	context.complete();
}

