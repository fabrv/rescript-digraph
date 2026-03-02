type t<'v, 'e> = {
  vertexData: Map.t<int, 'v>,
  adjacency: Map.t<int, Map.t<int, 'e>>,
  nextId: int,
}

let make = (): t<'v, 'e> => {
  vertexData: Map.make(),
  adjacency: Map.make(),
  nextId: 0,
}

let insertVertex = ({vertexData, adjacency, nextId}: t<'v, 'e>, vdata: 'v): t<'v, 'e> => {
  vertexData: Data.Map.set(vertexData, nextId, vdata),
  adjacency: Data.Map.set(adjacency, nextId, Map.make()),
  nextId: nextId + 1,
}

let insertEdge = ({vertexData, adjacency, nextId}: t<'v, 'e>, from: int, to: int, edgeData: 'e) => {
  vertexData,
  adjacency: if vertexData->Map.has(to) {
    adjacency->Data.Map.adjust(from, map => map->Data.Map.set(to, edgeData))
  } else {
    adjacency
  },
  nextId,
}

let getVertex = ({vertexData}: t<'v, 'e>, vid: int) => vertexData->Map.get(vid)
let getEdge = ({adjacency}: t<'v, 'e>, from: int, to: int) =>
  adjacency->Map.get(from)->Option.flatMap(map => map->Map.get(to))

let mapVertices = ({vertexData, adjacency, nextId}: t<'v, 'e>, fn: 'v => 'v): t<'v, 'e> => {
  vertexData: vertexData->Data.Map.map(fn),
  adjacency,
  nextId,
}

let mapEdges = ({vertexData, adjacency, nextId}: t<'v, 'e>, fn: 'e => 'e): t<'v, 'e> => {
  vertexData,
  adjacency: adjacency->Data.Map.map(adj => adj->Data.Map.map(fn)),
  nextId,
}

let filterVertex = ({vertexData, adjacency, nextId}: t<'v, 'e>, fn: (int, 'v) => bool): t<'v, 'e> => {
  let filtered = vertexData->Data.Map.filter(fn)
  {
    vertexData: filtered,
    adjacency: adjacency
      ->Data.Map.filter((k, _) => filtered->Map.has(k))
      ->Data.Map.map(adj => adj->Data.Map.filter((k, _) => filtered->Map.has(k))),
    nextId,
  }
}

let deleteVertex = ({vertexData, adjacency, nextId}: t<'v, 'e>, vid: int): t<'v, 'e> => {
  vertexData: vertexData->Data.Map.filter((k, _) => k !== vid),
  adjacency: {
    adjacency->Map.delete(vid)->ignore
    adjacency->Data.Map.map(adj => adj->Data.Map.filter((k, _) => k !== vid))
  },
  nextId,
}

let deleteEdge = ({vertexData, adjacency, nextId}: t<'v, 'e>, from: int, to: int) => {
  vertexData,
  adjacency: adjacency->Data.Map.adjust(from, adj => adj->Data.Map.delete(to)),
  nextId,
}

// Membership

let hasVertex = ({vertexData}: t<'v, 'e>, vid: int): bool =>
  vertexData->Map.has(vid)

let hasEdge = ({adjacency}: t<'v, 'e>, from: int, to: int): bool =>
  adjacency->Map.get(from)->Option.map(adj => adj->Map.has(to))->Option.getOr(false)

// Counts

let vertexCount = ({vertexData}: t<'v, 'e>): int =>
  vertexData->Map.size

let edgeCount = ({adjacency}: t<'v, 'e>): int =>
  adjacency->Map.entries->Iterator.toArray->Array.reduce(0, (acc, (_, adj)) => acc + adj->Map.size)

// Enumeration

let vertices = ({vertexData}: t<'v, 'e>): array<(int, 'v)> =>
  vertexData->Map.entries->Iterator.toArray

let edges = ({adjacency}: t<'v, 'e>): array<(int, int, 'e)> =>
  adjacency->Map.entries->Iterator.toArray->Array.flatMap(((from, adj)) =>
    adj->Map.entries->Iterator.toArray->Array.map(((to, edgeData)) => (from, to, edgeData))
  )

let successors = ({adjacency}: t<'v, 'e>, vid: int): array<(int, 'e)> =>
  adjacency->Map.get(vid)->Option.map(adj => adj->Map.entries->Iterator.toArray)->Option.getOr([])

let predecessors = ({adjacency}: t<'v, 'e>, vid: int): array<(int, 'e)> =>
  adjacency->Map.entries->Iterator.toArray->Array.filterMap(((from, adj)) =>
    adj->Map.get(vid)->Option.map(edgeData => (from, edgeData))
  )

// Structural queries

let outDegree = ({adjacency}: t<'v, 'e>, vid: int): int =>
  adjacency->Map.get(vid)->Option.map(adj => adj->Map.size)->Option.getOr(0)

let inDegree = ({adjacency}: t<'v, 'e>, vid: int): int =>
  adjacency->Map.entries->Iterator.toArray->Array.reduce(0, (acc, (_, adj)) =>
    adj->Map.has(vid) ? acc + 1 : acc
  )

let roots = (g: t<'v, 'e>): array<(int, 'v)> =>
  g->vertices->Array.filter(((vid, _)) => g->inDegree(vid) === 0)

let sinks = (g: t<'v, 'e>): array<(int, 'v)> =>
  g->vertices->Array.filter(((vid, _)) => g->outDegree(vid) === 0)

// Traversal

let bfs = (g: t<'v, 'e>, start: int): array<(int, 'v)> => {
  if !(g->hasVertex(start)) {
    []
  } else {
    let visited: Map.t<int, bool> = Map.make()
    visited->Map.set(start, true)
    let frontier = ref([start])
    let result = ref([])
    while frontier.contents->Array.length > 0 {
      let nextFrontier = ref([])
      frontier.contents->Array.forEach(vid =>
        switch g->getVertex(vid) {
        | Some(vdata) =>
          result := result.contents->Array.concat([(vid, vdata)])
          g->successors(vid)->Array.forEach(((neighbor, _)) =>
            if !(visited->Map.has(neighbor)) {
              visited->Map.set(neighbor, true)
              nextFrontier := nextFrontier.contents->Array.concat([neighbor])
            }
          )
        | None => ()
        }
      )
      frontier := nextFrontier.contents
    }
    result.contents
  }
}

let dfs = (g: t<'v, 'e>, start: int): array<(int, 'v)> => {
  if !(g->hasVertex(start)) {
    []
  } else {
    let visited: Map.t<int, bool> = Map.make()
    let result = ref([])
    let rec visit = vid =>
      if !(visited->Map.has(vid)) {
        visited->Map.set(vid, true)
        switch g->getVertex(vid) {
        | Some(vdata) =>
          result := result.contents->Array.concat([(vid, vdata)])
          g->successors(vid)->Array.forEach(((neighbor, _)) => visit(neighbor))
        | None => ()
        }
      }
    visit(start)
    result.contents
  }
}

// DAG operations

let topoSort = (g: t<'v, 'e>): option<array<(int, 'v)>> => {
  // Kahn's algorithm: process vertices with in-degree 0, decrement neighbors
  let inDegrees: Map.t<int, int> = Map.make()
  g->vertices->Array.forEach(((vid, _)) => inDegrees->Map.set(vid, 0))
  g->edges->Array.forEach(((_, to, _)) =>
    inDegrees->Map.set(to, inDegrees->Map.get(to)->Option.getOr(0) + 1)
  )
  let queue = ref(
    inDegrees->Map.entries->Iterator.toArray->Array.filterMap(((vid, deg)) =>
      deg === 0 ? Some(vid) : None
    )
  )
  let result = ref([])
  while queue.contents->Array.length > 0 {
    let nextQueue = ref([])
    queue.contents->Array.forEach(vid =>
      switch g->getVertex(vid) {
      | Some(vdata) =>
        result := result.contents->Array.concat([(vid, vdata)])
        g->successors(vid)->Array.forEach(((neighbor, _)) => {
          let newDeg = inDegrees->Map.get(neighbor)->Option.getOr(0) - 1
          inDegrees->Map.set(neighbor, newDeg)
          if newDeg === 0 {
            nextQueue := nextQueue.contents->Array.concat([neighbor])
          }
        })
      | None => ()
      }
    )
    queue := nextQueue.contents
  }
  if result.contents->Array.length === g->vertexCount {
    Some(result.contents)
  } else {
    None
  }
}

let hasCycle = (g: t<'v, 'e>): bool =>
  g->topoSort->Option.isNone

// Transformations

let reverse = ({vertexData, adjacency, nextId}: t<'v, 'e>): t<'v, 'e> => {
  let newAdj: Map.t<int, Map.t<int, 'e>> = Map.make()
  vertexData->Map.entries->Iterator.toArray->Array.forEach(((vid, _)) =>
    newAdj->Map.set(vid, Map.make())
  )
  adjacency->Map.entries->Iterator.toArray->Array.forEach(((from, adj)) =>
    adj->Map.entries->Iterator.toArray->Array.forEach(((to, edgeData)) =>
      newAdj->Map.get(to)->Option.map(toAdj => toAdj->Map.set(from, edgeData))->ignore
    )
  )
  {vertexData, adjacency: newAdj, nextId}
}

let merge = (g1: t<'v, 'e>, g2: t<'v, 'e>): t<'v, 'e> => {
  // Re-insert all of g2's vertices into g1, tracking the old -> new ID mapping
  let idMap: Map.t<int, int> = Map.make()
  let g = g2->vertices->Array.reduce(g1, (g, (oldId, vdata)) => {
    let newG = g->insertVertex(vdata)
    idMap->Map.set(oldId, newG.nextId - 1)
    newG
  })
  // Re-insert g2's edges using remapped IDs
  g2->edges->Array.reduce(g, (g, (from, to, edgeData)) =>
    switch (idMap->Map.get(from), idMap->Map.get(to)) {
    | (Some(newFrom), Some(newTo)) => g->insertEdge(newFrom, newTo, edgeData)
    | _ => g
    }
  )
}

let subgraph = (g: t<'v, 'e>, vids: array<int>): t<'v, 'e> => {
  let vidSet: Map.t<int, unit> = Map.make()
  vids->Array.forEach(vid => vidSet->Map.set(vid, ()))
  g->filterVertex((vid, _) => vidSet->Map.has(vid))
}
