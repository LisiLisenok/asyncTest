package herd.asynctest.internal;

import java.lang.Thread;

public class CurrentThread {
	public static boolean isWorks() {
		Thread thr = Thread.currentThread(); 
		return !thr.isInterrupted() && thr.isAlive();
	}
}
