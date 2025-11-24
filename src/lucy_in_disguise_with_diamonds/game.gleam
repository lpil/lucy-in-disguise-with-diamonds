import gleam/list
import gleam/option
import lustre
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html

pub type State {
  MadeWithGleamScreen
  TitleScreen
  IntroScreen
  PlayingScreen(game: Game)
  VictoryScreen
  CreditsScreen
}

pub type Game {
  Game(level: Level, next_levels: List(Level))
}

pub type Message {
  ContinuePressed
  WordSelected(word: String)
  WordRemoved(word: String)
}

fn update(state: State, message: Message) -> #(State, Effect(Message)) {
  case state {
    // These stages move on to the next one when the player does any
    // interaction
    MadeWithGleamScreen -> pure(TitleScreen)
    TitleScreen -> pure(IntroScreen)
    IntroScreen -> pure(PlayingScreen(Game(level: level_01, next_levels: [])))
    VictoryScreen -> pure(CreditsScreen)
    CreditsScreen -> pure(state)

    PlayingScreen(game:) -> update_playing_level(game, message)
  }
}

fn update_playing_level(
  game: Game,
  message: Message,
) -> #(State, Effect(Message)) {
  case message {
    ContinuePressed ->
      case answer_is_correct(game.level) {
        True ->
          case game.next_levels {
            [] -> pure(VictoryScreen)
            [level, ..next_levels] -> {
              let game = Game(level:, next_levels:)
              pure(PlayingScreen(game))
            }
          }
        // TODO: indicate to the user that the answer is incorrect
        False -> pure(PlayingScreen(game))
      }

    WordSelected(word:) -> {
      let game = Game(..game, level: select_word(game.level, word))
      pure(PlayingScreen(game))
    }

    WordRemoved(word:) -> {
      let game = Game(..game, level: remove_word(game.level, word))
      pure(PlayingScreen(game))
    }
  }
}

fn pure(value: value) -> #(value, Effect(message)) {
  #(value, effect.none())
}

pub fn application() -> lustre.App(a, State, Message) {
  lustre.application(init, update, view)
}

fn view(state: State) -> Element(Message) {
  html.h1([], [html.text("Hello, Joe!")])
}

fn init(_: anything) -> #(State, Effect(Message)) {
  #(MadeWithGleamScreen, effect.none())
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
