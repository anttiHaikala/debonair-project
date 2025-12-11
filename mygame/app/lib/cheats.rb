class Cheats
#  1 species, 2 role, 3 age, 4 scroll, 5 wand, 6 potion, 7 ring, 8 food, 9 tool, 10 weapon, 11 armor, 12 item
  def self.handle_input(args)
    hero = args.state.hero
    return unless hero
    if args.inputs.keyboard.key_down.one
      hero.species = Hero.species[(Hero.species.index(hero.species) + 1) % Hero.species.size]
      HUD.output_message(args, "Cheat: Changed species to #{hero.species}.")
    elsif args.inputs.keyboard.key_down.two
      hero.role = Hero.roles[(Hero.roles.index(hero.role) + 1) % Hero.roles.size]
      HUD.output_message(args, "Cheat: Changed role to #{hero.role}.")
    elsif args.inputs.keyboard.key_down.three
      hero.age = Hero.age[(Hero.age.index(hero.age) + 1) % Hero.age.size]
      HUD.output_message(args, "Cheat: Changed age to #{hero.age}.")
    elsif args.inputs.keyboard.key_down.four
      scroll = Scroll.randomize(hero.depth, args)
      hero.carried_items << scroll
      HUD.output_message(args, "Cheat: Added scroll of #{scroll.kind} to inventory.")
    elsif args.inputs.keyboard.key_down.five
      wand = Wand.randomize(hero.depth, args)
      hero.carried_items << wand
      HUD.output_message(args, "Cheat: Added wand of #{wand.kind} to inventory.")
    elsif args.inputs.keyboard.key_down.six
      potion = Potion.randomize(hero.depth, args)
      hero.carried_items << potion
      HUD.output_message(args, "Cheat: Added potion of #{potion.kind} to inventory.")
    elsif args.inputs.keyboard.key_down.seven
      ring = Ring.randomize(hero.depth, args)
      hero.carried_items << ring
      HUD.output_message(args, "Cheat: Added ring of #{ring.kind} to inventory.")
    elsif args.inputs.keyboard.key_down.zero
      weapon = Weapon.randomize(hero.depth, args)
      hero.carried_items << weapon
      HUD.output_message(args, "Cheat: Added weapon of #{weapon.kind} to inventory.")
    end
  end
end
