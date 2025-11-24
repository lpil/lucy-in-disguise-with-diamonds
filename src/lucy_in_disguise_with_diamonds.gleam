import lucy_in_disguise_with_diamonds/game
import lustre

pub fn main() {
  let app = game.application()
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}
