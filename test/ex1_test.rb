require "jinitest"

class Ex1Test < JiniTest::Test
  setup do
    @name = 'JO'
  end

  def test_foo
    @name = 'AGO'
    assert @name, 'AGO'
    assert 0, 0
  end

  def test_bar
    assert @name, 'JO'
  end
end

