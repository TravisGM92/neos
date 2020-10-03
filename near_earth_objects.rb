require 'faraday'
require 'figaro'
require 'pry'
# Load ENV vars via Figaro
Figaro.application = Figaro::Application.new(environment: 'production', path: File.expand_path('../config/application.yml', __FILE__))
Figaro.load

class NearEarthObjects
  attr_reader :asteroids_list_data, :parsed_asteroids_data, :date

  def initialize
    puts "________________________________________________________________________________________________________________________________"
    puts "Welcome to NEO. Here you will find information about how many meteors, astroids, comets pass by the earth every day. \nEnter a date below to get a list of the objects that have passed by the earth on that day."
    puts "Please enter a date in the following format YYYY-MM-DD."
    print ">>"
  end

  def self.read_api(date)
    conn = Faraday.new(
      url: 'https://api.nasa.gov',
      params: { start_date: date, api_key: ENV['nasa_api_key']}
    )
    @asteroids_list_data = conn.get('/neo/rest/v1/feed')

    @parsed_asteroids_data = JSON.parse(@asteroids_list_data.body, symbolize_names: true)[:near_earth_objects][:"#{date}"]
  end

  def self.astroid_list(date)
    self.read_api(date)

    formatted_asteroid_data = @parsed_asteroids_data.map do |astroid|
      {
        name: astroid[:name],
        diameter: "#{astroid[:estimated_diameter][:feet][:estimated_diameter_max].to_i} ft",
        miss_distance: "#{astroid[:close_approach_data][0][:miss_distance][:miles].to_i} miles"
      }
    end
  end

  def self.total_number_of_astroids
    @parsed_asteroids_data.count
  end

  def self.largest_astroid(date)
    @parsed_asteroids_data.map do |astroid|
      astroid[:estimated_diameter][:feet][:estimated_diameter_max].to_i
    end.max { |a,b| a<=> b}
  end
end
