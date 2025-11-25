import gleam/list
import gleam/option
import lucy_in_disguise_with_diamonds/game.{type Game}
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn made_with_gleam_screen(continue: message) -> Element(message) {
  html.div([event.on_click(continue)], [
    html.h1([], [element.text("Made with Gleam!")]),
  ])
}

pub fn title_screen(continue: message) -> Element(message) {
  html.div([event.on_click(continue)], [
    html.h1([], [element.text("Lucy in Disguise with Diamonds")]),
  ])
}

pub fn intro_screen(continue: message) -> Element(message) {
  html.div([event.on_click(continue)], [
    html.h1([], [element.text("Intro text explaining the game here")]),
  ])
}

pub fn playing_screen(
  game game: Game,
  on_continue continue: message,
  on_word_selected select_word: fn(String) -> message,
  on_word_removed remove_word: fn(String) -> message,
) -> Element(message) {
  let level = game.level
  html.div([], [
    html.img([
      attribute.src("https://gleam.run/images/lucy/lucy.svg"),
      attribute.height(100),
    ]),
    html.p([], list.map(level.sentence, sentence_chunk_view(_, remove_word))),
    html.ul([], list.map(level.words, possible_word_view(_, select_word))),
    button(continue, [], [element.text("Go")]),
  ])
}

fn sentence_chunk_view(
  chunk: game.Chunk,
  remove_word: fn(String) -> message,
) -> Element(message) {
  case chunk {
    game.FixedChunk(text:) -> html.text(text)
    game.InputChunk(selection: option.None, ..) -> html.text("_____")
    game.InputChunk(selection: option.Some(word), ..) ->
      button(remove_word(word), [], [html.text(word)])
  }
}

fn button(
  clicked: message,
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Element(message) {
  html.button(
    [attribute.role("button"), event.on_click(clicked), ..attributes],
    children,
  )
}

fn possible_word_view(
  word: String,
  select_word: fn(String) -> message,
) -> Element(message) {
  html.li([], [
    button(select_word(word), [], [html.text(word)]),
  ])
}

pub fn victory_screen(continue: message) -> Element(message) {
  html.div([event.on_click(continue)], [
    html.h1([], [element.text("Victory screen")]),
  ])
}

pub fn credits_screen() -> Element(message) {
  html.div([], [
    html.h1([], [element.text("Credits screen")]),
  ])
}
