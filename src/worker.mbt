///|
priv struct Worker {
  id : String
} derive(Show, Eq, Hash, @json.FromJson, ToJson)

///|
impl @moonchor.Location for Worker with name(self) {
  self.id
}

///|
fn Worker::new(id : String) -> Worker {
  Worker::{ id, }
}
