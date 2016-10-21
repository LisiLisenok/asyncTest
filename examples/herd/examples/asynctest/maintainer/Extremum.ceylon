import ceylon.test {

	test
}
import herd.asynctest {

	AsyncTestContext,
	parameterized
}
import herd.asynctest.match {

	EqualObjects,
	PassExisted
}


"Input for `min` test: stream and expected minimum value of the stream."
{[[],[{Integer*}, Integer]]*} minimumInput =
	[
		[[], [[for ( i in -100000..100000 ) i], -100000]],
		[[], [[for ( i in -100000..100000 ) -2 * i], -200000]],
		[[], [[for ( i in -100000..100000 ) i + 100000].reversed, 0]],
		[[], [[for ( i in -100000..100000 ) 2 * i - 100000].reversed, -300000]],
		[[], [[for ( i in -100000..100000 ) 2 * ( i - 100000 )], -400000]]
	];


"Input for `max` test: stream and expected maximum value of the stream."
{[[],[{Integer*}, Integer]]*} maximumInput =
	[
		[[], [[for ( i in -100000..100000 ) i], 100000]],
		[[], [[for ( i in -100000..100000 ) -2 * i], 200000]],
		[[], [[for ( i in -100000..100000 ) i + 100000].reversed, 200000]],
		[[], [[for ( i in -100000..100000 ) 2 * i - 100000].reversed, 100000]],
		[[], [[for ( i in -100000..100000 ) 2 * ( i - 100000 )], 0]]
	];


"Groups testing on min and on max."
by( "Lis" )
shared class Extremum()
{
	
	"Runs testing of `min`. Searches minimum value of the given stream using `ceylon.language::min`
	 and compares result to `expected` value using operator `==`."
	test parameterized( `value minimumInput` )
	shared void minWithExpected( AsyncTestContext context, {Integer*} stream, Integer expected ) {
		 context.start();
		 context.assertThat( min( stream ), PassExisted( EqualObjects( expected ) ), "", true );
		 context.complete();
	}
	

	"Runs testing of `max`. Searches maximum value of the given stream using `ceylon.language::max`
	 and compares result to `expected` value using operator `==`."
	test parameterized( `value maximumInput` )
	shared void maxWithExpected( AsyncTestContext context, {Integer*} stream, Integer expected ) {
		context.start();
		context.assertThat( max( stream ), PassExisted( EqualObjects( expected ) ), "", true );
		context.complete();
	}
	
}
