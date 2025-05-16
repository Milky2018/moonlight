///|
priv struct Manager {} derive(Show, Eq, Hash)

///|
impl @moonchor.Location for Manager with name(_) {
  "MoonlightManager"
}

///|
fn Manager::new() -> Manager {
  Manager::{  }
}

///|
priv struct ManagerState {
  mut counter : Int
  worker_list : Array[Worker]
}

///|
fn ManagerState::new(worker_list : Array[Worker]) -> ManagerState {
  ManagerState::{ counter: 0, worker_list }
}

///|
fn ManagerState::get_worker(self : ManagerState) -> Worker {
  let worker = self.worker_list[self.counter % self.worker_list.length()]
  self.counter = self.counter + 1
  worker
}
