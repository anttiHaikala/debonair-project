require 'app/lib/architect'
require 'app/lib/dungeon'
require 'app/lib/level'
require 'app/lib/GUI'
require 'app/lib/tile'
require 'app/lib/entity'
require 'app/lib/hero'
require 'app/lib/color_conversion'
require 'app/lib/leaves'
require 'app/lib/sound_fx'
require 'app/lib/utils'

def boot args
  args.state = {}
  Architect.instance.setup({})
  Architect.instance.architect_dungeon(args)
  args.state.current_level = 0
  printf "Boot complete.\n"
  printf "Dungeon has %d levels.\n" % args.state.dungeon.levels.size
  printf "Dungeon has %d entities.\n" % args.state.entities.size
end

def reset args
end

def tick args
  args.state.scene ||= :gameplay
  case args.state.scene
  when :gameplay
    gameplay_tick args
  when :staircase
    staircase_tick args
  end
end

def gameplay_tick args
  GUI.handle_input args
  GUI.draw_background args
  GUI.draw_tiles args
  GUI.update_entity_animations args
  GUI.draw_entities args
  GUI.draw_hud args
end

def staircase_tick args
  GUI.draw_background args
  GUI.draw_tiles args
  GUI.draw_entities args
  GUI.staircase_animation args
  GUI.draw_hud args
end