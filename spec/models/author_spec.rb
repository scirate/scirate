require 'spec_helper'

describe Authorship do
  before do
    @author = Authorship.create(fullname: "Lucrezia Mongfish", keyname: "Mongfish", forenames: "Lucrezia")
  end

  subject { @author }

  it { should respond_to(:fullname) }
  it { should respond_to(:keyname) }
  it { should respond_to(:forenames) }
  
  it { should be_valid }
end
