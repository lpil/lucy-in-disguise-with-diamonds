import gleam/list
import gleam/option.{type Option, None, Some}
import lucy_in_disguise_with_diamonds/game.{type Game}
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

pub fn gleam_logo_screen(continue: message) -> Element(message) {
  html.div([event.on_click(continue), attribute.class("logo-screen")], [
    html.img([
      attribute.alt("Gleam in the style of the classic SEGA logo"),
      attribute.src("logo.svg"),
    ]),
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
    html.p([], [element.text("Psst. This game has audio!")]),
  ])
}

pub fn intro_screen(continue: message) -> Element(message) {
  card([event.on_click(continue), attribute.class("intro")], [
    html.article([], [
      html.h1([], [
        element.text(
          "Lucy’s planning a diamond heist, but she’ll need your help to pull it off.",
        ),
      ]),
      html.p([], [
        html.text(
          "The date is set, the security system’s been hacked, and the getaway is planned. But in order to successfully hit the infamous Louvstre Museum, Lucy needs a foolproof disguise—and to not get caught in the run-up.",
        ),
      ]),
      html.p([], [
        html.text(
          "Her solution: all heist communications are conducted in Gaeilge.",
        ),
      ]),
      html.p([], [
        html.text(
          "Help Lucy by identifying her disguise, and soon she’ll be ready for the heist of the century!",
        ),
      ]),
      html.p([], [
        html.text("Be Gay. Do Crime... "),
        html.span([], [html.text("Don’t Get Caught.")]),
      ]),
      html.p([attribute.styles([#("text-align", "center")])], [
        button(continue, [], [element.text("Start the heist")]),
      ]),
    ]),
  ])
}

pub fn challenge_screen(
  game game: Game,
  on_continue continue: message,
  on_option_selected select: fn(game.Item) -> message,
  on_option_removed remove: fn(game.Item) -> message,
) -> Element(message) {
  let #(continue, select) = case game.selected {
    None -> #(None, Some(select))
    Some(_) -> #(Some(continue), None)
  }
  level_screen(
    game,
    continue_text: "Check answer",
    on_continue: continue,
    on_option_selected: select,
    on_option_removed: Some(remove),
    images: [
      "https://gleam.run/images/lucy/lucy.svg",
      game.item_image_url(game.level.item),
    ],
  )
}

pub fn answer_screen(
  game game: Game,
  selected selected: game.Item,
  on_continue continue: message,
) -> Element(message) {
  let image = case game.level.item == selected {
    True -> game.item_success_image_url(selected)
    False -> game.item_fail_image_url(selected)
  }
  level_screen(
    game,
    continue_text: "Next level",
    on_continue: Some(continue),
    on_option_selected: None,
    on_option_removed: None,
    images: [
      image,
    ],
  )
}

fn level_screen(
  game game: Game,
  continue_text continue_text: String,
  on_continue continue: Option(message),
  on_option_selected select_option: Option(fn(game.Item) -> message),
  on_option_removed remove_word: Option(fn(game.Item) -> message),
  images images: List(String),
) -> Element(message) {
  let level = game.level
  card([attribute.class("game")], [
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
      list.map(game.level_sentence(game), sentence_chunk_view(_, remove_word)),
    ),
    html.ul([], list.map(level.options, possible_word_view(_, select_option))),
    case continue {
      Some(continue) -> button(continue, [], [element.text(continue_text)])
      None -> disabled_button([], [element.text(continue_text)])
    },
  ])
}

fn card(
  attributes: List(Attribute(a)),
  children: List(Element(a)),
) -> Element(a) {
  html.div([attribute.class("card-background")], [
    html.main([attribute.class("card"), ..attributes], children),
  ])
}

fn sentence_chunk_view(
  chunk: game.SentenceChunk,
  remove: Option(fn(game.Item) -> message),
) -> Element(message) {
  case chunk {
    game.Fixed(text:) ->
      html.span([attribute.class("fixed-chunk")], [element.text(text)])

    game.Input -> html.span([attribute.class("word-placeholder")], [])

    game.Selected(item) -> {
      let attrs = [attribute.class("word-selected")]
      let text = html.text(game.item_to_gaeilge(item))
      case remove {
        None -> disabled_button(attrs, [text])
        Some(remove) -> button(remove(item), attrs, [text])
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
  option: game.Item,
  select_option: Option(fn(game.Item) -> message),
) -> Element(message) {
  let word = game.item_to_gaeilge(option)
  let button = case select_option {
    None -> disabled_button([], [html.text(word)])
    Some(select_option) -> button(select_option(option), [], [html.text(word)])
  }
  html.li([], [button])
}

pub fn victory_screen(continue: message) -> Element(message) {
  html.div([event.on_click(continue)], [
    html.h1([], [element.text("Victory screen")]),
  ])
}

pub fn credits_screen() -> Element(message) {
  html.div([attribute.class("credits-background")], [
    html.div([attribute.class("credits")], [
      html.h1([], [element.text("Lucy in Disguise with Diamonds")]),

      html.h2([], [element.text("Cast")]),
      credits_section([
        #("Lucy", ["Herself"]),
      ]),

      html.h2([], [element.text("Production")]),
      credits_section([
        #("Graphics", ["Hap Fiala"]),
        #("Programming", ["Louis Pilfold"]),
        #("Purring", ["Nubi"]),
      ]),

      html.h2([], [element.text("Resources")]),
      credits_section([
        #("Lustre framework", ["Hayleigh Thompson", "Yoshie Reusch"]),
        #("Gleam language", ["The Gleam core team", "The Gleam contributors"]),
        #("Outfit font", ["Smartsheet Inc", "Rodrigo Fuenzalida"]),
        #("Voice acting", ["Kara via Fourthwoods on Freesound"]),
      ]),

      html.p([attribute.class("disclaimer")], [
        html.text(
          "The characters and events depicted in this game are fictitious. "
          <> "Any similarity to actual persons, living or dead, is purely "
          <> "coincidental.",
        ),
        html.br([]),
        html.text("Lucy has never even been to Paris."),
      ]),
    ]),
  ])
}

fn credits_section(credits: List(#(String, List(String)))) -> Element(message) {
  element.fragment(
    list.map(credits, fn(credit) {
      html.div([attribute.class("credit")], [
        html.div([attribute.class("credit-role")], [html.text(credit.0)]),
        html.ul(
          [],
          list.map(credit.1, fn(name) { html.li([], [element.text(name)]) }),
        ),
      ])
    }),
  )
}
