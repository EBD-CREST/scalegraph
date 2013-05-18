package org.scalegraph.xpregel;

import org.scalegraph.util.MemoryChunk;
import org.scalegraph.graph.SparseMatrix;

class GraphEdge [E] {E haszero} {
	var offsets :MemoryChunk[Long];
	var vertexes :MemoryChunk[Long];
	var value : MemoryChunk[E];
	
	def this(m :SparseMatrix) {
		val numEdges = m.vertexes.size();
		offsets = m.offsets;
		vertexes = m.vertexes;
		value = new MemoryChunk[E](numEdges);
	}
	
	def this() { }
}
