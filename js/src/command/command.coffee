class Command
  @onCommit: null
  @onPost: null
  @onReject: null
  @commands: []
  @current_commands: []

  @commit: ->
    cmds = @squash()
    @commands.concat(cmds)
    @onCommit?(cmds)
    cmds

  @post: (cmd) ->
    if cmd.isValid()
      cmd.execute()
      @current_commands.push(cmd)
      @onPost?(cmd)
    else
      cmd.rejected = true
      @onReject?(cmd)
    cmd
    
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
    this

  squash: (cmd) ->
    false

  isTransformCommand: ->
    false

  isValid: ->
    true

@Command = Command
