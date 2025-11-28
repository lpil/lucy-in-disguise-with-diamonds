import lustre/effect

@external(javascript, "../lucy_in_disguise_with_diamonds_ffi.mjs", "wait")
pub fn wait(ms: Int, fun: fn() -> anything) -> Nil

pub fn later(ms: Int, dispatch message: message) -> effect.Effect(message) {
  use dispatch <- effect.from
  use <- wait(ms)
  dispatch(message)
}
