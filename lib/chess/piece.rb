class Piece
	def initialize(color, row, col)
		@color = color
		@row = row
		@col = col
	end
	#added reader for row and col for testing
	attr_reader :color, :row, :col
	attr_accessor :unicode, :king

	def valid_move?(to_row, to_col, board, color)
		return 	start_valid?(@row, @col, board, color) && dest_valid?(@row, @col, to_row, to_col, board, color)
	end

	#Overrided in king and pawn for special cases
	def decide_move(to_row, to_col, board, from_value)
		move_to(to_row, to_col, board, from_value)
	end

	def move_to(to_row, to_col, board, from_value)
		dest_value = get_captured(to_row, to_col, board)
		board[to_row][to_col] = board[@row][@col]
		board[@row][@col] = from_value
 		@row = to_row
 		@col = to_col
 		return dest_value
	end

	#Overrided in pawn for en passant
	def get_captured(to_row, to_col, board)
		return board[to_row][to_col]
	end

	def vertical_clear?(to_row, to_col, board)
		row_offset = to_row > @row ? 1 : -1
		increment(row_offset, 0, to_row, to_col, board)
	end

	def horizontal_clear?(to_row, to_col, board)
		col_offset = to_col > @col ? 1 : -1
		increment(0, col_offset, to_row, to_col, board)
	end

	def diagonal_clear?(to_row, to_col, board)
		row_offset = to_row > @row ? 1 : -1
		col_offset = to_col > @col ? 1 : -1
		increment(row_offset, col_offset, to_row, to_col, board)
	end
	
	def on_diagonal?(to_row, to_col)
		row_slope = (to_row - @row).abs
		col_slope = (to_col - @col).abs
		return row_slope == col_slope
	end

	def increment(row_offset, col_offset, to_row, to_col, board)
	    in_between = []
	    current_row, current_col = @row, @col

	    until current_row == to_row - row_offset && current_col == to_col - col_offset
	        current_row += row_offset
			current_col += col_offset
	        return false unless board[current_row][current_col].nil?
	        in_between << [current_row, current_col]
	    end
	    return in_between
	end

	###New functions###
	def start_valid?(row, col, board, color)
        return on_the_board?(row, col) && own_piece?(row, col, board, color)
    end

    def dest_valid?(from_row, from_col, to_row, to_col, board, color)
        return on_the_board?(to_row, to_col) && !own_piece?(to_row, to_col, board, color)
    end

    def on_the_board?(row, col)
        return (0..7).include?(row) && (0..7).include?(col)
    end

    def own_piece?(row, col, board, color)
        return !square_empty?(row, col, board) ? same_color?(row, col, board, color) : false
    end

    def square_empty?(row, col, board)
        return board[row][col].nil?
    end

    def same_color?(row, col, board, color)
        return color == board[row][col].color
    end
    ###End New Functions####

    #Overrided in Rook, Bishop, and Queen
    def get_in_between(row, col, board)
    	return false
    end

    #maybe just create a separate the content for the current implementation of move_to into another method so I can call it directly in move_not_in_check?
    #from values are probably there to prevent the first move from overwriting
    #added for refactoring. want to try and lessen the amount of code under King
    def move_not_in_check?(from_row, from_col, to_row, to_col, board)
		dest_value = move_to(to_row, to_col, board, nil)
        if @king.in_check?(board)
            move_to(from_row, from_col, board, dest_value)
            return false
        else
            move_to(from_row, from_col, board, dest_value)
            return true
        end
    end
end