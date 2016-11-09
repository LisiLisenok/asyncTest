"
 ### Test rules
 
 Provide a way to perform initialization / disposing before / after test execution and to modify test behaviour.
 
 Each rule is top-level value or class attribute which satisfies some of the following interfaces:  
 1. [[SuiteRule]] performs initialization or disposing before or after execution of _all_ tests in the scope
    (package for top-level value or class for attribute).  
 2. [[TestRule]] performs initialization or disposing before or after execution of _each_ test in the scope
    (package for top-level value or class for attribute).  
 3. [[TestStatement]] is indended to add success or failure report to the test results
    and is evaluated after _each_ test is completed.  
 
 In order to apply a rule a top-level value or class attribute satisfied some of the rule interfaces has to be declared
 and annotated with [[testRule]] annotation.  
 
 
 > Top-level rule is applied to top-level functions within the same package.  
 
 > Attribute is applide to methods of the same class.  
 
 > Attribute has to be shared. Inherited attributes are evaluated also.  
 
 > The rules inititalization / dispose functions takes [[herd.asynctest::AsyncPrePostContext]] and the interface contract
   has to be adopted: [[herd.asynctest::AsyncPrePostContext.proceed]] or [[herd.asynctest::AsyncPrePostContext.abort]]
   has to be called in order to complete / abort initialization / disposing process.  
   
 > [[TestStatement.apply]] takes [[herd.asynctest::AsyncTestContext]] and the interface contract
   has to be adopted: [[herd.asynctest::AsyncTestContext.complete]] has to be called
   in order to complete the statement evaluation.  

  
 ### Example:  
 
 		testRule object myRule satisfies TestRule & SuiteRule & TestStatement {
 			shared actual default void after(AsyncPrePostContext context) {
 				context.proceed();
 			}
 
 			shared actual default void before(AsyncPrePostContext context) {
 				context.proceed();
 			}
 
 			shared actual default void dispose(AsyncPrePostContext context) {
 				context.proceed();
 			}
 
 			shared actual default void initialize(AsyncPrePostContext context) {
 				context.proceed();
 			}
 
 			shared actual void apply(AsyncTestContext context) {
 				context.complete();
 			}
 		}
 		
 		test async testFunction1(AsyncTestContext context) => ...
 		test async testFunction2(AsyncTestContext context) => ...
 		
 		
 		
 		class MyTestClass() {
 			shared testRule object myClassRule satisfies TestRule {
 				shared actual void after(AsyncPrePostContext context) {
 					context.proceed();
 				}
 
 				shared actual void before(AsyncPrePostContext context) {
 					context.proceed();
 				}
 			}
 			
 			test async testMethod1(AsyncTestContext context) => ...
 			test async testMethod2(AsyncTestContext context) => ...
 		}
 
 In the above example `myRule` is evaluated before / after execution of top-level function `testFunction1` and `testFunction2`
 while `MyTestClass.myClassRule` is evaluated before / after execution of methods `testMethod1` and `testMethod2`.  
 
 
 ### Build-in test rules:  
 * [[AtomicValueRule]] provides atomic operations with some value.
   The value is re-initialized before _each_ test.  
 * [[ContextualRule]] stores values local to the current thread.
   This means each thread get its own copy of the value. The value is re-initialized before _each_ test.
 * [[CounterRule]] provides an atomic counter reseted to initial value before _each_ test.  
 * [[LockAccessRule]] tool for controlling access to a shared resource by multiple threads.  
 * [[MeterRule]] collects statistic data on an execution time and on a rate (per second) at which a set of events occur.  
 * [[ResourceRule]] represents a file packaged within a module and loaded before _all_ tests started.  
 * [[StatisticRule]] provides statistics data for some variate values.  
 * [[TemporaryDirectoryRule]] represents a temporary directory which is created before _each_ test and destroyed after.  
 * [[TemporaryFileRule]] represents a temporary file which is created before _each_ test and destroyed after.
 * [[Verifier]] extracts value from source function after _each_ test and verifies it with given matcher.    
 * [[VerifyRule]] extends [[AtomicValueRule]] and additionally verifies the stored value against a given matcher
   after _each_ test.  
   
 Why every build-in test rule implements `non-default` rule methods? Since each method calls
 [[herd.asynctest::AsyncPrePostContext.proceed]] or [[herd.asynctest::AsyncPrePostContext.abort]]
 which completes initialization / disposing. Delegation should be used instead of extending.  
 
 
 > Reminding: annotate the rule top-level value or attribute with [[testRule]]!
 
 "
since( "0.6.0" ) by( "Lis" )
shared package herd.asynctest.rule;