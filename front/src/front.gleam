import gleam/io
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html as h
import lustre/ui.{button, field, input}

pub type Model {
  Model
}

pub type Msg

pub fn reg() {
  h.form([], [
    h.text("kek"),
    button([attribute.type_("submit")], [element.text("Register")]),
  ])
}

pub fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(Msg)) {
  #(Model, effect.none())
}

fn init(_flags) -> #(Model, effect.Effect(Msg)) {
  #(Model, effect.none())
}

pub fn view(model: Model) -> element.Element(Msg) {
  h.div([], [
    h.label([attribute.for("name")], [element.text("name!")]),
    ui.input([attribute.type_("text"), attribute.id("name")]),
    reg(),
  ])
}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}
