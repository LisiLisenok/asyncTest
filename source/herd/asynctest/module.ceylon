
"
 ### asyncTest
 is an extension of SDK `ceylon.test` with following capabilities:
 * testing asynchronous multithread code
 * reporting several failures for a one particular test execution (test function)
 * mark each failure with `String` title
 * instantiating private classes and invoking private functions of tested module without additional dependecies in
 
 The extension is based on:
 * [[AsyncTestContext]] interface which test function has to operate with (basically, reports on fails to).
 * [[AsyncTestExecutor]] class which satisfies `ceylon.test.engine.spi::TestExecutor` and used by `ceylon.test` module
   to execute test functions.
 
 
 ### test procedure:
 1. Declare test function, which accepts [[AsyncTestContext]] as the first argument:
 			test void doTesting(AsyncTestContext context) {...}
    The other arguments have to be in accordance with `ceylon.test::parameters` annotation.
    Mark test function with `ceylon.test::test` annotation.
 2. Code test function according to [[AsyncTestContext]] specification:
 	* call [[AsyncTestContext.start]] before start testing
 	* perform testing and report on fails via [[AsyncTestContext]]
 	* call [[AsyncTestContext.complete]] to complete the testing
 3. Apply `ceylon.test::testExecutor` annotation:
 	* at module level to execute every functions / classes marked with test in the given module
 			testExecutor(\`class AsyncTestExecutor\`)
 			native(\"jvm\")
 			module mymodule \"1.0.0\"
 	* at function level to execute the given function only
 			testExecutor(\`class AsyncTestExecutor\`)
 			test void doTesting(AsyncTestContext context) {...}
 4. Run test in IDE or command line.
 
 Also see some details in documentation on [[AsyncTestExecutor]] and [[AsyncTestContext]].
 
 ### instantiating private classes
 See [[loadAndInstantiate]]
 
 ### invoking private functions
 See [[loadTopLevelFunction]]
 
 "
license (
	"
	 The MIT License (MIT)
	 
	 Permission is hereby granted, free of charge, to any person obtaining a copy
	 of this software and associated documentation files (the \"Software\"), to deal
	 in the Software without restriction, including without limitation the rights
	 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	 copies of the Software, and to permit persons to whom the Software is
	 furnished to do so, subject to the following conditions:
	 
	 The above copyright notice and this permission notice shall be included in all
	 copies or substantial portions of the Software.
	 
	 THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	 SOFTWARE."
)
by( "Lis" )
native( "jvm" )
module herd.asynctest "0.1.0" {
	import org.jboss.modules "1.4.4.Final";
	import java.base "8";
	shared import ceylon.test "1.2.1";
	import ceylon.collection "1.2.1";
	import ceylon.runtime "1.2.1";
}
