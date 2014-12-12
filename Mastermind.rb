require 'fox16'
include Fox

class MastermindMatrix < FXMatrix
  def initialize(parent)
    super(parent, 2)
    self.backColor = :DarkGreen
    4.times do
      MastermindAnswerPeg.new(self)
    end
  end
end

class MastermindGoButton < FXButton
  def initialize(parent)
    super(parent, 'GO', :opts => BUTTON_NORMAL|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT, :width => 50, :height => 50)
    self.backColor = :DarkGreen
    @row = self.parent
    self.connect(SEL_COMMAND) do
      self.disable
      @go_array = []
      @peg_answer = [:gray] * 4
      @answerCode = @row.parent.code.clone
      @guessCode = @row.children[1..4].map(&:color)
      for i in 0..3
        if @answerCode.index(@guessCode[i]) == i
          @indexInQuestion = @answerCode.index(@guessCode[i])
          @peg_answer.shift if @peg_answer[0] == :gray
          @peg_answer.push(:red)
          @answerCode.delete_at(@indexInQuestion)
          @answerCode.insert(@indexInQuestion, 'INDEX')
        end
      end
      for i in 0..3
        if @answerCode.include?(@guessCode[i])
          @indexInQuestion = @answerCode.index(@guessCode[i])
          @peg_answer.shift if @peg_answer[0] == :gray
          @peg_answer.push(:white)
          @answerCode.delete_at(@answerCode.index(@guessCode[i]))
          @answerCode.insert(@indexInQuestion, 'INDEX')
        end
      end
      @answerMatrix = @row.children[5]
      @count = 0
      @peg_answer.shuffle
      for i in 0..1
        for j in 0..1
          @answerMatrix.childAtRowCol(i,j).backColor = @peg_answer[@count]
          @count = @count + 1
        end
      end
      @row.parent.children.each do |row|
        @go_array << row.children[0]
      end
      if @peg_answer == [:red] * 4
        FXMessageBox.information(@row.parent, MBOX_OK, 'You Win!', 'You Win!')
        @row.parent.reset
        #TODO: Run RESET
      elsif @go_array.map(&:enabled?).uniq[0] == false && @go_array.map(&:enabled?).include?(true) == false
        FXMessageBox.information(@row.parent, MBOX_OK, 'You Lose!', 'You Lose!')
        @row.parent.reset
      end
    end
  end
end

class MastermindRow < FXHorizontalFrame
  def initialize(parent)
    super(parent)
    self.backColor = :black
    MastermindGoButton.new(self)
    4.times do
      MastermindColorPeg.new(self)
    end
    MastermindMatrix.new(self)
  end
end

class MastermindAnswerPeg < FXButton
  def initialize(parent)
    super(parent , '', :opts => BUTTON_NORMAL|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT, :width => 20, :height => 20)
    self.backColor = :DarkGray
  end
end

class MastermindColorPeg < FXButton
  attr_accessor :color
  def initialize(parent)
    super(parent, '', :opts => BUTTON_NORMAL|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT, :width => 50, :height => 50)
    self.backColor = :gray
    @window = self.parent.parent
    @amountPressed = 0
    self.connect(SEL_COMMAND) do
      @amountPressed += 1
      @amountPressed = 0 if @amountPressed > 5
      self.backColor = @window.cycle_color(@amountPressed)
      @color = @window.cycle_color(@amountPressed)
    end
  end
end

class MastermindWindow < FXMainWindow
  attr_accessor :code
  def initialize(app)
    super(app, 'Mastermind', :opts => DECOR_CLOSE|DECOR_TITLE)
    self.backColor = :DarkSlateGray
    12.times do
      MastermindRow.new(self)
    end
    self.code = self.createCode
  end

  def create
    super
    self.show(PLACEMENT_SCREEN)
  end

  def cycle_color(rem)
    self.getColors[rem]
  end

  def getColors
    [:red, :orange, :yellow, :green, :blue, :pink]
  end

  def reset
    self.children.each do |row|
      row.children[0].enable
      for k in 1..4 do
        row.children[k].backColor = :gray
      end
      for i in 0..1 do
        for j in 0..1 do
          row.children[5].childAtRowCol(i,j).backColor = :DarkGray
        end
      end
    end
    self.code = self.createCode
  end

  def createCode
    code = Array.new
    4.times do
      code << self.getColors.sample
    end
    code
  end
end

app = FXApp.new
MastermindWindow.new(app)
app.create
app.run

