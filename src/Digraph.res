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
  adjacency: adjacency->Data.Map.adjust(from, map => map->Data.Map.set(to, edgeData)),
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

let filterVertex = ({vertexData, adjacency, nextId}: t<'v, 'e>, fn: (int, 'e) => 'e): t<'v, 'e> => {
  vertexData: vertexData->Data.Map.filter(fn),
  adjacency,
  nextId
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
  adjacency: {
    adjacency
    ->Map.get(from)
    ->Option.map(adj => adj->Map.delete(to))
    ->Option.ignore
    adjacency
  },
  nextId,
}
