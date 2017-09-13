import ceylon.interop.java {
	createJavaObjectArray
}
import java.lang.reflect {
	Proxy,
	Method,
	InvocationHandler
}
import java.lang {
	ObjectArray,
	Types
}
import herd.asynctest.benchmark {
	benchmark,
	writeRelativeToFastest,
	Options,
	NumberOfLoops,
	SingleBench
}
import herd.asynctest {
	AsyncTestContext,
	async
}
import ceylon.test {
	test
}


interface I {
	shared formal Integer plusOne(Integer i);
}

class II() satisfies I {
	shared actual Integer plusOne(Integer i) => i + 1;
}


I instanceDecl() {
	return object satisfies I {
		II ii = II();
		value f = `I.plusOne`.bind(ii);
		shared actual Integer plusOne(Integer i) {
			return f.apply(i);
		}
	};
}


T proxyInstance<T>(T delegate) given T satisfies Object {
	assert (
		is T ret = Proxy.newProxyInstance (
			Types.classForType<T>().classLoader,
			createJavaObjectArray({Types.classForType<T>()}),
			object satisfies InvocationHandler {
				shared actual Object invoke(Object? proxy, Method method, ObjectArray<Object>? objectArray) {
					method.accessible = true;
					if (exists objectArray) {
						//return method.invoke(delegate, *objectArray.iterable);
						return method.invoke(delegate, *objectArray);
					}
					else {
						return method.invoke(delegate);
					}
					
				}
			}
		)
	);
	return ret;
}


"Runs comparative benchmark of direct function call, call via metamodel and call via java proxy."
shared test async void proxyAndMetaBenchmark(AsyncTestContext context) {
	writeRelativeToFastest (
		context,
		benchmark (
			Options(NumberOfLoops(1000), NumberOfLoops(100)),
			[
			SingleBench("direct", II().plusOne),
			SingleBench("meta", instanceDecl().plusOne),
			SingleBench("proxy", proxyInstance<I>(II()).plusOne)
			],
			[1], [2], [3]
		)
	);
	context.complete();
}
