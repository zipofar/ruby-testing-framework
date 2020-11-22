require "minitest"
require "meme"

class TestMeme < MiniTest::Test
  def test_foo
    meme = Meme.new
    result = meme.plus(1, 3)
    assert 4, result
  end
end

