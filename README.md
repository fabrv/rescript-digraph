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