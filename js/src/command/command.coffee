class Command
  @onCommit: null
  @onPost: null
  @commands: []
  @current_commands: []

  @commit: ->
    cmds = @squash()
    @commands.concat(cmds)
    @onCommit?(cmds)
    return

  @post: (cmd) ->
    cmd.execute()
    @current_commands.push(cmd)
    @onPost?(cmd)
    return
    
  @squash: ->
    cmds = []
    last = null
    while cmd = @current_commands.shift()
      unless last?.squash(cmd)
        last = cmd
        cmds.push(cmd)
    cmds
  
  post: ->
    Command.post(this)

  commit: ->
    Command.post(this)
    Command.commit()

  squash: (cmd) ->
    false

  isTransformCommand: ->
    false

@Command = Command
