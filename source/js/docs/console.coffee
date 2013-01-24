class Console
  promptLabel: '$ '
  welcomeMessage: null #'export BASE=http://tryriak.org/riak/'
  constructor: (selector)->
    @$el = $(selector)
    @el = @$el[0]
    @setup()

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

  commandValidate: (line)=>
    console.log('commandValidate')
    return line != ''

  commandHandle: (line, report, customPrompt)=>
    console.log('commandHandle')

    if line == "clear"
      @console.reset()
    else
      response = "-bash: #{line}: command not found"
      report([{msg: response, className:'jquery-console-message-value'}])
    []
    # $.ajax '/message.json',
    #   headers: {'Accept': 'application/json'}
    #   data: { message: line }
    #   success: (data, textStatus, jqXHR) ->
    #     report([{msg: data.message, className:'jquery-console-message-value'}])

  # when ^C is pressed
  cancelHandle: (e)=>
    console.log('cancelHandle')
    false


window.Console = Console