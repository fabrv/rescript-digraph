# Digraph: Directed Graph

Functional-style directed graph implementation in ReScript

Due to performance concerns unfortunately it is not purely functional, so insertions and deletions modify the underlying [Maps](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map).

## Installation

```sh
npm install rescript-digraph
```

## Construction

### `Digraph.make`

Creates a new directed graph.

```rescript
let make: unit => Digraph.t
```

#### Usage
```rescript
let graph = Digraph.make()
```

### `Digraph.insertVertex`

Inserts a new vertex into the graph.

```rescript
let insertVertex: (Digraph.t, 'vertexData) => Digraph.t
```
#### Usage
```rescript
// String vertex data
let graph = Digraph.insertVertex(Digraph.make(), "Jane")
// Number vertex data
let graph = Digraph.insertVertex(Digraph.make(), 42)
// Custom type vertex data
type vertexData = {id: int, name: string}
let graph = Digraph.insertVertex(Digraph.make(), {id: 1, name: "Alice"})
```

### `Digraph.insertEdge`

Inserts a new edge into the graph. Returns the unmodified graph if the edge already exists or vertex does not exist.

```rescript
let insertEdge: (Digraph.t, int, int, 'edgeData) => Digraph.t
```

#### Usage

```rescript
// Unit edge data
let graph = Digraph.insertEdge(Digraph.make(), 0, 1, ())
// Number edge data, could be used as weight for example
let graph = Digraph.insertEdge(Digraph.make(), 0, 1, 42)
// Custom type edge data
type relationship = Sibling | Cousin
type edgeData = {weight: int, relationship: relationship}
let graph = Digraph.make()
  ->insertEdge(0, 1, {weight: 5, relationship: Sibling})
  ->insertEdge(1, 0, {weight: 10, relationship: Cousin})
```

### `Digraph.deleteVertex`

Deletes a vertex from the graph. Returns the unmodified graph if the vertex does not exist.
Also deletes all the edges connected to the vertex.

```rescript
let deleteVertex: (Digraph.t, int) => Digraph.t
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("Jane")
  ->insertVertex("Mary")
let graph = Digraph.deleteVertex(graph, 0)
```

### `Digraph.deleteEdge`

Deletes an edge from the graph. Returns the unmodified graph if the edge does not exist.

```rescript
let deleteEdge: (Digraph.t, int, int) => Digraph.t
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("Jane")
  ->insertVertex("Mary")
  ->insertEdge(0, 1, ())
let graph = Digraph.deleteEdge(graph, 0, 1)
```

## Querying

### `Digraph.getVertex`

Retrieves the data associated with a vertex.

```rescript
let getVertex: (Digraph.t, int) => option<'vertexData>
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("Jane")
  ->insertVertex("Mary")
let jane = Digraph.getVertex(graph, 0)
```

### `Digraph.getEdge`

Retrieves the data associated with an edge.

```rescript
let getEdge: (Digraph.t, int, int) => option<'edgeData>
```

#### Usage
```rescript
type relationship = Sibling | Cousin
type edgeData = {weight: int, relationship: relationship}

let graph = Digraph.make()
  ->insertVertex("Jane")
  ->insertVertex("Mary")
  ->insertEdge(0, 1, {weight: 5, relationship: Sibling})
let janeMaryRelationship = Digraph.getEdge(graph, 0, 1)
```

## Map and Filter

### `Digraph.mapVertex`

Each vertex is transformed by the provided function.

```rescript
let map: (Digraph.t, ('vertexData => 'newVertexData)) => Digraph.t
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("Jane")
  ->insertVertex("Mary")
let newGraph = Digraph.mapVertex(graph, (data) => data ++ " Smith")
```

### `Digraph.mapEdges`

Each edge is transformed by the provided function.

```rescript
let mapEdges: (Digraph.t, ('edgeData => 'newEdgeData)) => Digraph.t
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("Jane")
  ->insertVertex("Mary")
  ->insertEdge(0, 1, {weight: 5, relationship: Sibling})
let newGraph = Digraph.mapEdges(graph, (data) => {data with weight: data.weight + 1})
```

### `Digraph.filterVertex`

Return a new graph containing only the vertices that satisfy the predicate.

```rescript
let filterVertex: (Digraph.t, ('key, 'vertexData => bool)) => Digraph.t
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("Jane")
  ->insertVertex("Mary")
let filteredGraph = Digraph.filterVertex(graph, (key, data) => data == "Jane")
```

## Membership

### `Digraph.hasVertex`

Returns `true` if a vertex with the given ID exists in the graph.

```rescript
let hasVertex: (Digraph.t<'v, 'e>, int) => bool
```

#### Usage
```rescript
let graph = Digraph.make()->insertVertex("Jane")
let exists = Digraph.hasVertex(graph, 0) // true
let exists = Digraph.hasVertex(graph, 99) // false
```

### `Digraph.hasEdge`

Returns `true` if an edge from `from` to `to` exists in the graph.

```rescript
let hasEdge: (Digraph.t<'v, 'e>, int, int) => bool
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("Jane")
  ->insertVertex("Mary")
  ->insertEdge(0, 1, ())
let exists = Digraph.hasEdge(graph, 0, 1) // true
let exists = Digraph.hasEdge(graph, 1, 0) // false
```

## Counts

### `Digraph.vertexCount`

Returns the number of vertices in the graph.

```rescript
let vertexCount: Digraph.t<'v, 'e> => int
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("Jane")
  ->insertVertex("Mary")
let count = Digraph.vertexCount(graph) // 2
```

### `Digraph.edgeCount`

Returns the total number of edges in the graph.

```rescript
let edgeCount: Digraph.t<'v, 'e> => int
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("Jane")
  ->insertVertex("Mary")
  ->insertEdge(0, 1, ())
let count = Digraph.edgeCount(graph) // 1
```

## Enumeration

### `Digraph.vertices`

Returns all vertices as an array of `(id, data)` pairs. Order is insertion order.

```rescript
let vertices: Digraph.t<'v, 'e> => array<(int, 'v)>
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("Jane")
  ->insertVertex("Mary")
let vs = Digraph.vertices(graph) // [(0, "Jane"), (1, "Mary")]
```

### `Digraph.edges`

Returns all edges as an array of `(from, to, data)` triples.

```rescript
let edges: Digraph.t<'v, 'e> => array<(int, int, 'e)>
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("Jane")
  ->insertVertex("Mary")
  ->insertEdge(0, 1, "knows")
let es = Digraph.edges(graph) // [(0, 1, "knows")]
```

### `Digraph.successors`

Returns all outgoing neighbors of a vertex as an array of `(neighborId, edgeData)` pairs.

```rescript
let successors: (Digraph.t<'v, 'e>, int) => array<(int, 'e)>
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("Jane")
  ->insertVertex("Mary")
  ->insertVertex("Bob")
  ->insertEdge(0, 1, ())
  ->insertEdge(0, 2, ())
let succs = Digraph.successors(graph, 0) // [(1, ()), (2, ())]
```

### `Digraph.predecessors`

Returns all incoming neighbors of a vertex as an array of `(neighborId, edgeData)` pairs.

```rescript
let predecessors: (Digraph.t<'v, 'e>, int) => array<(int, 'e)>
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("Jane")
  ->insertVertex("Mary")
  ->insertVertex("Bob")
  ->insertEdge(0, 2, ())
  ->insertEdge(1, 2, ())
let preds = Digraph.predecessors(graph, 2) // [(0, ()), (1, ())]
```

## Structural Queries

### `Digraph.outDegree`

Returns the number of outgoing edges from a vertex. Returns `0` for unknown vertex IDs.

```rescript
let outDegree: (Digraph.t<'v, 'e>, int) => int
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("Jane")
  ->insertVertex("Mary")
  ->insertEdge(0, 1, ())
let deg = Digraph.outDegree(graph, 0) // 1
```

### `Digraph.inDegree`

Returns the number of incoming edges to a vertex. Returns `0` for unknown vertex IDs.

```rescript
let inDegree: (Digraph.t<'v, 'e>, int) => int
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("Jane")
  ->insertVertex("Mary")
  ->insertEdge(0, 1, ())
let deg = Digraph.inDegree(graph, 1) // 1
```

### `Digraph.roots`

Returns all vertices with in-degree 0 (no incoming edges) as an array of `(id, data)` pairs.

```rescript
let roots: Digraph.t<'v, 'e> => array<(int, 'v)>
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("Jane")
  ->insertVertex("Mary")
  ->insertEdge(0, 1, ())
let rs = Digraph.roots(graph) // [(0, "Jane")]
```

### `Digraph.sinks`

Returns all vertices with out-degree 0 (no outgoing edges) as an array of `(id, data)` pairs.

```rescript
let sinks: Digraph.t<'v, 'e> => array<(int, 'v)>
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("Jane")
  ->insertVertex("Mary")
  ->insertEdge(0, 1, ())
let ss = Digraph.sinks(graph) // [(1, "Mary")]
```

## Traversal

### `Digraph.bfs`

Breadth-first traversal from a starting vertex. Returns visited vertices in BFS order as `(id, data)` pairs. Returns `[]` if the start vertex does not exist. Only vertices reachable from `start` are included.

```rescript
let bfs: (Digraph.t<'v, 'e>, int) => array<(int, 'v)>
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("a")
  ->insertVertex("b")
  ->insertVertex("c")
  ->insertEdge(0, 1, ())
  ->insertEdge(0, 2, ())
let visited = Digraph.bfs(graph, 0) // [(0, "a"), (1, "b"), (2, "c")]
```

### `Digraph.dfs`

Depth-first traversal from a starting vertex. Returns visited vertices in DFS order as `(id, data)` pairs. Returns `[]` if the start vertex does not exist. Only vertices reachable from `start` are included.

```rescript
let dfs: (Digraph.t<'v, 'e>, int) => array<(int, 'v)>
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("a")
  ->insertVertex("b")
  ->insertVertex("c")
  ->insertEdge(0, 1, ())
  ->insertEdge(0, 2, ())
let visited = Digraph.dfs(graph, 0) // [(0, "a"), (1, "b"), (2, "c")]
```

## DAG Operations

### `Digraph.topoSort`

Returns a topological ordering of all vertices as `Some(array<(id, data)>)`, or `None` if the graph contains a cycle. Uses Kahn's algorithm.

```rescript
let topoSort: Digraph.t<'v, 'e> => option<array<(int, 'v)>>
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("a")
  ->insertVertex("b")
  ->insertVertex("c")
  ->insertEdge(0, 1, ())
  ->insertEdge(1, 2, ())
switch Digraph.topoSort(graph) {
| Some(order) => // [(0, "a"), (1, "b"), (2, "c")]
| None => // graph has a cycle
}
```

### `Digraph.hasCycle`

Returns `true` if the graph contains at least one cycle.

```rescript
let hasCycle: Digraph.t<'v, 'e> => bool
```

#### Usage
```rescript
let dag = Digraph.make()
  ->insertVertex("a")
  ->insertVertex("b")
  ->insertEdge(0, 1, ())
Digraph.hasCycle(dag) // false

let cyclic = Digraph.make()
  ->insertVertex("a")
  ->insertVertex("b")
  ->insertEdge(0, 1, ())
  ->insertEdge(1, 0, ())
Digraph.hasCycle(cyclic) // true
```

## Transformations

### `Digraph.reverse`

Returns a new graph with all edge directions flipped. Vertex data and IDs are preserved.

```rescript
let reverse: Digraph.t<'v, 'e> => Digraph.t<'v, 'e>
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("a")
  ->insertVertex("b")
  ->insertEdge(0, 1, ())
let rev = Digraph.reverse(graph)
Digraph.hasEdge(rev, 1, 0) // true
Digraph.hasEdge(rev, 0, 1) // false
```

### `Digraph.merge`

Merges two graphs into one. All vertices and edges from both graphs are included. Vertices from `g2` are re-inserted with fresh IDs to avoid collisions.

```rescript
let merge: (Digraph.t<'v, 'e>, Digraph.t<'v, 'e>) => Digraph.t<'v, 'e>
```

#### Usage
```rescript
let g1 = Digraph.make()->insertVertex("Jane")
let g2 = Digraph.make()->insertVertex("Mary")
let merged = Digraph.merge(g1, g2)
Digraph.vertexCount(merged) // 2
```

### `Digraph.subgraph`

Returns the subgraph induced by the given vertex IDs. Only vertices in the list and edges between them are kept.

```rescript
let subgraph: (Digraph.t<'v, 'e>, array<int>) => Digraph.t<'v, 'e>
```

#### Usage
```rescript
let graph = Digraph.make()
  ->insertVertex("a")
  ->insertVertex("b")
  ->insertVertex("c")
  ->insertEdge(0, 1, ())
  ->insertEdge(1, 2, ())
let sub = Digraph.subgraph(graph, [0, 1])
Digraph.vertexCount(sub) // 2
Digraph.hasEdge(sub, 0, 1) // true
Digraph.hasEdge(sub, 1, 2) // false — vertex 2 was excluded
```