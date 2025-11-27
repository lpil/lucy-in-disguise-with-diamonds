import gleam/list
import gleam/option.{type Option, None, Some}
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
  html.div([attribute.class("title-screen")], [
    html.h1([], [element.text("Lucy in Disguise with Diamonds")]),
    html.img([
      attribute.class("undisguised-lucy"),
      attribute.src("https://gleam.run/images/lucy/lucy.svg"),
    ]),
    button(continue, [], [element.text("Play")]),
  ])
}

pub fn intro_screen(continue: message) -> Element(message) {
  html.main([event.on_click(continue)], [
    html.h1([], [element.text("Intro text explaining the game here")]),
  ])
}

pub fn challenge_screen(
  game game: Game,
  on_continue continue: message,
  on_word_selected select_word: fn(String) -> message,
  on_word_removed remove_word: fn(String) -> message,
) -> Element(message) {
  level_screen(
    game,
    continue_text: "Check answer",
    on_continue: continue,
    on_word_selected: Some(select_word),
    on_word_removed: Some(remove_word),
    images: [
      "https://gleam.run/images/lucy/lucy.svg",
      "https://gleam.run/images/lucy/lucy.svg",
    ],
  )
}

pub fn answer_screen(
  game game: Game,
  on_continue continue: message,
) -> Element(message) {
  level_screen(
    game,
    continue_text: "Next level",
    on_continue: continue,
    on_word_selected: None,
    on_word_removed: None,
    images: [
      "https://gleam.run/images/lucy/lucy.svg",
    ],
  )
}

fn level_screen(
  game game: Game,
  continue_text continue_text: String,
  on_continue continue: message,
  on_word_selected select_word: Option(fn(String) -> message),
  on_word_removed remove_word: Option(fn(String) -> message),
  images images: List(String),
) -> Element(message) {
  let level = game.level
  html.div([attribute.class("game-background")], [
    html.main([attribute.class("game")], [
      html.div([attribute.class("status")], [
        html.div([attribute.class("hearts")], [
          html.img([attribute.src("https://gleam.run/images/lucy/lucy.svg")]),
          html.img([attribute.src("https://gleam.run/images/lucy/lucy.svg")]),
          html.img([attribute.src("https://gleam.run/images/lucy/lucy.svg")]),
        ]),
        html.div([attribute.class("diamonds")], [
          element.text("0"),
          html.img([attribute.src("https://gleam.run/images/lucy/lucy.svg")]),
        ]),
      ]),
      html.div(
        [attribute.class("images")],
        list.map(images, fn(image) { html.img([attribute.src(image)]) }),
      ),
      html.p(
        [attribute.class("sentence")],
        list.map(level.sentence, sentence_chunk_view(_, remove_word)),
      ),
      html.ul([], list.map(level.words, possible_word_view(_, select_word))),
      button(continue, [], [element.text(continue_text)]),
    ]),
  ])
}

fn sentence_chunk_view(
  chunk: game.Chunk,
  remove_word: Option(fn(String) -> message),
) -> Element(message) {
  case chunk {
    game.FixedChunk(text:) ->
      html.span([attribute.class("fixed-chunk")], [element.text(text)])

    game.InputChunk(selection: None, ..) ->
      html.span([attribute.class("word-placeholder")], [])

    game.InputChunk(selection: Some(word), ..) -> {
      let attrs = [attribute.class("word-selected")]
      let text = html.text(word)
      case remove_word {
        None -> disabled_button(attrs, [text])
        Some(remove_word) -> button(remove_word(word), attrs, [text])
      }
    }
  }
}

fn disabled_button(
  attributes: List(Attribute(message)),
  children: List(Element(message)),
) -> Element(message) {
  html.button(
    [attribute.role("button"), attribute.disabled(True), ..attributes],
    children,
  )
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
  select_word: Option(fn(String) -> message),
) -> Element(message) {
  let button = case select_word {
    None -> disabled_button([], [html.text(word)])
    Some(select_word) -> button(select_word(word), [], [html.text(word)])
  }
  html.li([], [button])
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
