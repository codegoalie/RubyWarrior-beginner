class Player
  NEEDS_REST = 5
  WELL_RESTED = 20

  def play_turn(warrior)
    @warrior = warrior
    @health ||= warrior.health
    @resting ||= false
    @rescued ||= 0
    @just_pivoted ||= false

    
    if should_turn_around
      puts "better behind me"
      warrior.pivot!
      return
    end

    if @resting && warrior.health > @health
      if warrior.health < WELL_RESTED
        warrior.rest!
        return
      else
        @resting = false
      end
    end

    if warrior.feel.wall?
      warrior.pivot!
      return
    end

    if warrior.health < NEEDS_REST  # need to red
      if @health > warrior.health # in range of enemy  
        warrior.walk!(:backward)
      else #safe
        @resting = true
        warrior.rest!
      end
    elsif warrior.feel.captive?
      warrior.rescue!
    elsif warrior.feel.empty?
      warrior.walk!
    else
      attack!      
    end
    @health = warrior.health
  end

  def should_turn_around
    front = @warrior.look
    back  = @warrior.look(:backward)

    front_score = score(front[0].to_s) *3
    front_score += score(front[1].to_s) *2
    front_score += score(front[2].to_s) *1

    back_score = score(back[0].to_s) *3
    back_score += score(back[1].to_s) *2
    back_score += score(back[2].to_s) *1

    puts "Front: #{front_score}"
    puts "Back:  #{back_score}"
    front_score < back_score
  end

  def score(ent)
    case ent
    when 'Captive'
      6
    when 'Wizard'
      6
    when 'Archer'
      5
    when /Sludge/
      6
    when 'Stairs'
      0
    when 'nothing'
      0
    when 'wall'
      0
    else
      0
    end
  end
  
  def attack!
    @last_enemy = what_i_can_see
    if @warrior.feel.empty?
      @warrior.shoot!
    else
      @warrior.attack!
    end
  end

  def what_i_can_see
    if @warrior.feel.empty?
      # look and see what I see
      warrior.look.each do |s|
        next if s.empty?
        return s.character
      end
      return nil
    else
      @warrior.feel.character
    end
  end
end
