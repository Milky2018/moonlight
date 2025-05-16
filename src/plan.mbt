///|
enum Plan[T] {
  Array(collect~ : () -> Array[T])
}

///|
fn Plan::map[T, U](self : Plan[T], f : (T) -> U) -> Plan[U] {
  match self {
    Array(collect~) => Plan::Array(collect=fn() { collect().map(f) })
  }
}
