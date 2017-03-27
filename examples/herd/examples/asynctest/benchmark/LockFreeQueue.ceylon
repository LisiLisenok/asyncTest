import java.util.concurrent.atomic {
	AtomicReference
}


"Lock free queue."
shared class LockFreeQueue<Item>() given Item satisfies Object {
	
	class Node (
		shared variable Item? item = null,
		Node? nextNode = null 
	) {
		shared AtomicReference<Node?> next = AtomicReference<Node?>( nextNode );
	}
	
	
	AtomicReference<Node> head = AtomicReference<Node>( Node() );
	AtomicReference<Node> tail = AtomicReference<Node>( head.get() );
	
	shared void enqueue( Item item ) {
		Node newTail = Node( item );
		variable Node oldTail = tail.get();
		while ( !oldTail.next.compareAndSet( null, newTail ) ) {
			oldTail = tail.get();
		}
		// adjust tail
		tail.compareAndSet( oldTail, newTail );
	}
	
	shared Item? dequeue() {
		// current head
		variable Node oldHead = head.get();
		// store next in order to retriev correct item even if next will be replaced 
		variable Node? next = oldHead.next.get();
		// shift head to the next
		while ( next exists, !head.compareAndSet( oldHead, next ) ) {
			oldHead = head.get();
			next = oldHead.next.get();
		}
		return next?.item;
	}
	
	shared Boolean empty => !head.get().next.get() exists;
	
}
