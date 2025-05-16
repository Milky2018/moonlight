///|
struct Person {
  name : String
  age : Int
} derive(ToJson, @json.FromJson, Show)

///|
fn main {
  let p = {
    name : "Tom",
    age : 18
  }

  let j = @json.stringify(p.to_json())
  println(j)
  try {
    let p2: Person = @json.from_json!(@json.parse!(j))
    println(p2)
  } catch {
    _ => {
      println("Error parsing JSON")
    }
  }
}
