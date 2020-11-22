require 'pry-nav'

module MiniTest
  def self.autorun
    puts '1: autorun'
    at_exit {
      MiniTest.run
    }
  end

  def self.run
    puts '3: run - get suites that contain Test classes'
    suites = Test.runnables.reject { |suite| suite.runnable_methods.empty? }
    suites.map { |suite| suite.run }
  end

  def self.run_method(klass, method_name)
    result = klass.new(method_name).run
    puts "Method #{method_name} in class #{klass.name} return #{result}"
  end

  class Test
    @@runnables = []

    def initialize(method_name)
      @method_name = method_name
    end

    def run
      puts '5: run - run test method'
      self.send(@method_name)
    end

    def assert(a, b)
      a == b
    end

    def self.runnables
      @@runnables
    end

    def self.inherited(klass)
      puts "2: inherited -> #{klass}"
      self.runnables << klass
      super
    end

    def self.runnable_methods
      self.public_instance_methods(true).grep(/^test_/)
    end

    def self.run
      puts '4: run - get test methods in Parent test class'
      test_methods = self.runnable_methods
      test_methods.each do |method_name|
        MiniTest.run_method(self, method_name)
      end
    end
  end
end

MiniTest.autorun

