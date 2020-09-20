require 'spec_helper'

describe ProfileFields::Couleur do
  let(:couleur) { ProfileFields::Couleur.new }
  describe "#set" do
    it "should set the value composing the given values" do
      couleur.set colors: ["schwarz", "weiß", "gold"], percussion_colors: ["silber", "silber"], reverse: false
      couleur.value.should == "schwarz-weiß-gold, Perkussion silber-silber"

      couleur.set colors: ["schwarz", "weiß", "gold"], percussion_colors: ["silber", "silber"], reverse: true
      couleur.value.should == "schwarz-weiß-gold, Perkussion silber-silber, von unten getragen"

      couleur.set colors: ["schwarz", "weiß", "gold"], ground_color: "gold", percussion_colors: ["silber", "silber"], reverse: true
      couleur.value.should == "schwarz-weiß-gold auf gold, Perkussion silber-silber, von unten getragen"
    end
  end

  describe "#colors" do
    subject { couleur.colors }
    before { couleur.set colors: ["schwarz", "weiß", "gold"], percussion_colors: ["silber", "silber"], reverse: true }
    it { should == ["schwarz", "weiß", "gold"] }
  end

  describe "#ground_color" do
    subject { couleur.ground_color }
    describe "when no ground color is set" do
      before { couleur.set colors: ["schwarz", "weiß", "gold"], percussion_colors: ["silber", "silber"], reverse: true }
      it { should == nil }
    end
    describe "when a ground color is set" do
      before { couleur.set colors: ["schwarz", "weiß"], ground_color: "gold", percussion_colors: ["silber", "silber"], reverse: true }
      it { should == "gold" }
    end
  end

  describe "#percussion_colors" do
    subject { couleur.percussion_colors }
    before { couleur.set colors: ["schwarz", "weiß", "gold"], percussion_colors: ["silber", "rot"], reverse: true }
    it { should == ["silber", "rot"] }
  end

  describe "#reverse" do
    subject { couleur.reverse }
    before { couleur.set colors: ["schwarz", "weiß", "gold"], percussion_colors: ["silber", "rot"], reverse: true }
    it { should be true }
  end

  describe "#reverse" do
    subject { couleur.reverse }
    before { couleur.set colors: ["schwarz", "weiß", "gold"], percussion_colors: ["silber", "rot"], reverse: false }
    it { should be false }
  end

  describe "#apparent_colors" do
    subject { couleur.apparent_colors }
    describe "when only the main colors are set" do
      before { couleur.set colors: ["schwarz", "weiß", "gold"] }
      it { should == %w(schwarz weiß gold)}
    end
    describe "when only the main colors are set with reverse wearing" do
      before { couleur.set colors: ["schwarz", "weiß", "gold"], reverse: true }
      it { should == %w(gold weiß schwarz)}
    end
    describe "when main and percussion colors are set" do
      before { couleur.set colors: ["schwarz", "weiß", "gold"], percussion_colors: ["silber", "silber"] }
      it { should == %w(silber schwarz weiß gold silber)}
    end
    describe "when main and percussion colors are set with reverse wearing" do
      before { couleur.set colors: ["schwarz", "weiß", "gold"], percussion_colors: ["silber", "silber"], reverse: true }
      it { should == %w(silber gold weiß schwarz silber)}
    end
    describe "when main, ground, and percussion colors are set" do
      before { couleur.set colors: ["schwarz", "weiß"], ground_color: "gold", percussion_colors: ["rot", "blau"] }
      it { should == %w(rot gold schwarz weiß gold blau)}
    end
    describe "when main, ground, and percussion colors are set with reverse wearing" do
      before { couleur.set colors: ["schwarz", "weiß"], ground_color: "gold", percussion_colors: ["rot", "blau"], reverse: true }
      it { should == %w(blau gold weiß schwarz gold rot)}
    end
  end

end