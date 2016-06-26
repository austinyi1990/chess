require_relative "pawn"
require_relative "rook"
require_relative "knight"
require_relative "bishop"
require_relative "king"
require_relative "queen"

class GameBoard
	def initialize
    	@board = set_board
        set_king_reference
    end
    attr_reader :board
    attr_accessor :black_king, :white_king

    def set_board
		Array.new(8).each_index.map do |row|
			Array.new(8).each_index.map do |col|
                set_start_piece(row, col)
			end
		end
    end

    def set_start_piece(row, col)
        color = "white" if row == 7 || row == 6
        color = "black" if row == 0 || row == 1
        return Pawn.new(color, row, col) if row == 1 || row == 6

        if (row == 0 || row == 7)
            case col
                when 3 then return set_king(color, row, col)
                when 0, 7 then return Rook.new(color, row, col)
                when 1, 6 then return Knight.new(color, row, col)
                when 2, 5 then return Bishop.new(color, row, col)
                when 4 then return Queen.new(color, row, col)
                else
                    return nil
            end
        end
    end

    # starts returning false if you run validmove twice
    def update_board(from, to, color)
        reset_pawn_movement(color)
        from_row, from_col = convert_to_indexes(from)
        to_row, to_col = convert_to_indexes(to)

        #fails because it doesn't do a check for start. cant call it on piece because if a piece doesn't exist, you can't do a check
        if !board[from_row][from_col].nil? && @board[from_row][from_col].valid_move?(to_row, to_col, @board, color)
            @board[from_row][from_col].decide_move(to_row, to_col, @board, nil)
            return true
        else
            return false
        end
    end

    def get_pieces(color)
        pieces = []
        @board.each {|row| row.each {|square| pieces << square if square.is_a?(Piece) && square.color == color}}
        return pieces
    end

    def convert_to_indexes(input)
        row_index = input[0].ord - 97
        col_index = input[1].to_i - 1
        return row_index, col_index
    end

    def set_king(color, row, col)
        king = King.new(color, row, col)
        color == "white" ? @white_king = king : @black_king = king
        return king
    end

    def get_king(color)
        return color == "white" ? @white_king : @black_king
    end

    def print_board
        col_divider = " | "
        row_headers = ('A'..'H').to_a
        col_headers = (1..8).to_a

        rows = @board.each.map do |row|
            new_row = row.each.map do |square|
                square.nil? ? " " : square.unicode
            end
            "#{row_headers.shift} | #{new_row.join(col_divider)} |"
        end

        puts "    #{col_headers.join("   ")}"
        puts rows
    end

    def reset_board
        @board = set_board
        set_king_reference
    end

    def set_king_reference
        @board.each do |row|
            row.each do |square|
                if square.is_a?(Piece)
                    square.king = get_king(square.color)
                end
            end
        end
    end

    def reset_pawn_movement(color)
        @board.each do |row|
            row.each do |square|
                if square.is_a?(Pawn) && square.color == color
                    square.double_moved = false
                end
            end
        end
    end
end