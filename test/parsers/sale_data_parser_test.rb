require_relative "../test_helper.rb"
describe Parsers::SaleDataParser do


  let(:p) {Parsers::SaleDataParser.new}

  it "generically works" do
    begin
      results = p.parse("(stock no. 1, for $100)")
      results[:stock_number].must_equal "stock no. 1"
      results[:purchase][:currency_symbol].must_equal "$"
      results[:purchase][:value].must_equal "100"
      results[:purchase][:string].must_be_nil
      puts "\nSALE DATA STRUCTURE:\n#{JSON.pretty_generate results}" if ENV["DEBUG"]


    rescue Parslet::ParseFailed => failure
      puts failure.cause.ascii_tree
    end
  end

  it "handles only money amounts" do
    results = p.parse("(for $100)")
    results[:stock_number].must_be_nil
    results[:purchase][:currency_symbol].must_equal "$"
    results[:purchase][:value].must_equal "100"
    results[:purchase][:string].must_be_nil

  end

    it "handles money amounts followed by letters" do
    results = p.parse("(for $100M)")
    results[:stock_number].must_be_nil
    results[:purchase][:currency_symbol].must_equal "$" 
    results[:purchase][:value].must_equal "100M" 
    results[:purchase][:string].must_be_nil

  end


  it "handles alternate currency symbols and locations" do
    "$ƒ£€¢¥₱".split("").each do |sym|
      results = p.parse("(for #{sym}100)")
      results[:stock_number].must_be_nil
      results[:purchase][:currency_symbol].must_equal sym
      results[:purchase][:value].must_equal "100"
      results[:purchase][:string].must_be_nil


      results = p.parse("(for #{sym} 100)")
      results[:stock_number].must_be_nil
      results[:purchase][:currency_symbol].must_equal sym
      results[:purchase][:value].must_equal "100"
      results[:purchase][:string].must_be_nil


      results = p.parse("(for 100#{sym})")
      results[:stock_number].must_be_nil
      results[:purchase][:currency_symbol].must_equal sym
      results[:purchase][:value].must_equal "100"
      results[:purchase][:string].must_be_nil


      results = p.parse("(for 100 #{sym})")
      results[:stock_number].must_be_nil
      results[:purchase][:currency_symbol].must_equal sym
      results[:purchase][:value].must_equal "100"
      results[:purchase][:string].must_be_nil

    end
  end

  it "handles only stock numbers" do
    results = p.parse("(stock no. 1)")
    results[:stock_number].must_equal "stock no. 1"
    results[:purchase].must_be_nil

  end

  it "handles money amounts with commas" do
    results = p.parse("(for $100,000)")
    results[:stock_number].must_be_nil
    results[:purchase][:currency_symbol].must_equal "$"
    results[:purchase][:value].must_equal "100,000"
    results[:purchase][:string].must_be_nil

  end

  it "handles money amounts with decimal places" do
    results = p.parse("(for $10.50)")
    results[:stock_number].must_be_nil
    results[:purchase][:currency_symbol].must_equal "$"
    results[:purchase][:value].must_equal "10.50"
    results[:purchase][:string].must_be_nil
  end

  it "handles strange money amounts" do
    results = p.parse("(for 100 florins)")
    results[:stock_number].must_be_nil
    results[:purchase][:string].must_equal "100 florins"
    results[:purchase][:value].must_be_nil
    results[:purchase][:currency_symbol].must_be_nil
  end 

    it "handles strange money amounts with commas" do
    results = p.parse("(for 5 shillings, three pence)")
    results[:stock_number].must_be_nil
    results[:purchase][:string].must_equal "5 shillings, three pence"
    results[:purchase][:value].must_be_nil
    results[:purchase][:currency_symbol].must_be_nil
  end 
end