class Command
  @onCommit: []
  @onPost: []
  @onReject: []
  @commands: []
  @current_commands: []

  @commit: ->
    cmds = @squash()
    @commands.concat(cmds)
    fnc(cmds) for fnc in @onCommit
    cmds

  @post: (cmd) ->
    if cmd.isValid()
      cmd.execute()
      @current_commands.push(cmd)
      fnc(cmd) for fnc in @onPost
    else
      cmd.rejected = true
      fnc(cmd) for fnc in @onReject
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
