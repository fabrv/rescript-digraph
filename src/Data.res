module Map = {
  let set = (map: Map.t<'k, 'v>, key: 'k, value: 'v) => {
    map->Map.set(key, value)
    map
  }

  let adjust = (map: Map.t<'k, 'v>, key: 'k, fn: 'v => 'v) => {
    map->Map.get(key)->Option.map(val => map->Map.set(key, fn(val)))->ignore
    map
  }

  let delete = (map: Map.t<'k, 'v>, key: 'k) => {
    map->Map.delete(key)->ignore
    map
  }

  let filter = (map: Map.t<'k, 'v>, fn: ('k, 'v) => bool) => {
    map->Map.entries->Iterator.filter(((k, v)) => fn(k, v))->Map.fromIterator
  }

  let map = (map: Map.t<'k, 'v>, fn: 'v => 'b) => {
    map->Map.entries->Iterator.map(((k, v)) => (k, fn(v)))->Map.fromIterator
  }
}
