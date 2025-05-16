///|
struct MoonlightClusterConfig {
  manager : Manager
  worker_list : Array[Worker]
}

///|
pub fn local_cluster_config(worker_num : Int) -> MoonlightClusterConfig {
  {
    manager: Manager::new(),
    worker_list: Array::makei(worker_num, fn(i) {
      Worker::new("MoonlightWorker_\{i}")
    }),
  }
}

///|
fn MoonlightClusterConfig::into_locations(
  self : MoonlightClusterConfig
) -> Array[&@moonchor.Location] {
  let locations : Array[&@moonchor.Location] = []
  locations.push(self.manager)
  for worker in self.worker_list {
    locations.push(worker)
  }
  locations
}

///|
fn make_choreo(
  f : (MoonlightContext) -> Unit!Async,
  config : MoonlightClusterConfig
) -> @moonchor.Choreo[Unit] {
  fn(ctx) {
    let mctx = MoonlightContext::new(ctx, config)
    f!(mctx)
  }
}

///|
pub fn MoonlightClusterConfig::start(
  self : MoonlightClusterConfig,
  f : (MoonlightContext) -> Unit!Async
) -> Unit {
  let backend = @moonchor.make_local_backend(self.into_locations())
  let choreo = make_choreo(f, self)
  @kit.run_async(fn() { @moonchor.run_choreo!(backend, choreo, self.manager) })
  for worker in self.worker_list {
    @kit.run_async(fn() { @moonchor.run_choreo!(backend, choreo, worker) })
  }
}

///|
test "Local cluster start" {
  let cluster = local_cluster_config(4)
  cluster.start(fn(_mctx) { println("Hello, Moonlight!") })
}
