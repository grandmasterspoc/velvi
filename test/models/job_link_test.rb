# == Schema Information
#
# Table name: job_links
#
#  id         :integer          not null, primary key
#  job_title  :string
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class JobLinkTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end