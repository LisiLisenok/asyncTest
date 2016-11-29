import herd.asynctest {
	async,
	AsyncTestContext
}
import herd.asynctest.rule {
	SignalRule,
	testRule
}
import ceylon.test {
	test
}
import java.lang {
	Thread
}


"Provides a simple example of signal rule usage."
async class SignalRuleExample() {
	
	shared testRule SignalRule rule = SignalRule();
	
	test shared void myTest(AsyncTestContext context) {
		object thread1 extends Thread() {
			shared actual void run() {
				print("start await signal");
				rule.await(); // awaits until thread2 signals
				print("signal completed");
				context.complete();
			}
		}
		thread1.start();
		
		object thread2 extends Thread() {
			shared actual void run() {
				sleep(1000);
				print("signal!");
				rule.signal(); // wakes up thread1
			}
		}
		thread2.start();
	}
	
}
