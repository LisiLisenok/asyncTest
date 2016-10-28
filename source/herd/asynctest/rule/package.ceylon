"Test rules provide a way to perform initialization / disposing before / after test execution and to modify test behaviour.  
 
 There 3 types of test rule:
 1. [[SuiteRule]] which performs initialization or disposing before or after execution of _all_ tests in the scope
    (package for top-level value or class for attribute).
 2. [[TestRule]] which performs initialization or disposing before or after execution of _each_ test in the scope
    (package for top-level value or class for attribute).
 3. [[TestStatement]] which is evaluated after test completion and indended to add
    success or failure report to the test results. 
 
 > All 3 types are represented as interfaces and may be combined using types intersection.  
 
 In order to apply a rule a top-level value or class attribute satisfied some of the rule interfaces has to be declared
 and annotated with [[testRule]] annotation.  
 
 
 > Top-level rule is applied to top-level functions within the same package.  
 
 
 > Attribute is applide to methods of the same class.  
 
 
 > Attribute has to be shared. Inherited attributes are considered also.  
 
 
 > The rules inititalization / dispose functions takes [[herd.asynctest::AsyncPrePostContext]] and the interface contract
   has to be adopted: [[herd.asynctest::AsyncPrePostContext.proceed]] or [[herd.asynctest::AsyncPrePostContext.abort]]
   has to be called in order to complete / abort initialization / disposing process.  
   
   
 > [[TestStatement.apply]] takes [[herd.asynctest::AsyncTestContext]] and the interface contract
   has to be adopted: [[herd.asynctest::AsyncTestContext.complete]] has to be called
   in order to complete the statement evaluation.  

  
 #### Example:  
 
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
 
 
 #### Build-in test rules:  
 * [[AtomicValueRule]] provides atomic operations possibility with some value.
   The value is re-initialized before _each_ test.  
 * [[ContextualRule]] stores values local to the current thread.
   This means each thread get its own copy of the value. The value is re-initialized before eqch test.
 * [[CounterRule]] provides an atomic counter reseted to initial value before _each_ test.  
 * [[ResourceRule]] represents a file packaged within a module and loaded before all tests started.  
 * [[TemporaryDirectoryRule]] represents a temporary directory which is created before _each_ test and destroyed after.  
 * [[TemporaryFileRule]] represents a temporary file which is created before _each_ test and destroyed after.  
 * [[VerifyRule]] extends [[AtomicValueRule]] and additionally verifies the stored value against a given matcher
   after the test.  
   
 Why every build-in test rule implements `non-default` rule methods? Since each method calls
 [[herd.asynctest::AsyncPrePostContext.proceed]] or [[herd.asynctest::AsyncPrePostContext.abort]]
 which completes initialization / disposing. Delegation should be used instead of extending.  
 
 
 > Reminding: annotate the rule top-level value or attribute with [[testRule]]!
 
 "
since( "0.6.0" ) by( "Lis" )
shared package herd.asynctest.rule;
