class ShellCommand
  attr_accessor :output

  def initialize(commands)
    @commands = commands
  end

  def execute
    IO.popen('-') do |p|
      if p.nil?
        $stderr.close
        exec *@commands
      end
      @output = p.read
    end
  end

  def run_and_return_output_if_success
    self.execute
    return @output if self.success?
  end

  def success?
    return false if $?.nil?
    $?.exitstatus == 0 ? true : false
  end

  def status
    $?.exitstatus unless $?.nil?
  end
end
