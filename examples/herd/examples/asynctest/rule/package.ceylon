"Examples of test rules:
 
 * [[ContextualRuleExample]] - usage of `herd.asynctest.rule::ContextualRule` which stores values locally to thread.  
 * [[ResourceRuleExample]] - usage of `herd.asynctest.rule::ResourceRule` which provides access to resource stored in module.  
 * [[ServerCustomRule]] - applies custom rule to initialize `ceylon.http.server::Server` and runs it in background.  
 * [[SignalRuleExample]] - simple example of signal rule usage.  
 "
shared package herd.examples.asynctest.rule;
