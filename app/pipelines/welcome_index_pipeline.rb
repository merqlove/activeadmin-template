module WelcomeIndexPipeline
  include ChainableMethods

  def with_hello(lines)
    lines << 'hello'
  end

  def with_hun(lines)
    lines << 'hun'
  end
end
