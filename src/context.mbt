///|
struct MoonlightContext {
  chorctx : @moonchor.ChoreoContext
  config : MoonlightClusterConfig
  manager_state : @moonchor.Located[ManagerState, Manager]
}

///|
fn MoonlightContext::new(
  chorctx : @moonchor.ChoreoContext,
  config : MoonlightClusterConfig
) -> MoonlightContext {
  let manager_state = chorctx.locally(config.manager, fn(_unwrapper) {
    ManagerState::new(config.worker_list)
  })
  MoonlightContext::{ chorctx, config, manager_state }
}

///|
pub fn MoonlightContext::immediate[T](
  self : MoonlightContext,
  data : T
) -> ImmediateData[T] {
  let data = self.chorctx.locally(self.config.manager, fn(_unwrapper) { data })
  ImmediateData::new(data)
}

///|
pub async fn MoonlightContext::remote_run[In : @moonchor.Message, Out : @moonchor.Message](
  self : MoonlightContext,
  task : (In) -> Out,
  arg : ImmediateData[In]
) -> ImmediateData[Out] {
  let arg = arg.data
  let result_at_manager = self.remote_run_internal!(task, arg)
  ImmediateData::new(result_at_manager)
}

///|
async fn MoonlightContext::remote_run_internal[In : @moonchor.Message, Out : @moonchor.Message](
  self : MoonlightContext,
  task : (In) -> Out,
  arg : @moonchor.Located[In, Manager]
) -> @moonchor.Located[Out, Manager] {
  let worker = self.manager_state.map(fn(state) { state.get_worker() })
  let worker = self.chorctx.broadcast!(self.config.manager, worker)
  let arg_at_worker = self.chorctx.comm!(self.config.manager, worker, arg)
  let result_at_worker = self.chorctx.locally(worker, fn(unwrapper) {
    let arg = unwrapper.unwrap(arg_at_worker)
    println("Processing data at \{worker.name()}")
    task(arg)
  })
  self.chorctx.comm!(worker, self.config.manager, result_at_worker)
}
