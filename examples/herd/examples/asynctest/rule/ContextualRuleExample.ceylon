import herd.asynctest.rule {
	ContextualRule,
	testRule
}
import herd.asynctest {
	AsyncTestContext,
	async
}
import ceylon.test {
	test
}
import herd.asynctest.match {
	EqualTo
}


async class ContextualRuleExample() {
	
	shared testRule ContextualRule<Integer> intValue = ContextualRule<Integer>(0);


	shared test void contextual(AsyncTestContext context) {		
		context.assertThat<Integer>(intValue.get, EqualTo(0), "initial", true);
		try (u1 = intValue.Using(2)) {
			context.assertThat<Integer>(intValue.get, EqualTo(2), "step", true);
			context.assertThat<Integer>(intValue.get, EqualTo(2), "rollback", true);
		}
		context.assertThat<Integer>(intValue.get, EqualTo(0), "second rollback", true);
		context.complete();
	}
	
	shared test void complex(AsyncTestContext context) {
		context.assertThat<Integer>(intValue.get, EqualTo(0), "initial", true);
		try (u1 = intValue.Using(2)) {
			context.assertThat<Integer>(intValue.get, EqualTo(2), "first step", true);
			try(u2 = intValue.Using(3)) {
				context.assertThat<Integer>(intValue.get, EqualTo(3), "second step", true);
			}
			context.assertThat<Integer>(intValue.get, EqualTo(2), "first rollback", true);
		}
		context.assertThat<Integer>(intValue.get, EqualTo(0), "second rollback", true);
		context.complete();
	}
	
	shared test void same(AsyncTestContext context) {
		context.assertThat<Integer>(intValue.get, EqualTo(0), "initial", true);
		try (u1 = intValue.Using(2)) {
			context.assertThat<Integer>(intValue.get, EqualTo(2), "first step", true);
			try (u1) {
				context.assertThat<Integer>(intValue.get, EqualTo(2), "second step", true);
			}
			context.assertThat<Integer>(intValue.get, EqualTo(2), "first rollback", true);
		}
		context.assertThat<Integer>(intValue.get, EqualTo(0), "second rollback", true);
		context.complete();
	}
	
	shared test void manual(AsyncTestContext context) {
		context.assertThat<Integer>(intValue.get, EqualTo(0), "initial", true);
		try (u1 = intValue.Using(2)) {
			context.assertThat<Integer>(intValue.get, EqualTo(2), "step", true);
			value u2 = intValue.Using(3);
			u2.obtain();
			context.assertThat<Integer>(intValue.get, EqualTo(3), "step", true);
			try (u3 = intValue.Using(4)) {
				context.assertThat<Integer>(intValue.get, EqualTo(4), "step", true);
				u2.release(null);
				context.assertThat<Integer>(intValue.get, EqualTo(3), "rollback", true);
				u1.obtain();
				context.assertThat<Integer>(intValue.get, EqualTo(2), "step", true);
				u1.release(null);
				context.assertThat<Integer>(intValue.get, EqualTo(3), "rollback", true);
			}
			context.assertThat<Integer>(intValue.get, EqualTo(2), "rollback", true);
		}
		context.assertThat<Integer>(intValue.get, EqualTo(0), "rollback", true);
		context.complete();
	}
	
}