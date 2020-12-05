module MiniTest
  def self.autorun
    at_exit {
      MiniTest.run
    }
  end

  def self.run
    reporter = Reporter.new
    reporter.render_header
    suites = Test.runnables.reject { |suite| suite.runnable_methods.empty? }
    suites.map { |suite| suite.run(reporter) }
    reporter.render_statistics
  end

  def self.run_method(klass, method_name, reporter)
    reporter.inc_runs
    begin
      klass.new(method_name, reporter).run
      reporter.render_test_ok
    rescue TestError => e
      reporter.add_failure(e)
      reporter.render_test_failure
    end
  end

  class Reporter
    MSG_ASSERT_FAILURE = 'Expected false to be truthy.'

    def initialize
      @count_runs = 0
      @count_assertions = 0
      @count_failures = 0
      @failures = []
    end

    def add_failure(e)
      @count_failures += 1
      @failures << e
    end

    def inc_runs
      @count_runs += 1
    end

    def inc_assertions
      @count_assertions += 1
    end

    def render_test_ok
      print('.')
    end

    def render_test_failure
      print('F')
    end

    def render_header
      print "# Running:\r\n\r\n"
    end

    def render_statistics
      print "\r\n"
      print "# Finish:\r\n"
      print "\r\n"
      print render_failures, "\r\n"
      print "\r\n"
      print "#{@count_runs} runs, #{@count_assertions} assertions, #{@count_failures} failures"
      print "\r\n"
    end

    private

    def render_failures
      text_failures = @failures.map.with_index do |failure, i|
        info = parse_failure(failure)
        header = "#{i}) Failure:"
        body = "#{failure.class_name}##{info[:method_name]} [#{info[:file_path]}:#{info[:line_number]}]:"
        [header, body].join("\r\n")
      end

      text_failures.join("\r\n")
    end

    def parse_failure(failure)
      place_of_exception = failure.backtrace[1].split(' ')

      info_about_file = place_of_exception[0].split(':')

      {
        method_name: place_of_exception[1].delete('`\''),
        file_path: info_about_file[0],
        line_number: info_about_file[1],
      }
    end
  end

  class TestError < StandardError
    attr_reader :class_name

    def initialize(class_name, msg = '')
      @class_name = class_name
      super(msg)
    end
  end

  class Test
    @@runnables = []

    def initialize(method_name, reporter)
      @method_name = method_name
      @reporter = reporter
    end

    def run
      self.send(@method_name)
    end

    def assert(a, b)
      @reporter.inc_assertions
      result = a == b
      raise TestError.new(self.class) unless result
      result
    end

    def self.runnables
      @@runnables
    end

    def self.inherited(klass)
      self.runnables << klass
      super
    end

    def self.runnable_methods
      self.public_instance_methods(true).grep(/^test_/)
    end

    def self.run(reporter)
      test_methods = self.runnable_methods
      test_methods.each do |method_name|
        MiniTest.run_method(self, method_name, reporter)
      end
    end
  end
end

MiniTest.autorun

