# Just unfolds a section and moves to the next lesson plan step
class Section extends window.Step
  constructor: (trs, name, el, next)->
    super(trs, name)
    @el = el
    @nextStep = next


window.Section = Section
