require 'test_helper'

class TopTagTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert TopTag.new.valid?
  end
end
