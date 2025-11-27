import gleam/list
import gleam/option.{None}

pub type Game {
  Game(level: Level, next_levels: List(Level))
}

pub type Level {
  Level(
    /// URL to the image.
    disguise_image: String,
    /// The sentence that the player has to complete.
    sentence: List(Chunk),
    /// The words that the player can use to complete the sentence.
    words: List(String),
  )
}

pub type Chunk {
  /// Some fixed text that is shown to the player and they cannot change.
  FixedChunk(text: String)
  /// A gap in the sentence that the player has to fill.
  InputChunk(correct: String, selection: option.Option(String))
}

pub const first_level = Level(
  "t-shirt",
  [
    FixedChunk("Tá "),
    InputChunk("t-léine", None),
    FixedChunk(" ar Lucy."),
  ],
  ["hata", "t-léine"],
)

// t-léine
// gúna
// briste
// carbhat
// hata
// spéiclí

pub const levels = [
  Level(
    "hat",
    [
      FixedChunk("Tá "),
      InputChunk("hata", None),
      FixedChunk(" uirthi."),
    ],
    ["gúna", "hata", "t-léine"],
  ),
  Level(
    "dress",
    [
      FixedChunk("Tá "),
      InputChunk("gúna", None),
      FixedChunk(" uirthi."),
    ],
    ["gúna", "hata", "t-léine"],
  ),
  // Level(
//   "glasses",
//   [
//     InputChunk("Tá", None),
//     FixedChunk(" t-léine uirthi."),
//   ],
//   ["Is", "Tá"],
// ),
// Level(
//   "scarf",
//   [
//     InputChunk("Tá", None),
//     FixedChunk(" t-léine uirthi."),
//   ],
//   ["Is", "Tá"],
// ),
// // Level(
// //   "bag",
// //   [
// //     InputChunk("Tá", None),
// //     FixedChunk(" t-léine uirthi."),
// //   ],
// //   ["Is", "Tá"],
// // ),
// Level(
//   "trousers",
//   [
//     InputChunk("Tá", None),
//     FixedChunk(" t-léine uirthi."),
//   ],
//   ["Is", "Tá"],
// ),
// Level(
//   "wig",
//   [
//     InputChunk("Tá", None),
//     FixedChunk(" t-léine uirthi."),
//   ],
//   ["Is", "Tá"],
// ),
// Level(
//   "coat",
//   [
//     InputChunk("Tá", None),
//     FixedChunk(" t-léine uirthi."),
//   ],
//   ["Is", "Tá"],
// ),
// Level(
//   "tie",
//   [
//     InputChunk("Tá", None),
//     FixedChunk(" t-léine uirthi."),
//   ],
//   ["Is", "Tá"],
// ),
]

pub fn new() -> Game {
  Game(level: first_level, next_levels: levels)
}

pub fn select_word(level: Level, word: String) -> Level {
  let sentence =
    list.map_fold(level.sentence, False, fn(has_replaced, chunk) {
      case chunk {
        InputChunk(selection: option.None, correct:) if !has_replaced -> {
          let chunk = InputChunk(selection: option.Some(word), correct:)
          #(True, chunk)
        }

        _ -> #(has_replaced, chunk)
      }
    }).1
  Level(..level, sentence:)
}

pub fn remove_word(level: Level, word: String) -> Level {
  let sentence =
    list.map_fold(level.sentence, False, fn(has_replaced, chunk) {
      case chunk {
        InputChunk(selection: option.Some(selection), correct:)
          if word == selection && !has_replaced
        -> {
          let chunk = InputChunk(selection: option.None, correct:)
          #(True, chunk)
        }

        _ -> #(has_replaced, chunk)
      }
    }).1
  Level(..level, sentence:)
}

pub fn answer_is_correct(level: Level) -> Bool {
  list.all(level.sentence, fn(chunk) {
    case chunk {
      FixedChunk(..) -> True
      InputChunk(correct:, selection:) -> selection == option.Some(correct)
    }
  })
}
