
"Test runner provides a control over a test function execution. The package contains staff
 to make a custom runners as well as some build-in runners.  
 
 Each runner has to satisfy [[AsyncTestRunner]] interface which contains only one method:
 		shared formal void run(AsyncMessageContext context, void testing(AsyncMessageContext context), TestInfo info)  
 Where:  
 * `context` is message context to report test results to.  
 * `testing` is test function to be executed.  
 * `info` is information on the test variant to be executed.  
 
 Steps to execute test function with some runner:  
 1. Declare value or function which return value satisfied to [[AsyncTestRunner]] interface.  
    The value or factory function may be either top-level or test function container class attribute / method.
 2. Mark test function or upper-level container with [[runWith]] annotation. Provide as the annotation argument
    declaration of value / function made under item 1.  
 3. Run the test.   
 
 > Test runner executes only test function. All `before`, `after` and `testRule` (including `TestStatement`)
   callbacks are executed outside the runner.  
 
 
 #### Built-in runners  
 
 * [[ChainedRunner]] - chaining a list of runners.  
 * [[ErrorCollectorRunner]] - collects all errors into a one `ceylon.test.engine::MultipleFailureException` exception.  
 * [[RepeatRunner]] - repeats test execution a number of times.  
 
 
 #### Custom runners  
 
 Implement [[AsyncTestRunner]] interface and apply your runner using [[runWith]] annotation.
 "
since( "0.6.0" ) by( "Lis" )
shared package herd.asynctest.runner;
