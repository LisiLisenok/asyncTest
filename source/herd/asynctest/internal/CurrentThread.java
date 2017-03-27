package herd.asynctest.internal;

import java.lang.Thread;

public class CurrentThread {
	public static boolean isAlive() {
		Thread thr = Thread.currentThread(); 
		return !thr.isInterrupted() && thr.isAlive();
	}
}
