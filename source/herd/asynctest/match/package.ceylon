
"Basically, matcher is a rule and verification method
 which identifies if submitted test value satisfies this rule or not.
 [[Matcher]] interface is base entry for each matcher.  
 Verification is performed using [[Matcher.match]] method. Result of verification
 is [[MatchResult]] which is simply satisfied / unsatisfied `Boolean` and `String` message describing
 matching operation.  
 
 Matchers may be combined with each other using `and`, `or` and `xor` methods of [[Matcher]] interface.
 Also a matcher can be reverted from <i>meet</i> to <i>don't meet</i> state
 and visa versa using [[Matcher.not]] method.  
 
 Example:
 
 	asyncTestContext.assertThat(joda, IsType(Jedi).and(Mapping((Master master)=>master.padawans, Contains(luke)));

  
 >Matchers are used in conjunction with [[herd.asynctest::AsyncTestContext.assertThat]]
  and [[herd.asynctest::AsyncTestContext.assumeThat]]
 
 --------------------------------------------
 "
by( "Lis" )
shared package herd.asynctest.match;
