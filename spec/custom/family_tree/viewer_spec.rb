describe FamilyTree::Viewer do
  (1..4).each do |i|
    str = 'p' + i.to_s
    let(str.to_sym) { double(str, to_s: 'p') }
  end

  describe ".display" do
    subject { FamilyTree::Viewer.display(array) }

    describe "scenario 1" do
      let(:array) { [[p1]] }

      it { should == "p" }
    end

    describe "scenario 2" do
      let(:array) { [[ p1, nil, nil],
                     ['[', 'T', ']'],
                     [ p2,  p3,  p4]] }

      it { should == ["p . .",
                      "[ T ]",
                      "p p p"].join("\n") }
    end

    describe "scenario 3" do
      let(:array) { [[ p1, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
                     ['[', '-', '-', '-', '-', 'T', 'T', 'T', ']', nil, nil],
                     [ p2, nil, nil, nil, nil,  p2,  p2,  p2,  p2, nil, nil],
                     ['[', '-', '-', '-', ']', nil, nil, nil, '[', '-', ']'],
                     [ p3,  p3,  p3,  p3,  p3, nil, nil, nil,  p4,  p4,  p4]] }

      it { should == ["p . . . . . . . . . .",
                      "[ - - - - T T T ] . .",
                      "p . . . . p p p p . .",
                      "[ - - - ] . . . [ - ]",
                      "p p p p p . . . p p p"].join("\n") }
    end
  end

end


