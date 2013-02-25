class Node
  attr_accessor :row, :column, :fixed, :value, :possible_values, :square
  def initialize(row, col, is_fixed, value, *possible_values)
    self.row = row
    self.column = col
    self.fixed = is_fixed
    self.value = value
    self.possible_values = possible_values if possible_values
    puts "(#{self.row},#{self.column}): #{self.value}"
  end

  def check_value(board, value)
    puts "checking #{value}"
    return !(get_conflicts(board).include? value)
  end

  def get_conflicts(board)
    conflicts = []
    conflicts += self.get_row(board)
    conflicts += self.get_column(board)
    conflicts += self.get_square(board)
    puts conflicts.inspect
    conflicts.collect! {|node| node.value}
    conflicts.delete(nil)
    conflicts.uniq!
    puts conflicts.inspect
    return conflicts
  end

  def update_possible(board)
    puts "getting possibilities.."
    bad = get_conflicts(board)
    puts bad.inspect
    list = [1,2,3,4,5,6,7,8,9]
    list.delete_if{|num| bad.include? num}
    puts list.inspect
    self.possible_values = list
  end

  def get_square(board)
    left = 3*(self.column/3)
    top = 3*(self.row/3)
    ret = board[top].slice(left, 3)
    ret += board[top+1].slice(left, 3)
    ret += board[top+2].slice(left, 3)
    return ret
  end
  def get_row(board)
    return board[self.row]
  end
  def get_column(board)
    list = []
    board.each do |row|
      list << row[self.column]
    end
    return list
  end
end

#this is the method from question 2, which allows us to read in the puzzle
def make_sudoku_puzzle(file)
  board = Array.new(9) {Array.new(9)}
  f = File.open(file, 'r')
  (0..8).each do |line|
    chars = f.readline.split(' ')
    (0..8).each do |col|
      c = chars[col]
      if c == '-'
        n = Node.new(line, col, false, nil, [1,2,3,4,5,6,7,8,9])
      else
        n = Node.new(line, col, true, c.to_i)
      end
      board[line][col] = n
    end
  end
  f.close
  return board
end

#this method returns true if all square have been assigned. Otherwise, it returns false.
def satisfied(board)
  board.each do |r|
    r.each do |c|
      return false if c.value.nil?
    end
  end
end

#this method selects the next node for expansion
def next_node(board)
  #find node with least possible values available
  #but not one we've looked at recently.. hm
  #also do not choose a complete node

  #method to return next node reading puzzle like a book
  candidate = board[@cur/10][@cur%10]
  puts candidate.inspect
  @cur += 1
  @cur = 0 if @cur >= 89
  @cur += 1 if @cur%10 == 9
  if !candidate.value.nil?
    #we don't want to return a node that we've assigned, 
    #so if this is the case let's find another option
    return next_node(board)
  else
    #the value of this node is nil, so we can try to assign it
    return candidate
  end
end

def backtracking_search(board)
  return board if satisfied(board)
  node = next_node(board)
  node.update_possible(board)
  node.possible_values.each do |i|
    if node.check_value(board, i)
      node.value = i
      result = backtracking_search(board)
      if result == 'failure'
        node.value = nil
      else
        return board
      end
    end
  end
  return 'failure'
end

def show(board)
  board.each do |line|
    line.each do |square|
      print "#{(square.value ? square.value : '-')}" + ' '
    end
    puts ''
  end
end

#================ Execution begins here =======================#

@cur = 0
puzzle = make_sudoku_puzzle(ARGV[0])
puts "START STATE:"
show puzzle
gameover = backtracking_search(puzzle)
puts "FINAL STATE:"
if gameover != 'failure'
  show gameover 
else
  puts "failure"
end



