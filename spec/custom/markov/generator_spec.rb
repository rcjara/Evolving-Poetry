include MarkovHelper

describe Markov::Generator do
  context "with a basic language" do
    let(:language) { poe_language }
    subject { Markov::Generator.new(language) }

    context ".generate_line" do
      it "should be able to generate a line with words" do
        expect( subject.generate_line.words ).to_not be_empty
      end
    end
  end

end

