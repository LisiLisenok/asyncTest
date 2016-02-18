
"Contains some examples of `asyncTest` usage:
 * [[package herd.examples.asynctest.fibonnachi]] - test of calculation of Fibonnachi numbers in separated thread.
 "
native( "jvm" ) module herd.examples.asynctest "0.1.0" {
	shared import ceylon.promise "1.2.0";
	shared import ceylon.test "1.2.1";
	shared import herd.asynctest "0.1.0";
	shared import java.base "8";
}
