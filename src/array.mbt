///|
struct LightArray[T] {
  ctx : MoonlightContext
  data : @moonchor.Located[Array[T], Manager]
}

///|
pub fn LightArray::collect[T](self : LightArray[T]) -> ImmediateData[Array[T]] {
  ImmediateData::new(self.data)
}

///|
pub async fn LightArray::map[T : @moonchor.Message, U : @moonchor.Message](
  self : LightArray[T],
  f : (T) -> U
) -> LightArray[U] {
  let len = self.ctx.chorctx.locally_broadcast!(self.ctx.config.manager, fn(
    unwrapper
  ) {
    unwrapper.unwrap(self.data).length()
  })
  let results = self.ctx.chorctx.locally(self.ctx.config.manager, fn(
    _unwrapper
  ) {
    []
  })
  for i in 0..<len {
    let arg = self.ctx.chorctx.locally(self.ctx.config.manager, fn(unwrapper) {
      let data = unwrapper.unwrap(self.data)
      data[i]
    })
    let result = self.ctx.remote_run_internal!(f, arg)
    self.ctx.chorctx.locally(self.ctx.config.manager, fn(unwrapper) {
      let results = unwrapper.unwrap(results)
      let result = unwrapper.unwrap(result)
      results.push(result)
    })
    |> ignore
  }
  LightArray::{ ctx: self.ctx, data: results }
}

///|
test "Light array basic" {
  async fn array_map_job(ctx : MoonlightContext) {
    ctx.array([1, 2, 3, 4]).map!(fn(i) { i * 2 }).collect().map(println)
    |> ignore
  }

  let cluster = local_cluster_config(4)
  cluster.start(array_map_job)
}
