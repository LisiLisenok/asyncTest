 #### asyncTest
 
 is an extension to SDK `ceylon.test` module with following capabilities:
 * testing asynchronous multithread code
 * common initialization for a set of test functions
 * storing initialized values on test context and retrieving them during test execution
 * executing tests concurrently or sequentially
 * parameterized testing
 * conditional test execution
 * multi-reporting, i.e. several failures or successes can be reported for a one particular test execution (test function)
 * reporting test results using charts (or graphs)
 
 The module is available on [CeylonHerd](https://herd.ceylon-lang.org/modules/herd.asynctest)
 
 
 #### Usage and documentation
 
 The extension is aimed to be run using Ceylon test tool.  
 See usage details in [API documentation](https://modules.ceylon-lang.org/repo/1/herd/asynctest/0.3.0/module-doc/api/index.html)
 
 
 #### Examples
 
 * Test of [Fibonnachi numbers calculation](examples/herd/examples/asynctest/fibonnachi).
   Calculation function is executed on separated thread and returns results using `ceylon.promise`.
 * [Time scheduler](examples/herd/examples/asynctest/scheduler) testing.
 * [Microbenchmark](examples/herd/examples/asynctest/mapperformance) -
   comparative performance test of Ceylon / Java HashMap and TreeMap.
 
 


