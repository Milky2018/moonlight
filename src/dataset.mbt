///|
struct Dataset[T] {
  exec_ : (MoonlightContext) -> @moonchor.Located[T, Manager]!Async
}

///|
fn Dataset::exec[T](
  self : Dataset[T],
  ctx : MoonlightContext
) -> @moonchor.Located[T, Manager]!Async {
  (self.exec_)!(ctx)
}

///|
fn Dataset::from_array[T](arr : Array[T]) -> Dataset[Array[T]] {
  {
    exec_: fn(ctx) {
      ctx.chorctx.locally(ctx.config.manager, fn(_unwrapper) { arr })
    },
  }
}

///|
fn Dataset::map[T : @moonchor.Message, U : @moonchor.Message](
  self : Dataset[Array[T]],
  f : (T) -> U
) -> Dataset[Array[U]] {
  {
    exec_: fn(ctx) {
      let data = self.exec!(ctx)
      let len = ctx.chorctx.locally_broadcast!(ctx.config.manager, fn(
        unwrapper
      ) {
        unwrapper.unwrap(data).length()
      })
      let results = ctx.chorctx.locally(ctx.config.manager, fn(_unwrapper) {
        []
      })
      for i in 0..<len {
        let arg = ctx.chorctx.locally(ctx.config.manager, fn(unwrapper) {
          let data = unwrapper.unwrap(data)
          data[i]
        })
        let result = ctx.remote_run_internal!(f, arg)
        ctx.chorctx.locally(ctx.config.manager, fn(unwrapper) {
          let results = unwrapper.unwrap(results)
          let result = unwrapper.unwrap(result)
          results.push(result)
        })
        |> ignore
      }
      results
    },
  }
}

///|
pub async fn Dataset::collect[T](
  self : Dataset[Array[T]],
  ctx : MoonlightContext
) -> ImmediateData[Array[T]] {
  let data = self.exec!(ctx)
  ImmediateData::new(data)
}

///|
test "Dataset test" {
  async fn dataset_test(ctx : MoonlightContext) {
    let data = Dataset::from_array([1, 2, 3, 4])
    let result = data.map(fn(x) { x * 1 })
    let result = result.collect!(ctx)
    result.map(println) |> ignore
  }

  let cluster = local_cluster_config(4)
  cluster.start(dataset_test)
}
