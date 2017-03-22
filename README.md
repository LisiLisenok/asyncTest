#### asyncTest  
is an extension to SDK `ceylon.test` module with following capabilities:  

* testing asynchronous multithread code  
* executing tests concurrently or sequentially  
* value- and type- parameterized testing  
* organizing complex test conditions into a one flexible expression with matchers  
* initialization and disposing with either functions or test rules  
* test execution control with test runners  
* conditional test execution  
* multi-reporting: several failures or successes can be reported for a one particular test execution (test function),
  each report is represented as test variant and might be marked with `String` title  
* reporting test results using charts (or plots)  
* benchmarks

The module is available on [Ceylon Herd](https://herd.ceylon-lang.org/modules/herd.asynctest).  
Current version is 0.7.0.  


#### Ceylon compiler / platform  

Compiled with Ceylon 1.3.2  
Available on JVM only  


#### Dependencies  

* ceylon.collection/1.3.2  
* ceylon.file/1.3.2 shared  
* ceylon.language/1.3.2  
* ceylon.test/1.3.2 shared  
* java.base/8 JDK
* java.management/8 JDK  


#### Usage and documentation  
 
The extension is aimed to be run using Ceylon test tool.  
See usage details in [API documentation](https://modules.ceylon-lang.org/repo/1/herd/asynctest/0.7.0/module-doc/api/index.html).
 
 
#### Examples  
 
* Test of [Fibonacci numbers calculation](examples/herd/examples/asynctest/fibonacci).  
  Calculation function is executed on separated thread and returns results using `ceylon.promise`.
* [Time scheduler](examples/herd/examples/asynctest/scheduler) testing.   
* [Benchmarking](examples/herd/examples/asynctest/benchmark) examples of benchmarks.  
* [Matchers](examples/herd/examples/asynctest/matchers) - matchers usage.  
* [Parameterized](examples/herd/examples/asynctest/parameterized) - type- and value- parameterized testing.  
* [Rules](examples/herd/examples/asynctest/rule) - test rules usage.  
