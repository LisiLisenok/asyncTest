import ceylon.test {

	testExecutor
}
import herd.asynctest {

	AsyncTestExecutor,
	maintainer
}


"Example of maintainer usage. See description in [[Maintainer]]."
by( "Lis" )
testExecutor( `class AsyncTestExecutor` )
maintainer( `class Maintainer` )
shared package herd.examples.asynctest.maintainer;
