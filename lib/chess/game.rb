require_relative "game_board"
require_relative "player"

class Game
	def initialize
		@game_board = GameBoard.new
		@player1 = Player.new("Player 1", @game_board)
		@player2 = Player.new("Player 2", @game_board)
		@players = [@player1, @player2]
		@current_player = @player1
		@other_player = @player2
		main_menu
	end

	def main_menu
		puts "Welcome to Chess"
	    answer = ""
    	while answer != 2
			printf "Main Menu\n1) New Game 2) Quit "
			answer = gets.chomp.to_i
			case answer
				when 1 then play
				when 2 then puts "Thanks for playing!"
				else
					puts "Sorry, I don't know how to #{answer}"
			end
		end
	end

	def play
		get_player_order
		get_player_color
		loop do
			if threatening_pieces = @current_player.king.in_check?(@game_board.board)
				if @current_player.king.in_checkmate?(threatening_pieces, @game_board.board)
					puts "\nCheckmate! #{@current_player.name} loses!"
					@game_board.print_board
					replay
					return
				else
					puts "\n#{@current_player.name} is in check!"
				end
			end
			puts "\n#{@current_player.name}'s turn #{@current_player.unicode}"
			@current_player.mark_position
			switch_player
		end
	end

	def get_player_order
		printf "Would you like to randomize the order? (y/n): "
		answer = gets.chomp.downcase
		until (answer == "y" || answer == "n")
			puts "Invalid input. Please try again."
			answer = gets.chomp.downcase
		end

		if answer == "y"
			@current_player = @players.sample
			@other_player = @players.find {|other_player| other_player.name != @current_player.name}
		end
		puts "#{@current_player.name} goes first"
	end

	def get_player_color
		printf "#{@other_player.name} gets dibs on choosing color. Which color would you like to use (W/B)? :"
		answer = gets.chomp.downcase
		until (answer == "w" || answer == "b")
			puts "Invalid input. Please try again."
			answer = gets.chomp.downcase
		end

		if answer == "w"
			@other_player.color, @other_player.unicode = "white", "\u26AA"
			@current_player.color, @current_player.unicode = "black", "\u26AB"
		else
			@other_player.color, @other_player.unicode = "black", "\u26AB"
			@current_player.color, @current_player.unicode = "white", "\u26AA"
		end
		puts "#{@other_player.name} selects #{@other_player.color} #{@other_player.unicode}"
		
		@current_player.set_king
		@other_player.set_king
	end

	def switch_player
		@current_player, @other_player = @other_player, @current_player
	end

	def replay
		printf "Would you like to play again? (y/n)"
		answer = gets.chomp.downcase
		until (answer == "y" || answer == "n")
			printf "Invalid input. Please try again."
			answer = gets.chomp.downcase
		end
		if answer == "y"
			reset_game
			self.play
		end
	end

	def reset_game
		@game_board.reset_board
		switch_player if @current_player != @player1
	end
end

game = Game.new