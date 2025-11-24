import gleam/list
import gleam/option

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

pub const level_01 = Level(
  disguise_image: "green-hat",
  sentence: [
    FixedChunk("Lucy is wearing a "),
    InputChunk("green", option.None),
    FixedChunk("."),
  ],
  words: ["blue", "green", "orange", "red"],
)

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
