import gleam/float
import gleam/list
import glor
import lucy_in_disguise_with_diamonds/time
import lustre/effect

const success_sounds = [
  "fourthwoods__kara-hooray.ogg",
  "fourthwoods__kara-thats-it.ogg",
  "fourthwoods__kara-woohoo.ogg",
  "fourthwoods__kara-yahoo.ogg",
  "fourthwoods__kara-yeehaw-2.ogg",
  "fourthwoods__kara-yep.ogg",
  "fourthwoods__kara-yippee.ogg",
  "fourthwoods__kara-you-found-it.ogg",
]

pub fn play_success() -> effect.Effect(msg) {
  use _dispatch <- effect.from
  case list.sample(success_sounds, 1) {
    [] -> Nil
    [sound, ..] -> {
      let player = glor.new(sound)
      glor.set_loop(player, False)
      glor.play(player)
    }
  }
}

pub fn play_music() -> effect.Effect(msg) {
  use _dispatch <- effect.from
  let track =
    "Seth_Makes_Sound_-_Cute_Background_Loop_Song_Thing_(lpil_edit).mp3"
  let player = glor.new(track)
  glor.set_loop(player, True)
  glor.set_volume(player, 0.0)
  glor.play(player)
  ramp_up(player, to: 0.3)
}

pub fn play_logo_jingle() -> effect.Effect(msg) {
  use _dispatch <- effect.from
  use <- time.wait(200)
  let track = "gleam-ah.mp3"
  let player = glor.new(track)
  glor.set_volume(player, 0.4)
  glor.play(player)
}

fn ramp_up(player: glor.AudioPlayer, to target: Float) -> Nil {
  let volume = glor.volume(player)
  let next_volume = float.max(volume *. 1.1, 0.01)
  case volume >. target {
    True -> Nil
    False -> {
      use <- time.wait(40)
      glor.set_volume(player, next_volume)
      ramp_up(player, to: target)
    }
  }
}
