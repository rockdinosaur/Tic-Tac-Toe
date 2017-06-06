require 'pry'

INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
GO_FIRST = 'player'

WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                [[1, 5, 9], [3, 5, 7]]              # diagonals

# Methods ----------------------------------------------------------------------
def prompt(message)
  puts "=> #{message}"
end

def joinor(arr, separator = ", ", conjunction = "or")
  str = ''
  arr.each_with_index do |num, index|
    str += "#{num}#{separator}" if index < (arr.length - 1)
    str += "#{conjunction} #{num}" if index == arr.length - 1
  end
  str
end

def display_board(brd, player_score, computer_score)
  system 'clear'
  puts "First to win 5 matches wins!"
  puts "You're '#{PLAYER_MARKER}'. Computer is '#{COMPUTER_MARKER}'"
  puts "Your score: #{player_score} Computer score: #{computer_score}"
  puts ""
  puts "     |     |"
  puts "  #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}"
  puts "     |     |"
  puts ""
end

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

def player_places_piece!(brd)
  square = ''
  loop do
    prompt "Choose a square #{joinor(empty_squares(brd))}:"
    square = gets.chomp.to_i
    break if empty_squares(brd).include?(square)
    prompt "Sorry, that's not a valid square."
  end
  brd[square] = PLAYER_MARKER
end

def computer_places_piece!(brd)
  if brd[5] == INITIAL_MARKER
    brd[5] = COMPUTER_MARKER
  else
    square = empty_squares(brd).sample
    brd[square] = COMPUTER_MARKER
  end
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def someone_won?(brd)
  !!detect_winner(brd)
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    if brd.values_at(*line).count(PLAYER_MARKER) == 3
      # *line is the equivalent of line[0], line[1], line[2]... etc
      return 'Player'
    elsif brd.values_at(*line).count(COMPUTER_MARKER) == 3
      return 'Computer'
    end
  end
  nil
end

def detect_threat_line(brd)
  WINNING_LINES.each do |line|
    if brd.values_at(*line).count(COMPUTER_MARKER) == 2 && brd.values_at(*line).count(INITIAL_MARKER) == 1
      return line
    end
  end

  # 2 #each iterations because we want offense to take priority

  WINNING_LINES.each do |line|
    if brd.values_at(*line).count(PLAYER_MARKER) == 2 &&
       brd.values_at(*line).count(INITIAL_MARKER) == 1
      return line
    end
  end
  nil
end

def defend_attack!(brd)
  brd.values_at(*detect_threat_line(brd)).each_with_index do |marker, index|
    if marker == INITIAL_MARKER
      brd[detect_threat_line(brd)[index]] = COMPUTER_MARKER
    end
  end
end

def alternate_player(current_player)
  if current_player == 'computer'
    'player'
  else
    'computer'
  end
end

def place_piece!(board, current_player)
  if current_player == 'player'
    player_places_piece!(board)
  else
    if detect_threat_line(board)
      defend_attack!(board)
    else
      computer_places_piece!(board)
    end
  end
end

# End of Methods ---------------------------------------------------------------

# Beginning of MAIN
choices = ['player', 'computer']
choice = ''

loop do
  if GO_FIRST == "choose"
    prompt "If you want to go first, enter: 'player', otherwise enter: 'computer':"
    choice = gets.chomp.downcase
    break if choices.any? { |choices| choices == choice }
    prompt "That's not a valid choice."
  else
    break
  end
end

loop do
  player_score = 0
  computer_score = 0
  loop do
    board = initialize_board

    if choice == choices[0] || GO_FIRST == choices[0]
      current_player = choices[0]
    elsif choice == choices[1] || GO_FIRST == choices[1]
      current_player = choices[1]
    end

    loop do
      display_board(board, player_score, computer_score)
      place_piece!(board, current_player)
      current_player = alternate_player(current_player)

      if someone_won?(board)
        player_score += 1 if detect_winner(board) == choices[0].capitalize
        computer_score += 1 if detect_winner(board) == choices[1].capitalize
      end

      break if someone_won?(board) || board_full?(board)
    end

    if player_score >= 5
      prompt "You won 5 games!!!"
      break
    elsif computer_score >= 5
      prompt "Computer won 5 games!!!"
      break
    end
  end
  prompt("Would you like to play again? y/n")
  play_again = gets.chomp
  break unless play_again.downcase.start_with?('y')
end

prompt("Thanks for playing!")
