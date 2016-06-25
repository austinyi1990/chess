require_relative "piece"

class King < Piece
	def initialize(color, row, col)
		super(color, row, col)
		@color == "white" ? @unicode = "\u2654" : @unicode = "\u265A"
        @moved = false
	end
    attr_accessor :moved

    #Validates that move does not put king in check
    #to_row and to_col does not need to be in check for castling
    #need to check valid_move for king
	def valid_move?(to_row, to_col, board, color)
        return false if super == false
        return legal_move?(to_row, to_col, board) && move_not_in_check?(@row, @col, to_row, to_col, board)
	end

    #Override to allow castling and movement update
    def decide_move(to_row, to_col, board, from_value)
        @moved = true
        valid_castling_move?(to_row, to_col, board) ? castle_to(to_row, to_col, board) : super
    end

    #piece specific movements
    def legal_move?(to_row, to_col, board)
        return (to_row - @row).abs <= 1 && (to_col - @col).abs <= 1 || valid_castling_move?(to_row, to_col, board)
    end

    #might be calling incheck multiple times because validmove is called incheck
	def in_check?(board)
		enemy_color = @color == "white" ? "black" : "white"
		enemy_pieces = get_pieces(enemy_color, board)        

        threatening_pieces = enemy_pieces.find_all {|enemy| enemy.legal_move?(@row, @col, board)}

        threatening_pieces.each do |piece|
            puts "Enemy: #{piece.class.name} [#{piece.row},#{piece.col}]"
        end

        threatening_pieces.empty? ? false : threatening_pieces
	end

	def in_checkmate?(threatening_pieces, board)
		friendly_pieces = get_pieces(@color, board)
        puts "__in_checkmate__"
        puts "Can the king move out?: #{move_out_valid?(board)}"
        puts "Can you capture the threat?: #{can_capture_threat?(friendly_pieces, threatening_pieces, board)}"
        puts "Can you block the threat?: #{can_block_threat?(friendly_pieces, threatening_pieces, board)}"
		return  !move_out_valid?(board) &&
                !can_capture_threat?(friendly_pieces, threatening_pieces, board) &&
                !can_block_threat?(friendly_pieces, threatening_pieces, board)
	end

 	def get_pieces(color, board)
        pieces = []
        board.each {|row| row.each {|square| pieces << square if square.is_a?(Piece) && square.color == color}}
        return pieces
    end

    # maybe do a .any?
    def move_out_valid?(board)
        offsets = [[1,0],[0,1],[-1,0],[0,-1],[1,1],[-1,1],[-1,-1],[1,-1]]
    	offsets.each do |offset|
            to_row, to_col = @row + offset[0], @col + offset[1]

            if valid_move?(to_row, to_col, board, @color)
                puts "King can move out at: [#{to_row},#{to_col}]"
                return true
            end
    	end
    	return false
    end

    
    #for all the of the checks, need to consider if the king is still in check
    def can_capture_threat?(friendly_pieces, threatening_pieces, board)
        return false if threatening_pieces == false || threatening_pieces.length > 1
        enemy_row = threatening_pieces.first.row
        enemy_col = threatening_pieces.first.col

        friendly_pieces.each do |friend|
            if friend.legal_move?(enemy_row, enemy_col, board)
                puts "#{friend.class.name} can capture at: [#{enemy_row},#{enemy_col}]"
                return true
            end
        end
        return false
    end

    #can only block if its from a rook, queen, or bishop and requires at least 1 square in between
    #king is registering as being able to block
    def can_block_threat?(friendly_pieces, threatening_pieces, board)
        return false if threatening_pieces == false || threatening_pieces.length > 1
        enemy_piece = threatening_pieces.first
        enemy_row = enemy_piece.row
        enemy_col = enemy_piece.col

        if in_between = enemy_piece.get_in_between(@row, @col, board)
            puts "__inside can_block_threat__"
            p in_between

            friendly_pieces.each do |friend|
                in_between.each do |square|
                    to_row, to_col = square[0], square[1]
                    if friend.valid_move?(to_row, to_col, board, @color)
                        puts "#{friend.class.name} can block at: [#{to_row},#{to_col}]"
                        return true
                    end
                end
            end
        end
        return false
    end

    def dest_valid?(from_row, from_col, to_row, to_col, board, color)
        valid_castling_move?(to_row, to_col, board) ? true : super
    end

    def valid_castling_move?(to_row, to_col, board)
        col_offset = to_col > @col ? 1 : -1

        if on_the_board?(to_row, to_col) && own_piece?(to_row, to_col, board, @color) && board[to_row][to_col].is_a?(Rook)
            if board[to_row][to_col].moved == false && @moved == false && !in_check?(board)
                if in_between = board[to_row][to_col].get_in_between(@row, @col, board)
                    return move_not_in_check?(@row, @col, to_row, to_col + col_offset, board) && move_not_in_check?(@row, @col, to_row, to_col + 2*col_offset, board)
                end
            end
        end
        return false
    end

    def castle_to(to_row, to_col, board)
        col_offset = to_col > @col ? 1 : -1
        @moved = true
        move_to(@row, @col + 2*col_offset, board, nil)
        board[to_row][to_col].moved = true
        board[to_row][to_col].move_to(to_row, @col - col_offset, board, nil)
    end
end

