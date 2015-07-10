# Gems
require "colorize"

# Global variables
$board = Hash.new(0)
$user_type = 1
$computer_type = 2
$winPos = []

# Methods
def place_square(position)
  if $board[position] == 0
    $board[position] = $computer_type
    return true
  end
  return false
end

# Lines:
# * -1 = No line
# * 1 = vertical a
# * 2 = vertical b
# * 3 = vertical c
# * 4 = horizontal a
# * 5 = horizontal b
# * 6 = horizontal c
# * 7 = from a1-c3
# * 8 = from a3-c1

$ai = {
  :target_line => -1 # the line the AI wants to do. See above comment for options
}

def two_of_three_unchk(stmt1, stmt2, stmt3)
  return (stmt1 && stmt2) || (stmt2 && stmt3) || (stmt1 && stmt3)
end

def two_of_three(stmt1, stmt1chk, stmt2, stmt2chk, stmt3, stmt3chk)
  return (stmt1 && stmt2 && stmt3chk) || (stmt2 && stmt3 && stmt1chk) || (stmt1 && stmt3 && stmt2chk)
end

def two_of_three_pos(pos1, pos2, pos3, type)
  return two_of_three($board[pos1] == type, $board[pos1] == 0, $board[pos2] == type, $board[pos2] == 0, $board[pos3] == type, $board[pos3] == 0)
end

def get_target_line(type)
  target = -1
  
  if two_of_three_pos([0, 0], [0, 1], [0, 2], type) # vertical a
    target = 1
  elsif two_of_three_pos([1, 0], [1, 1], [1, 2], type) # vertical b
    target = 2
  elsif two_of_three_pos([2, 0], [2, 1], [2, 2], type) # vertical c
    target = 3
  elsif two_of_three_pos([0, 0], [1, 0], [2, 0], type) # horizontal a
    target = 4
  elsif two_of_three_pos([0, 1], [1, 1], [2, 1], type) # horizontal b
    target = 5
  elsif two_of_three_pos([0, 2], [1, 2], [2, 2], type) # horizontal c
    target = 6
  elsif two_of_three_pos([0, 0], [1, 1], [2, 2], type) # from a1-c3
    target = 7
  elsif two_of_three_pos([0, 2], [1, 1], [2, 0], type) # from c3-a1
    target = 8
  end
  
  return target
end

def get_target_positions(target)
  case target
    when 1
      return [[0, 0], [0, 1], [0, 2]]
    when 2
      return [[1, 0], [1, 1], [1, 2]]
    when 3
      return [[2, 0], [2, 1], [2, 2]]
    when 4
      return [[0, 0], [1, 0], [2, 0]]
    when 5
      return [[0, 1], [1, 1], [2, 1]]
    when 6
      return [[0, 2], [1, 2], [2, 2]]
    when 7
      return [[0, 0], [1, 1], [2, 2]]
    when 8
      return [[0, 2], [1, 1], [2, 0]]
  else
    return []
  end
end

def try_place_line(target, type)
  positions = get_target_positions(target)
  if place_square(positions[0]) || place_square(positions[1]) || place_square(positions[2])
    return true
  end
  return false
end

def would_win_in_one_if_placed(target, type)
  positions = get_target_positions(target)
  if two_of_three_unchk($board[positions[0]] == type, $board[positions[1]] == type, $board[positions[2]] == type)
    return true
  end
  return false
end

def do_move()
  # corner checks
  # if not blocked, these allow for creating forks quickly in the beginning of the game.
  if $board[[0, 0]] == $user_type
    if place_square([2, 2])
      return true
    end
  end
  if $board[[2, 0]] == $user_type
    if place_square([0, 2])
      return true
    end
  end
  if $board[[2, 2]] == $user_type
    if place_square([0, 0])
      return true
    end
  end
  if $board[[0, 2]] == $user_type
    if place_square([2, 0])
      return true
    end
  end
  
  if place_square([1, 1]) # get the center
    return true
  end
  $ai[:target_line] = get_target_line($computer_type)
  user_target = get_target_line($user_type)
  
  if $ai[:target_line] > -1 and would_win_in_one_if_placed($ai[:target_line], $computer_type)
    if try_place_line($ai[:target_line], $computer_type)
      return true
    end
  end
  
  # SPECIAL CASES
  # These routines check for certain strategies and blocks them.
  # TODO: generalize these
  if $board[[1, 1]] == $user_type and $board[[2, 2]] == $user_type and $board[[0, 0]] == $computer_type
    if place_square([0, 2])
      return true
    end
  end
  if $board[[1, 2]] == $user_type and $board[[2, 0]] == $user_type
    if place_square([2, 2])
      return true
    end
  end
  if $board[[1, 2]] == $user_type and $board[[0, 2]] == $user_type
    if place_square([2, 2])
      return true
    end
  end
  if $board[[0, 0]] == $user_type and $board[[2, 1]] == $user_type
    if place_square([2, 0])
      return true
    end
  end
  
  if user_target > -1
    if try_place_line(user_target, $computer_type)
      return true
    end
  end
  if $ai[:target_line] > -1
    if try_place_line(user_target, $computer_type)
      return true
    end
  end
  
  # CORNER CHECKING
  # This does some checks to make sure the player can't exploit the one weakness in the AI (so far):
  # The top-left and bottom-right corner
  
  if $board[[1, 0]] == $user_type and $board[[0, 1]] == $user_type and $board[[0, 0]] == 0
    # trying the top-left corner?
    if place_square([0, 0])
      return true # NOPE
    end
  end
  if $board[[1, 2]] == $user_type and $board[[2, 1]] == $user_type and $board[[2, 2]] == 0
    # trying the bottom-right corner?
    if place_square([2, 2])
      return true # NOPE
    end
  end
  
  # Still here? try every line
  try_line = 1
  while true do
    # loop over every line
    if try_line > 8
      break # that failed
    end
    if try_place_line(try_line, $computer_type)
      return true # it worked
    end
    try_line += 1
  end
  
  return false # no spaces left. Since neither has won, it must be a tie.
end

def check_horiz_line(y, type)
  return ($board[[0, y]] == type) && ($board[[1, y]] == type) && ($board[[2, y]] == type)
end

def check_vert_line(x, type)
  return ($board[[x, 0]] == type) && ($board[[x, 1]] == type) && ($board[[x, 2]] == type)
end

def get_win_position(type)
  if check_vert_line(0, type)
    return get_target_positions(1)
  elsif check_vert_line(1, type)
    return get_target_positions(2)   
  elsif check_vert_line(2, type)
    return get_target_positions(3)  
  elsif check_horiz_line(0, type)
    return get_target_positions(4)   
  elsif check_horiz_line(1, type)
    return get_target_positions(5)   
  elsif check_horiz_line(2, type) 
    return get_target_positions(6)    
  elsif ($board[[0, 0]] == type) && ($board[[1, 1]] == type) && ($board[[2, 2]] == type)
    return get_target_positions(7)    
  elsif ($board[[0, 2]] == type) && ($board[[1, 1]] == type) && ($board[[2, 0]] == type)
    return get_target_positions(8)    
  else
    return []
  end
end

def check_win(type)
  # This should be made cleaner at some point
  if get_win_position(type).length > 0
    return true
  else
    return false
  end
end

def draw_tile(x, y, winning_type=-1)
  tile = $board[[x, y]]
  tileIcon = " "
  case tile
    when 0
      tileIcon = " "
    when 1
      tileIcon = "X"
    when 2
      tileIcon = "O"
  end
  if $winPos.include?([x, y])
    tileIcon = tileIcon.bold
    if winning_type == $user_type
      tileIcon = tileIcon.green
    else
      tileIcon = tileIcon.red
    end
  end
  print tileIcon
end

def draw_row(y, winning_type=-1)
  print "| "
  draw_tile(0, y, winning_type)
  print " | "
  draw_tile(1, y, winning_type)
  print " | "
  draw_tile(2, y, winning_type)
  puts " |"
end

def draw_board(winning_type=-1)
  puts "+-----------+" #.colorize(:color => :white, :background => :light_black)
  draw_row(0, winning_type)
  puts "|-----------|"
  draw_row(1, winning_type)
  puts "|-----------|"
  draw_row(2, winning_type)
  puts "+-----------+"
end

def get_position_from_response(response)
  position = response.upcase
  
  pos_x = 0
  pos_y = 0
  
  # Data validation
  if not position.length == 2
    return false
  end
  case position[0]
    when "A"
      pos_x = 0
    when "B"
      pos_x = 1 
    when "C"
      pos_x = 2    
  else
    return false # invalid reponse
  end
  case position[1]
    when "1"
      pos_y = 0
    when "2"
      pos_y = 1 
    when "3"
      pos_y = 2    
  else
    return false # invalid response
  end
  
  return [pos_x, pos_y]
end

def main()
  # reset variables
  $board = Hash.new(0)
  $winPos = []
  running = true
  
  while running
    probably_tie = false
    
    draw_board()
    print "Select a position (or type 'quit' to quit): "
    response = gets.chomp
    if not response == "quit"
      position = get_position_from_response(response)
      if not position == false
        if $board[position] == 0
          $board[position] = $user_type
          if not do_move()
            # It's a tie! Maybe.
            probably_tie = true
          end
        else
          puts "Position already taken!".red
        end
      else
        puts "Invalid position!".red
      end
    else
      running = false
      return
    end
    
    if check_win($user_type)
      $winPos = get_win_position($user_type)
      draw_board($user_type)
      puts "Congratulations! You win!".green
      running = false
    elsif check_win($computer_type)
      $winPos = get_win_position($computer_type)
      draw_board($computer_type)
      puts "You lost!".red
      running = false
    elsif probably_tie
      draw_board()
      puts "It's a tie!".yellow
      running = false
    end
  end
  
  ask_again = true
  while ask_again
    print "Do you want to play again? (yes/no) "
    again = gets.chomp.downcase
    case again[0]
      when "y"
        main()
        ask_again = false
      when "n"
        ask_again = false
    else
      ask_again = true
    end
  end
end

# Run
main()