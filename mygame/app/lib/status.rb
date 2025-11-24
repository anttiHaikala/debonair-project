# temporal effect applied to an entity
class Status  
  attr_accessor :kind # a symbol
  attr_accessor :entity # Entity class object
  attr_accessor :created_at # world time!
  attr_accessor :duration # in world time units, nil means permanent
  
  def initialize(entity, kind, duration=nil, args)
    @kind = kind
    @duration = duration
    @entity = entity
    @created_at = args.state.kronos.world_time
    @entity.add_status(self)
  end
end