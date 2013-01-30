$ ->
  stateManager = window.stateManager = new window.StateManager

  # console.log(stateManager.next())
  # console.log(stateManager.next().next())
  # x = stateManager.next().next()
  # x.complete("osx")
  # console.log(x.next())
  # console.log(x.next().next())
  # console.log(x.next().next().next())

  $('#try-riak section.lesson .title').click (e)->
    $(this).siblings('.body').toggle('show')

  $('#try-riak ul.nav-tabs a').click (e)->
    e.preventDefault()
    $(this).tab('show')
  
  # Add console under tabs
  consoles = {}
  $('#try-riak .tab-content div[id^=install]').each ()->
    id = $(this).attr('id')
    # trs, name, selector, next
    consoles[id] = new window.Console(null,
      id.replace('install-', ''),
      '#'+id+' .console')

  # Add copy to console option
  $('#try-riak .tab-content .tab-pane .code').prepend('<span class=copy>Copy to Console</span>')
  $('#try-riak .tab-content .tab-pane .code .copy').live 'click', ()->
    id = $(this).parents('.tab-pane').attr('id')
    command = $(this).siblings('pre').html()
    consoles[id].insert(command)
