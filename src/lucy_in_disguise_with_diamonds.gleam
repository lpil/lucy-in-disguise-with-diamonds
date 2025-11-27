import lucy_in_disguise_with_diamonds/game.{type Game, Game}
import lucy_in_disguise_with_diamonds/ui
import lustre
import lustre/effect.{type Effect}
import lustre/element.{type Element}

pub type State {
  MadeWithGleamScreen
  TitleScreen
  IntroScreen
  ChallengeScreen(game: Game)
  AnswerScreen(game: Game)
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
    IntroScreen -> pure(ChallengeScreen(game.new()))
    VictoryScreen -> pure(CreditsScreen)
    CreditsScreen -> pure(state)

    ChallengeScreen(game:) -> update_challenge_screen(game, message)
    AnswerScreen(game:) -> update_answer_screen(game, message)
  }
}

fn update_answer_screen(game: Game, message: Message) -> #(State, Effect(a)) {
  case message {
    WordRemoved(..) | WordSelected(..) -> pure(AnswerScreen(game))

    ContinuePressed ->
      case game.next_levels {
        [] -> pure(VictoryScreen)
        [level, ..next_levels] -> {
          let game = Game(level:, next_levels:)
          pure(ChallengeScreen(game))
        }
      }
  }
}

fn update_challenge_screen(
  game: Game,
  message: Message,
) -> #(State, Effect(Message)) {
  case message {
    ContinuePressed -> pure(AnswerScreen(game))

    WordSelected(word:) -> {
      let game = Game(..game, level: game.select_word(game.level, word))
      pure(ChallengeScreen(game))
    }

    WordRemoved(word:) -> {
      let game = Game(..game, level: game.remove_word(game.level, word))
      pure(ChallengeScreen(game))
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
    ChallengeScreen(game:) ->
      ui.challenge_screen(
        game:,
        on_continue: ContinuePressed,
        on_word_selected: WordSelected,
        on_word_removed: WordRemoved,
      )
    AnswerScreen(game:) -> ui.answer_screen(game:, on_continue: ContinuePressed)

    VictoryScreen -> ui.victory_screen(ContinuePressed)
    CreditsScreen -> ui.credits_screen()
  }
}

fn init(_: anything) -> #(State, Effect(Message)) {
  #(MadeWithGleamScreen, effect.none())
  // #(TitleScreen, effect.none())
  // #(ChallengeScreen(game.new()), effect.none())
}
