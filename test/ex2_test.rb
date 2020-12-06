require "jinitest"

class Ex2Test < JiniTest::Test
  def test_foo
    assert 1, 1
    assert 0, 0
  end

  def test_bar
    assert 1, 1
  end

  def test_fiz
    assert 1, 0
    assert 1, 1
  end
end

