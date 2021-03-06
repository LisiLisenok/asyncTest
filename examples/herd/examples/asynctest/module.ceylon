
"Contains some examples of `asyncTest` usage:
 * [[package herd.examples.asynctest.benchmark]] - examples of benchmark test    
 * [[package herd.examples.asynctest.fibonacci]] - test of calculation of Fibonacci numbers in separated thread  
 * [[package herd.examples.asynctest.mapperformance]] - comparative performance test of Ceylon - Java HashMap and TreeMap  
 * [[package herd.examples.asynctest.matchers]] - several examples of matchers from `package herd.asynctest.match`  
 * [[package herd.examples.asynctest.parameterized]] - type- and value- parameterized testing  
 * [[package herd.examples.asynctest.rule]] - usage of the test rules  
 * [[package herd.examples.asynctest.scheduler]] - time scheduler testing  
 * [[package herd.examples.asynctest.vertx]] - unit testing of Vert.x application  
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
module herd.examples.asynctest "0.7.1" {
	shared import ceylon.collection "1.3.3";
	shared import ceylon.http.server "1.3.3";
	shared import ceylon.http.client "1.3.3";
	shared import ceylon.http.common "1.3.3";
	shared import ceylon.promise "1.3.3";
	shared import ceylon.test "1.3.3.1";
	shared import herd.asynctest "0.7.1";
	shared import java.base "8";
	import ceylon.interop.java "1.3.3";
	import io.vertx.ceylon.core "3.4.2";
}
