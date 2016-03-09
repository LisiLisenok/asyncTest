import ceylon.test {

	testExecutor
}
import herd.asynctest {

	AsyncTestExecutor
}


"Using matchers."
see( `package herd.asynctest.match` )
by( "Lis" )
testExecutor( `class AsyncTestExecutor` )
shared package herd.examples.asynctest.matchers;
