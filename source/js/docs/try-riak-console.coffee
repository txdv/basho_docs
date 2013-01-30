class Console extends window.Step
  promptLabel: '$ '
  welcomeMessage: null
  # constructor: (selector, os)->
  constructor: (trs, name, selector, next)->
    super(trs, name)
    @$el = $(selector)
    @el = @$el[0]
    @setup()
    @install = new ConsoleInstall(@name)
    @nextStep = next

  setup: ()->
    @console = @$el.console
      animateScroll:   true
      promptHistory:   true
      autofocus:       true
      promptLabel:     @promptLabel
      welcomeMessage:  @welcomeMessage
      commandValidate: @commandValidate
      commandHandle:   @commandHandle
      cancelHandle:    @cancelHandle
    @console.cancelOutput = null

  insert: (line)=>
    @console.typer.consoleInsert(line)

  commandValidate: (line)=>
    console.log('commandValidate')
    return line != ''

  commandHandle: (line, report, customPrompt)=>
    console.log('commandHandle')
    @console.cancelOutput = false

    if line == "clear"
      @console.reset()
    else
      response = "-bash: #{line}: command not found"
      @continuedPrompt = false
      resp = []
      for respLine in @install.read(line)
        if $.isArray(respLine)
          newline = respLine[2] == false
          pause = respLine[1] || 0
          resp.push {msg: respLine[0], className:'jquery-install-message', pause: pause, newline: newline}
        if respLine.complete?
          resp.push {msg: respLine.complete, className:'jquery-install-message', complete:@lessonComplete}
      report(resp)
    []

  # TODO: this should be built into TryRiakState
  lessonComplete: (message)->
    alert(message)

  # when ^C is pressed
  cancelHandle: (e)=>
    console.log('cancelHandle')
    @console.cancelOutput = true
    false


window.Console = Console
