# == Schema Information
#
# Table name: job_links
#
#  id            :integer          not null, primary key
#  job_title     :string
#  job_type      :string
#  job_subtitles :string
#  job_location  :string
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'indeed_search_worker'
require 'job_application_worker'
require 'mechanize'
require 'open-uri'

class JobLink < ActiveRecord::Base

  belongs_to :user
  has_many :job_applications
  after_create  :run_search#:call_search_worker
  after_update :call_application_worker
  validates_presence_of :job_title
  accepts_nested_attributes_for :job_applications

  ## Solution: save each paginated page in an array and run an each loop on that

  def run_search
    agent = Mechanize.new 
    agent.get('http://www.indeed.com/')
    fill_out_search_form(agent)
    # loop_through_pages_and_search(agent)

    search_and_create_job_application(agent)
  end

  def fill_out_search_form(agent)
    form = agent.page.forms[0]
    form["q"] = job_title
    form["l"] =  job_location
    form.submit
  end 


  def search_and_create_job_application(agent)
    path_to_resume = resume_key
    # byebug
    @counter = 0

    search_page = agent.page
    until !(search_page.at_css(".np:contains('Next »')")) || @counter == 12
      begin 
        search_page = agent.page
        break if !(search_page.at_css(".np:contains('Next »')"))
          agent.page.search(".result:contains('Easily apply')").each do |title|

          job_title_company_location_array = [title.css('h2').text, title.at(".company").text, title.search('.location').text]
          next if job_applications.where(title: job_title_company_location_array[0], company: job_title_company_location_array[1]).any? || !(agent.page.uri.to_s.match(/indeed.com/))

            indeed_job_address = "http://www.indeed.com#{title.at('a').attributes['href'].value}"

      

            create_job_application(agent, title, job_title_company_location_array, path_to_resume, indeed_job_address)
              # click_easily_applicable_link(agent, title, job_title_company_location_array, path_to_resume)
          end 
          indeed_base = search_page.uri.to_s.split("&start").first
          next_page = "#{indeed_base}&start=#{@counter+=1}0"
          agent.get next_page
          puts "===\n\n#{agent.page.uri}"
      rescue Exception => e
         puts "\n\n#{e}\n\n"
         next 
      end  
    end  
  end  

  def create_job_application(agent, title, job_attributes, path_to_resume, indeed_job_url)
    puts "\n\n#{'===='*40}\n\n\n -----CREATING FILE FROM----- \n#{agent.page.uri}\n\n\n\n\n"
        job_applications.find_or_create_by(indeed_link: indeed_job_url,
                                           title: job_attributes[0],
                                           company: job_attributes[1], 
                                           location: job_attributes[2], 
                                           user_name: user_attribute_array[0],
                                           user_email: user_attribute_array[1],
                                           user_phone_number: user_attribute_array[2],
                                           user_resume_path: path_to_resume,
                                           user_cover_letter: user_attribute_array[3]
                                           )
  end  


  # def click_easily_applicable_link(agent, title, job_attributes, path_to_resume)
  #   puts "place 2"
  #   begin
      
  #     agent.click title.css('a').first

  #     puts "Place 3"  
  #     if !(agent.page.uri.to_s.match(/indeed.com\/jobs?/)) && !!(agent.page.uri.to_s.match(/indeed.com/))
  #       puts "\n\n#{'===='*40}\n\n\n -----CREATING FILE FROM----- \n#{agent.page.uri}\n\n\n\n\n"
  #       job_applications.find_or_create_by(indeed_link: agent.page.uri.to_s,
  #                                          title: job_attributes[0],
  #                                          company: job_attributes[1], 
  #                                          location: job_attributes[2], 
  #                                          user_name: user_attribute_array[0],
  #                                          user_email: user_attribute_array[1],
  #                                          user_phone_number: user_attribute_array[2],
  #                                          user_resume_path: path_to_resume,
  #                                          user_cover_letter: user_attribute_array[3]) 
  #     end
  #   rescue => e
  #     puts e 
  #     puts "no page here"     
  #     return
  #   end  
  # end  

  def user_attribute_array
    ["#{user.first_name} #{user.last_name}", user.email, user.phone_number, user.cover_letter]
  end


  def resume_key
    user.resume.url.split('http://s3.amazonaws.com/job-bot-bucket/').last.split('?').first
  end  

  def call_search_worker
    SearchWorker.perform_async(id)
  end  

  def call_application_worker
    ApplicationWorker.perform_async(id)
  end  
end

