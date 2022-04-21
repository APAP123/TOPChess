# spec/game_spec.rb
require './lib/game'
require './lib/piece'
require './lib/parser'

describe Chess do
  describe '#stalemate?' do
    context 'When Black King cannot make a move without putting himself in check' do
      it 'returns true' do
        board = [
          [nil, nil, nil, nil, nil, nil, nil, King.new(-1)],
          [nil, nil, nil, nil, nil, King.new(1), nil, nil],
          [nil, nil, nil, nil, nil, nil, Queen.new(1), nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]

        stalemate_game = Chess.new(board, -1)
        result = stalemate_game.stalemate?
        expect(result).to be true
      end
    end

    context 'When Black King can make a move without putting himself in check' do
      it 'returns false' do
        board = [
          [nil, nil, nil, nil, nil, nil, nil, King.new(-1)],
          [nil, nil, nil, nil, King.new(1), nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, Queen.new(1), nil]
        ]

        non_stalemated_game = Chess.new(board, -1)
        result = non_stalemated_game.stalemate?
        expect(result).to be false
      end
    end
  end

  describe '#check?' do
    context 'When Black King is is in check' do
      it 'returns true' do
        board = [
          [nil, nil, nil, nil, nil, nil, nil, King.new(-1)],
          [nil, nil, nil, nil, nil, nil, Pawn.new(1), nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, King.new(1), nil]
        ]

        black_check_game = Chess.new(board, -1)
        result = black_check_game.check?
        expect(result).to be true
      end
    end

    context 'When White King is in check' do
      it 'returns true' do
        board = [
          [nil, nil, nil, nil, nil, nil, nil, King.new(-1)],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, Rook.new(-1), nil],
          [nil, nil, nil, nil, nil, nil, King.new(1), nil]
        ]

        white_check_game = Chess.new(board, 1)
        result = white_check_game.check?
        expect(result).to be true
      end
    end

    context 'When White King is not in check' do
      it 'returns false' do
        board = [
          [nil, nil, nil, nil, nil, nil, nil, King.new(-1)],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, Pawn.new(1), nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, King.new(1), nil]
        ]

        no_check_game = Chess.new(board, -1)
        result = no_check_game.check?
        expect(result).to be false
      end
    end
  end
end
