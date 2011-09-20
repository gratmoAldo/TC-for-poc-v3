require 'test_helper'

class TaggingTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Tagging.new.valid?
  end
end
