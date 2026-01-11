class Debug
  
  def self.press_l(args)
    if $debug
      # debug info you need right now
      printf "Dijkstra test from hero position %d,%d to exit staircase %d,%d\n" % [args.state.hero.x, args.state.hero.y,args.state.dungeon.levels[args.state.hero.depth].staircase_down_x, args.state.dungeon.levels[args.state.hero.depth].staircase_down_y]
      path = Utils.dijkstra(args.state.hero, args.state.hero.x, args.state.hero.y, args.state.dungeon.levels[args.state.hero.depth].staircase_down_x, args.state.dungeon.levels[args.state.hero.depth].staircase_down_y, args.state.dungeon.levels[args.state.hero.depth], args) 
      printf "Dijkstra path length: %d\n" % [path.size]
      HUD.output_message(args, "Dijkstra path to staircase down length: %d" % [path.size])
    end
  end
end