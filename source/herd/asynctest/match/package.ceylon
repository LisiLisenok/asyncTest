
"Matchers are intended to organize complex test conditions into a one flexible expression.  
 Each matcher is requirements specification and verification method
 which identifies if submitted test value satisfies matcher specification or not.  
 [[Matcher]] interface is base entry for each matcher.  
 Verification is performed using [[Matcher.match]] method. Result of verification
 is [[MatchResult]] which is simply satisfied / unsatisfied `Boolean` and `String` message describing
 matching operation.  
 
 Matchers may be combined with each other using logical operators: `and or `or` which are
 methods of [[Matcher]] interface. Also a matcher can be reverted from _satisfied_ to _unsatisfied_ state
 and visa versa using [[Matcher.not]] method.  
 
 Example:
 
 	asyncTestContext.assertThat(joda, IsType<Jedi>().and(Mapping((Master master)=>master.padawans, Contains(luke)));

  
 > Matchers are aimed to be used in conjunction with [[herd.asynctest::AsyncTestContext.assertThat]] method.  
 
 > Custom matchers: just implemeny [[Matcher]] interface.  
 
 --------------------------------------------
 "
since( "0.4.0" ) by( "Lis" )
shared package herd.asynctest.match;
