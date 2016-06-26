require_relative "piece"

class Bishop < Piece
	def initialize(color, row, col)
		super(color, row, col)
		@color == "white" ? @unicode = "\u2657" : @unicode = "\u265D"
	end
	
	#Validates that move does not put king ion check	
	def valid_move?(to_row, to_col, board, color)
		return false if super == false
		return legal_move?(to_row, to_col, board) && move_not_in_check?(@row, @col, to_row, to_col, board)
	end 

    #Piece specific movements
    def legal_move?(to_row, to_col, board)
    	return on_diagonal?(to_row, to_col) && diagonal_clear?(to_row, to_col, board)
    end

	def get_in_between(row, col, board)
		return diagonal_clear?(row, col, board)
	end 
end