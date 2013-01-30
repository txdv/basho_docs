# A base-class representing a single step in a lesson plan
class Step
  constructor: (trs, name)->
    @trs = trs
    @name = name

  # extract to a helper... don't like this feature envy
  buildStep: (ary)=>
    @trs.buildStep(ary)
    # throw "I need some data here... comeon!!" unless ary?
    # args = ary.splice(1)
    # Kind = ary[0]
    # new Kind(@, args...)

  complete: ()=>
    true

  next: ()=>
    @buildStep(@nextStep)
    # throw "Implement me, please"


window.Step = Step
