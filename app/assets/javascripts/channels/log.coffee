App.log = App.cable.subscriptions.create "LogChannel",
  connected: ->
    console.log("We're connected!")
    # Called when the subscription is ready for use on the server

  disconnected: ->
    console.log("We're disconnected!")
    # Called when the subscription has been terminated by the server

  received: (data) ->
    console.log(data)
    $('.update-modal-message').text data.message
    $('.update-modal').modal()

    # Called when there's incoming data on the websocket for this channel
