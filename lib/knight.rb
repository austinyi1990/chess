require_relative "piece"

class Knight < Piece
	def initialize(color, row, col)
		super(color, row, col)
		@color == "white" ? @unicode = "\u2658" : @unicode = "\u265E"
	end
	#Validates that move does not put king ion check
	def valid_move?(to_row, to_col, board, color)
		return false if super == false
		return 	legal_move?(to_row, to_col, board) &&
				move_not_in_check?(@row, @col, to_row, to_col, board)
	end 

    #Piece specific movements
    def legal_move?(to_row, to_col, board)
    	return (to_col - @col).abs == 2 && (to_row - @row).abs == 1 || (to_col - @col).abs == 1 && (to_row - @row).abs == 2
    end
end