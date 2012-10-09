describe FamilyTree::Compressor do
  # Create poem doubles for the test
  # Using this construction allows for arbitrary number of poems easily
  (1..12).each do |i|
    str = 'p' + i.to_s
    let(str.to_sym) { double(str, to_s: 'p') }
  end

  subject { FamilyTree::Compressor.new(tree) }

  shared_examples_for "any scenario" do
    its(:result) { should == result }
    its(:to_s)   { should == string }
  end

  describe "Scenario 1: An uncompressable tree" do
    let(:tree) {[[ p1, nil, nil],
                 ['[', 'T', ']'],
                 [ p2,  p3,  p4]] }
    let(:string) {
       ["p . .",
        "[ T ]",
        "p p p"].join("\n")
    }
    let(:result) { tree }

    it_should_behave_like "any scenario"
  end

  describe "Scenario 2: Given a 3-gen simple compressable tree" do
    let(:tree) {
      [[ p1, nil, nil],
       ['[', '-', ']'],
       [ p2, nil,  p3],
       ['[', ']', nil],
       [ p4,  p5, nil]]
    }
    let(:string) {
      ["p .",
       "[ ]",
       "p p",
       "[ ]",
       "p p"].join("\n")
    }
    let(:result) {
      [[ p1, nil],
       ['[', ']'],
       [ p2,  p3],
       ['[', ']'],
       [ p4,  p5]]
    }

    it_should_behave_like "any scenario"
  end


  describe "Scenario 3: A tree with many blank regions" do
    let(:tree) {
      [[ p1, nil, nil, nil, nil, nil, nil, nil],
       ['[', '-', '-', 'T', '-', 'T', '-', ']'],
       [ p2, nil, nil,  p3, nil,  p4, nil,  p5],
       ['[', 'T', ']', '[', ']', '[', ']', nil],
       [ p6,  p7,  p8,  p9, p10, p11, p12, nil]]
    }
    let(:string) {
     ["p . . . . . .",
      "[ - - T - T ]",
      "p . . p . p p",
      "[ T ] [ ] [ ]",
      "p p p p p p p"].join("\n")
    }
    let(:result) {
      [[ p1, nil, nil, nil, nil, nil, nil ],
       ['[', '-', '-', 'T', '-', 'T', ']' ],
       [ p2, nil, nil,  p3, nil,  p4,  p5 ],
       ['[', 'T', ']', '[', ']', '[', ']' ],
       [ p6,  p7,  p8,  p9, p10, p11, p12 ]]
    }

    it_should_behave_like "any scenario"

  end

  describe "Scenario 4: A tree with a huge blank region" do
    let(:tree) { [
      [ p1, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
      ['[', '-', '-', '-', '-', 'T', 'T', 'T', ']', nil, nil],
      [ p2, nil, nil, nil, nil,  p2,  p2,  p2,  p2, nil, nil],
      ['[', '-', '-', '-', ']', nil, nil, nil, '[', '-', ']'],
      [ p3,  p3,  p3,  p3,  p3, nil, nil, nil,  p4,  p4,  p4]]
    }
    let(:string) {
        ["p . . . . . . .",
         "[ - T T T ] . .",
         "p . p p p p . .",
         "[ - - - ] [ - ]",
         "p p p p p p p p"].join("\n")
    }
    let(:result) {
       [[ p1, nil, nil, nil, nil, nil, nil, nil],
        ['[', '-', 'T', 'T', 'T', ']', nil, nil],
        [ p2, nil,  p2,  p2,  p2,  p2, nil, nil],
        ['[', '-', '-', '-', ']', '[', '-', ']'],
        [ p3,  p3,  p3,  p3,  p3,  p4,  p4,  p4]]
    }

    it_should_behave_like "any scenario"
  end
#
  describe "Scenario 5: a huge tree" do
    let(:tree) {
      [[ p1, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
       ['[', '-', '-', '-', '-', '-', 'T', 'T', 'T', ']', nil, nil],
       [ p2, nil, nil, nil, nil, nil,  p2,  p2,  p2,  p2, nil, nil],
       ['[', '-', '-', '-', ']', nil, nil, nil, nil, '[', '-', ']'],
       [ p3,  p3,  p3,  p3,  p3, nil, nil, nil, nil,  p4,  p4,  p4],
       [nil, nil, nil, nil, '[', ']', nil, nil, nil, '|', nil, nil],
       [nil, nil, nil, nil,  p1,  p1, nil, nil, nil,  p1, nil, nil]]
    }
    let(:string) {
      ["p . . . . . . . .",
       "[ - - T T T ] . .",
       "p . . p p p p . .",
       "[ - - - ] . [ - ]",
       "p p p p p . p p p",
       ". . . . [ ] | . .",
       ". . . . p p p . ."].join("\n")
    }
    let(:result) {
      [[ p1, nil, nil, nil, nil, nil, nil, nil, nil],
       ['[', '-', '-', 'T', 'T', 'T', ']', nil, nil],
       [ p2, nil, nil,  p2,  p2,  p2,  p2, nil, nil],
       ['[', '-', '-', '-', ']', nil, '[', '-', ']'],
       [ p3,  p3,  p3,  p3,  p3, nil,  p4,  p4,  p4],
       [nil, nil, nil, nil, '[', ']', '|', nil, nil],
       [nil, nil, nil, nil,  p1,  p1,  p1, nil, nil]]
    }

    it_should_behave_like "any scenario"
  end

  describe "Scenario 6: a tree where there are more 3rd generation poems than 2nd" do
    let(:tree) {
         [[ p1, nil, nil, nil, nil, nil, nil],
          ['[', '-', '-', '-', '-', 'T', ']'],
          [ p2, nil, nil, nil, nil,  p2,  p2],
          ['[', 'T', 'T', 'T', ']', nil, nil],
          [ p3,  p3,  p3,  p3,  p3, nil, nil]]
    }
    let(:string) {
      ["p . . . .",
       "[ T ] . .",
       "p p p . .",
       "[ T T T ]",
       "p p p p p"].join("\n")
    }

    its(:to_s) { should == string }

  end


end
