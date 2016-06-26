require_relative "piece"

class Pawn < Piece
	def initialize(color, row, col)
		super(color, row, col)
		@color == "white" ? @unicode = "\u2659" : @unicode = "\u265F"
		@direction = @color == "white" ? -1 : 1
		@last_row = @color == "white" ? 0 : 7
		@moved = false
		@double_moved = false
	end
	attr_accessor :moved, :double_moved

	#Validates that move does not put king in check
	def valid_move?(to_row, to_col, board, color)
		return false if super == false
		return legal_move?(to_row, to_col, board) && move_not_in_check?(@row, @col, to_row, to_col, board)
	end 

	#Override to allow promotion and movement updates
	def decide_move(to_row, to_col, board, from_value)
		@moved = true
		@double_moved = true if is_double_move?(to_row)
		to_row == @last_row ? promote(to_row, to_col, board) : super
	end

    #Piece specific movements
    def legal_move?(to_row, to_col, board)
		return 	move_ahead_valid?(to_row, to_col, board) || 
				capture_diag_valid?(to_row, to_col, board) ||
				en_passant_capture_valid?(to_row, to_col, board)
    end

	def get_captured(to_row, to_col, board)
		if en_passant_capture_valid?(to_row, to_col, board)
			dest_value = board[@row][to_col]
			board[@row][to_col] = nil
		else
			dest_value = board[to_row][to_col]
		end
		return dest_value
	end

	#because incheck checks for valid move, this might be accidentely updating properties for the pawn
	#moved and double_moved needs to be set after the move is actually made
	#@double_moved needs to be set to false after the its the players turn again
	def move_ahead_valid?(to_row, to_col, board)
		if to_col == @col && vertical_clear?(to_row, to_col, board) && square_empty?(to_row, to_col, board)
			return true if (is_double_move?(to_row) && @moved == false) || is_single_move?(to_row)
		end
		return false
	end

	def capture_diag_valid?(to_row, to_col, board)
		return (to_row - @row) == @direction && (to_col - @col).abs == 1 if !board[to_row][to_col].nil?
	end

	#might need to check this one to make sure that it doesn't capture my own pieces
	def en_passant_capture_valid?(to_row, to_col, board)
		if (to_row - @row) == @direction && (to_col - @col).abs == 1 && board[to_row - @direction][to_col].is_a?(Pawn)
			return board[to_row - @direction][to_col].double_moved == true
		end
		return false
	end
	
	#if the pawn is promoted to a rook, make sure that moved is set to true
	def promote(to_row, to_col, board)
        promoted_piece = nil
        input = ""
        until ['q','r','b','k'].include?(input)
        	printf "Promote your Pawn (Q)ueen (R)ook (B)ishop (K)night: "
        	input = gets.chomp
        	case input
        		when 'q' then promoted_piece = Queen.new(@color, row, col)
                when 'r' then promoted_piece = Rook.new(@color, row, col)
                when 'b' then promoted_piece = Bishop.new(@color, row, col)
                when 'k' then promoted_piece = Knight.new(@color, row, col)
                else
                	puts "#{input} is not a valid input. Please try again."
        	end
        end
        promoted_piece.king = @king
        board[@row][@col] = promoted_piece
        promoted_piece.move_to(to_row, to_col, board, nil)
	end

	#check this method
	def is_double_move?(to_row)
		return to_row - @row == 2 * @direction
	end

	def is_single_move?(to_row)
		return to_row - @row == @direction
	end
end