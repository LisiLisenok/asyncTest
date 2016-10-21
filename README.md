#### asyncTest
is an extension to SDK `ceylon.test` module with following capabilities:
 * testing asynchronous multithread code
 * common initialization for a test suite
 * executing tests concurrently or sequentially
 * value-parameterized testing
 * type-parameterized testing
 * conditional test execution
 * organizing complex test conditions into a one flexible expression with matchers
 * multi-reporting: several failures or successes can be reported for a one particular test execution (test function),
   each report is represented as test variant and might be marked with `String` title
 * reporting test results using charts (or graphs)


The module is available on [CeylonHerd](https://herd.ceylon-lang.org/modules/herd.asynctest).  
Current version is 0.5.2.  

 
#### Ceylon compiler / platform

Compiled with Ceylon 1.3.0  
Available on JVM only


#### Dependencies

* ceylon.collection/1.3.0
* ceylon.file/1.3.0
* ceylon.language/1.3.0
* ceylon.promise/1.3.0 shared
* ceylon.test/1.3.0 shared
* java.base/8 JDK


#### Usage and documentation
 
The extension is aimed to be run using Ceylon test tool.  
See usage details in [API documentation](https://modules.ceylon-lang.org/repo/1/herd/asynctest/0.5.2/module-doc/api/index.html).
 
 
#### Examples
 
* Test of [Fibonacci numbers calculation](examples/herd/examples/asynctest/fibonacci).
  Calculation function is executed on separated thread and returns results using `ceylon.promise`.
* [Time scheduler](examples/herd/examples/asynctest/scheduler) testing.
* [Microbenchmark](examples/herd/examples/asynctest/mapperformance) -
  comparative performance test of Ceylon / Java HashMap and TreeMap.
* [Matchers](examples/herd/examples/asynctest/matchers) - matchers usage.
* [Generics](examples/herd/examples/asynctest/generics) - type-parameterized testing.
