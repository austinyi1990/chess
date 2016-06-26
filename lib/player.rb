class Player
	def initialize(name, game_board)
    	@name = name
    	@game_board = game_board
    	#player's king?
    	@king = nil
    end
    attr_reader :name, :king
    attr_accessor :color, :unicode
    
    #could refactor the inputs
    def mark_position
    	@game_board.print_board
		printf "Make your move: "
		input = gets.chomp
		from = input[0..1]
		to = input[2..3]

		until input.length == 4 && @game_board.update_board(from, to, @color)
			puts "#{input} is either not a valid input or unavailable. Please try again."
			printf "Make your move: "
			input = gets.chomp
			from = input[0..1]
			to = input[2..3]
		end
    end

    #have it so that the player has a reference to his king
    def set_king
        @king = @game_board.get_king(@color)
    end
end