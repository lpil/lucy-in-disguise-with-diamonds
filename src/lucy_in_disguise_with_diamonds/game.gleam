import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set

pub type Game {
  Game(
    level: Level,
    next_levels: List(Level),
    selected: Option(Item),
    score: Int,
    lives: Int,
  )
}

pub type Level {
  ItemLevel(item: Item, options: List(Item))
}

pub type Item {
  Coat
  Dress
  Glasses
  Hat
  TShirt
  Tie
  Trousers
}

pub const first_level = ItemLevel(TShirt, [Hat, TShirt])

pub const levels = [
  ItemLevel(Hat, [Dress, Hat]),
  ItemLevel(Dress, [Dress, Glasses, Hat]),
  ItemLevel(Glasses, [Dress, Glasses, TShirt]),
  ItemLevel(Coat, [Coat, Tie, Dress]),
  ItemLevel(Tie, [Coat, Tie, Dress]),
]

pub fn new() -> Game {
  Game(
    level: first_level,
    next_levels: levels,
    selected: None,
    score: 0,
    lives: 3,
  )
}

pub fn select_option(game: Game, option: Item) -> Game {
  let selected = case game.selected {
    None -> Some(option)
    Some(_) -> game.selected
  }
  Game(..game, selected:)
}

pub fn deselect_option(game: Game, option: Item) -> Game {
  let selected = case game.selected {
    None -> None
    Some(existing) if option == existing -> None
    Some(_) -> game.selected
  }
  Game(..game, selected:)
}

pub fn answer_is_correct(game: Game) -> Bool {
  let Game(level:, selected:, ..) = game
  case level {
    ItemLevel(item:, ..) -> Some(item) == selected
  }
}

pub fn item_to_gaeilge(item: Item) -> String {
  case item {
    Coat -> "cóta"
    Dress -> "gúna"
    Glasses -> "spéiclí"
    Hat -> "hata"
    TShirt -> "t-léine"
    Tie -> "carbhat"
    Trousers -> "briste"
  }
}

pub fn item_to_bearla(item: Item) -> String {
  case item {
    Coat -> "coat"
    Dress -> "dress"
    Glasses -> "glasses"
    Hat -> "hat"
    TShirt -> "t-shirt"
    Tie -> "tie"
    Trousers -> "trousers"
  }
}

pub type SentenceChunk {
  Fixed(text: String)
  Input
  Selected(Item)
}

pub fn challenge_sentence(game: Game) -> List(SentenceChunk) {
  [
    Fixed("Tá "),
    case game.selected {
      None -> Input
      Some(item) -> Selected(item)
    },
    Fixed("ar Lucy."),
  ]
}

pub fn answer_sentence(level: Level, selected: Item) -> List(SentenceChunk) {
  case selected == level.item {
    True -> [
      Fixed("Tá "),
      Selected(selected),
      Fixed("ar Lucy."),
    ]
    False -> [
      Fixed("Tá "),
      Selected(level.item),
      Fixed(" uirthi, ni "),
      Selected(selected),
      Fixed("!"),
    ]
  }
}

pub fn item_image_url(item: Item) -> String {
  "/item-" <> item_to_bearla(item) <> ".svg"
}

pub fn item_fail_image_url(item: Item) -> String {
  "/fail-" <> item_to_bearla(item) <> ".svg"
}

pub fn item_success_image_url(item: Item) -> String {
  "/success-" <> item_to_bearla(item) <> ".svg"
}

pub fn all_images() -> List(String) {
  [first_level, ..levels]
  |> list.flat_map(fn(level) { level.options })
  |> list.fold(set.new(), fn(items, item) { set.insert(items, item) })
  |> set.to_list
  |> list.flat_map(fn(item) {
    [
      item_image_url(item),
      item_fail_image_url(item),
      item_success_image_url(item),
    ]
  })
}

pub fn increment_score(game: Game) -> Game {
  Game(..game, score: game.score + 1)
}

pub fn decrement_lives(game: Game) -> Game {
  Game(..game, lives: game.lives - 1)
}
