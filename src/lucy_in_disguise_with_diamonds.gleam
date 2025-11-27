import lucy_in_disguise_with_diamonds/game.{type Game, Game}
import lucy_in_disguise_with_diamonds/ui
import lustre
import lustre/effect.{type Effect}
import lustre/element.{type Element}

pub type State {
  MadeWithGleamScreen
  TitleScreen
  IntroScreen
  PlayingScreen(game: Game)
  VictoryScreen
  CreditsScreen
}

pub type Message {
  ContinuePressed
  WordSelected(word: String)
  WordRemoved(word: String)
}

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

fn update(state: State, message: Message) -> #(State, Effect(Message)) {
  case state {
    // These stages move on to the next one when the player does any
    // interaction
    MadeWithGleamScreen -> pure(TitleScreen)
    TitleScreen -> pure(IntroScreen)
    IntroScreen -> pure(PlayingScreen(game.new()))
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
      case game.answer_is_correct(game.level) {
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
      let game = Game(..game, level: game.select_word(game.level, word))
      pure(PlayingScreen(game))
    }

    WordRemoved(word:) -> {
      let game = Game(..game, level: game.remove_word(game.level, word))
      pure(PlayingScreen(game))
    }
  }
}

fn pure(value: value) -> #(value, Effect(message)) {
  #(value, effect.none())
}

fn view(state: State) -> Element(Message) {
  case state {
    MadeWithGleamScreen -> ui.made_with_gleam_screen(ContinuePressed)
    TitleScreen -> ui.title_screen(ContinuePressed)
    IntroScreen -> ui.intro_screen(ContinuePressed)
    PlayingScreen(game:) ->
      ui.playing_screen(
        game:,
        on_continue: ContinuePressed,
        on_word_selected: WordSelected,
        on_word_removed: WordRemoved,
      )
    VictoryScreen -> ui.victory_screen(ContinuePressed)
    CreditsScreen -> ui.credits_screen()
  }
}

fn init(_: anything) -> #(State, Effect(Message)) {
  // #(MadeWithGleamScreen, effect.none())
  // #(TitleScreen, effect.none())
  #(PlayingScreen(game.new()), effect.none())
}
