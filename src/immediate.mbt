///|
struct ImmediateData[T] {
  data : @moonchor.Located[T, Manager]
}

///|
fn ImmediateData::new[T](data : @moonchor.Located[T, Manager]) -> ImmediateData[T] {
  ImmediateData::{ data, }
}

///|
fn ImmediateData::map[T, U](self : ImmediateData[T], f : (T) -> U) -> ImmediateData[U] {
  self.data.map(f) |> ImmediateData::new
}

///|
test "Simple task" {
  async fn remote_job(ctx : MoonlightContext) {
    let input_data = ctx.immediate(42)
    let result = ctx.remote_run!(fn(x : Int) { x + 1 }, input_data)
    result.map(println) |> ignore
  }

  let cluster = local_cluster_config(4)
  cluster.start(remote_job)
}
