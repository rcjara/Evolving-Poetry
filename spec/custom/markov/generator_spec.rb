include MarkovHelper

describe Markov::Generator do
  context ".generate_line" do
    subject { Markov::Generator.new(language) }

    context "with a basic language" do
      let(:language) { poe_language }

      it "should be able to generate a line multiple characters" do
        expect( subject.generate_line.num_chars ).to be > 0
      end
    end

    context "with a language very unlikely to reach a sentence end" do
      let(:text)     { 'the ' * 1 + 'end.' }
      let(:language) { Markov::Language.new.add_snippet(text) }

      it "should be within the character limit" do
        3.times do
          expect( subject.generate_line.num_chars ).to be <= language.limit
        end
      end

    end
  end
end

