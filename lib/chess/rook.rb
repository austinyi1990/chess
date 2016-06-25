require_relative "piece"

class Rook < Piece
	def initialize(color, row, col)
		super(color, row, col)
		@color == "white" ? @unicode = "\u2656" : @unicode = "\u265C"
		@moved = false
	end
	attr_accessor :moved
	#is @moved being set for the rook?
	
	#Override to allow movement update
	def decide_move(to_row, to_col, board, from_value)
		@moved = true
		super
	end

	#Validates that move does not put king ion check
	def valid_move?(to_row, to_col, board, color)
		return false if super == false
		return 	legal_move?(to_row, to_col, board) && move_not_in_check?(@row, @col, to_row, to_col, board)
	end

    #Piece specific movements
    def legal_move?(to_row, to_col, board)
    	return to_row == @row && horizontal_clear?(to_row, to_col, board) || to_col == @col && vertical_clear?(to_row, to_col, board)
    end

	def get_in_between(row, col, board)
		return horizontal_clear?(row, col, board) || vertical_clear?(row, col, board)
	end 
end