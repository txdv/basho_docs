# Represents the entire lesson plan state machine
Section = window.Section
Console = window.Console
Choice  = window.Choice

class StateManager

  # skipTo: ()=>

  # TODO should track the current state
  next: ()=>
    step = @buildStep(@states())
    @setCurrentStep(step)
    step

  setCurrentStep: (step)=>
    @currentStep = step

  buildStep: (obj)=>
    throw "I need some data here... comeon!!" unless obj?
    new obj.kind(@, obj.opts...)

  # TODO build these in a more readable way
  states: ()=>
    return @__states if @__states
    cluster   = {kind: Section, opts: ['cluster', '#make-cluster', null]}
    configure = {kind: Section, opts: ['configure', '#configuring-node', cluster]}
    consoleChoice = {kind: Choice, opts: ['choose-install-os',
      {kind: Console, name: 'debian', opts: ['debian', '#install-debian .console', configure]},
      {kind: Console, name: 'osx', opts: ['osx', '#install-osx .console', configure]},
      {kind: Console, name: 'rhel', opts: ['rhel', '#install-rhel .console', configure]}
    ]}
    @__states = {kind: Section, opts: ['install', '#installing-riak', consoleChoice]}
    @__states

window.StateManager = StateManager
