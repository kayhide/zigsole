class Command
  @onCommit: null
  @commands: []

  constructor: ->
    Command.commands = []

  commit: ->
    @execute()
    Command.commands.push(this)
    if Command.onCommit?
      Command.onCommit(this)


@Command = Command
