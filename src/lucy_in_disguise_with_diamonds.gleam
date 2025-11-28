import gleam/option
import lucy_in_disguise_with_diamonds/audio
import lucy_in_disguise_with_diamonds/game.{type Game, Game}
import lucy_in_disguise_with_diamonds/time
import lucy_in_disguise_with_diamonds/ui
import lustre
import lustre/effect.{type Effect}
import lustre/element.{type Element}

pub type State {
  TitleScreen
  GleamLogoScreen
  IntroScreen
  ChallengeScreen(game: Game)
  AnswerScreen(game: Game, selected: game.Item)
  VictoryScreen
  CreditsScreen
}

pub type Message {
  ContinuePressed
  ScoreIncrementSignalled
  WordSelected(game.Item)
  WordRemoved(game.Item)
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
    IntroScreen -> pure(ChallengeScreen(game.new()))
    VictoryScreen -> pure(CreditsScreen)
    CreditsScreen -> pure(state)

    GleamLogoScreen -> #(IntroScreen, audio.play_music())

    TitleScreen -> {
      let effects =
        effect.batch([
          time.later(2000, ContinuePressed),
        ])
      #(GleamLogoScreen, effects)
    }

    ChallengeScreen(game:) -> update_challenge_screen(game, message)
    AnswerScreen(game:, selected:) ->
      update_answer_screen(game, selected, message)
  }
}

fn update_answer_screen(
  game: Game,
  selected: game.Item,
  message: Message,
) -> #(State, Effect(a)) {
  case message {
    WordRemoved(..) | WordSelected(..) -> pure(AnswerScreen(game, selected))

    ScoreIncrementSignalled -> #(
      AnswerScreen(game.increment_score(game), selected),
      effect.none(),
    )

    ContinuePressed ->
      case game.next_levels {
        [] -> pure(VictoryScreen)
        [level, ..next_levels] -> {
          let game = Game(..game, level:, next_levels:, selected: option.None)
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
    ScoreIncrementSignalled -> #(
      ChallengeScreen(game.increment_score(game)),
      effect.none(),
    )

    ContinuePressed ->
      case game.selected {
        option.Some(selected) if selected == game.level.item -> {
          let effect =
            effect.batch([
              audio.play_success(),
              stepped_dispatch(10, ScoreIncrementSignalled),
            ])
          #(AnswerScreen(game, selected), effect)
        }
        option.Some(selected) -> {
          let game = game.decrement_lives(game)
          #(AnswerScreen(game, selected), effect.none())
        }
        option.None -> pure(ChallengeScreen(game))
      }

    WordSelected(option) -> {
      let game = game.select_option(game, option)
      pure(ChallengeScreen(game))
    }

    WordRemoved(option) -> {
      let game = game.deselect_option(game, option)
      pure(ChallengeScreen(game))
    }
  }
}

fn stepped_dispatch(amount: Int, message: Message) -> Effect(Message) {
  use dispatch <- effect.from
  use <- stepped(amount)
  dispatch(message)
}

fn stepped(amount: Int, run: fn() -> anything) -> Nil {
  case amount > 0 {
    False -> Nil
    True -> {
      use <- time.wait(100)
      run()
      stepped(amount - 1, run)
    }
  }
}

fn pure(value: value) -> #(value, Effect(message)) {
  #(value, effect.none())
}

fn view(state: State) -> Element(Message) {
  case state {
    GleamLogoScreen -> ui.gleam_logo_screen(ContinuePressed)
    TitleScreen -> ui.title_screen(ContinuePressed)
    IntroScreen -> ui.intro_screen(ContinuePressed)
    ChallengeScreen(game:) ->
      ui.challenge_screen(
        game:,
        on_continue: ContinuePressed,
        on_option_selected: WordSelected,
        on_option_removed: WordRemoved,
      )
    AnswerScreen(game:, selected:) ->
      ui.answer_screen(game:, selected:, on_continue: ContinuePressed)

    VictoryScreen -> ui.victory_screen(ContinuePressed)
    CreditsScreen -> ui.credits_screen()
  }
}

fn init(_: anything) -> #(State, Effect(Message)) {
  #(TitleScreen, effect.none())
  // #(ChallengeScreen(game.new()), effect.none())
  // #(CreditsScreen, effect.none())
}
