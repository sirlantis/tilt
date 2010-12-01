require 'contest'
require 'tilt'
require 'prawn'

class PrawnTemplateTest < Test::Unit::TestCase
  def pdf_data(testcase)
    File.read(File.join(File.dirname(__FILE__), 'prawn', "#{testcase}.pdf"))
  end

  test "registered for '.prawn' files" do
    assert_equal Tilt::PrawnTemplate, Tilt['test.prawn']
    assert_equal Tilt::PrawnTemplate, Tilt['test.pdf.prawn']
  end

  test "loading and evaluating templates on #render" do
    template = Tilt::PrawnTemplate.new { |t| "pdf.text('Hello World!')" }
    assert_equal pdf_data('render'), template.render
  end

  test "passing locals" do
    template = Tilt::PrawnTemplate.new { 'pdf.text("Hey #{name}!")' }
    assert_equal pdf_data('locals'), template.render(Object.new, :name => 'Joe')
  end

  test "evaluating in an object scope" do
    template = Tilt::PrawnTemplate.new { 'pdf.text("Hey #{@name}!")' }
    scope = Object.new
    scope.instance_variable_set :@name, 'Joe'
    assert_equal pdf_data('scope'), template.render(scope)
  end

  test "passing a block for yield" do
    template = Tilt::PrawnTemplate.new { 'pdf.text("Hey #{yield}!")' }
    assert_equal pdf_data('yield'), template.render { 'Joe' }
  end

  test "backtrace file and line reporting without locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    template = Tilt::PrawnTemplate.new('test.prawn', 11) { data }
    begin
      template.render
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of NameError, boom
      line = boom.backtrace.first
      file, line, meth = line.split(":")
      assert_equal 'test.prawn', file
      assert_equal '11', line
    end
  end

  test "backtrace file and line reporting with locals" do
    data = File.read(__FILE__).split("\n__END__\n").last
    template = Tilt::PrawnTemplate.new('test.prawn', 1) { data }
    begin
      template.render(nil, :name => 'Joe', :foo => 'bar')
      fail 'should have raised an exception'
    rescue => boom
      assert_kind_of RuntimeError, boom
      line = boom.backtrace.first
      file, line, meth = line.split(":")
      assert_equal 'test.prawn', file
      assert_equal '2', line
    end
  end

end

__END__
pdf.text("Hey #{name}!")
fail "expected fail"
