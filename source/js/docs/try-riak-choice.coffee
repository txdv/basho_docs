# when one of multiple choices are made,
# walk down that step
class Choice extends window.Step
  constructor: (trs, name, choices...)->
    super(trs, name)
    @choices = choices

  # each choice is a step. you cannot go to the next one until it has been completed
  complete: (which)=>
    @nextStep = null
    for choice in @choices
      @nextStep = choice if choice.name == which


window.Choice = Choice
