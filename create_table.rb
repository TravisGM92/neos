require_relative 'near_earth_objects'

class CreateTable

  def self.columns(astroid_list)
    column_labels = { name: "Name", diameter: "Diameter", miss_distance: "Missed The Earth By:" }
    @column_data = column_labels.each_with_object({}) do |(col, label), hash|
      hash[col] = {
        label: label,
        width: [astroid_list.map { |astroid| astroid[col].size }.max, label.size].max}
    end
  end

  def self.headers
    "| #{ @column_data.map { |_,col| col[:label].ljust(col[:width]) }.join(' | ') } |"
  end

  def self.dividers
    "+-#{@column_data.map { |_,col| "-"*col[:width] }.join('-+-') }-+"
  end

  def self.format_row_data(row_data, column_info)
    row = row_data.keys.map { |key| row_data[key].ljust(column_info[key][:width]) }.join(' | ')
    puts "| #{row} |"
  end

  def self.create_rows(astroid_data, column_info)
    rows = astroid_data.each { |astroid| self.format_row_data(astroid, column_info) }
  end

  def self.results(date)
    header = self.headers
    divider = self.dividers
    formated_date = DateTime.parse(date).strftime("%A %b %d, %Y")
    puts "______________________________________________________________________________"
    puts "On #{formated_date}, there were #{NearEarthObjects.total_number_of_astroids} objects that almost collided with the earth."
    puts "The largest of these was #{NearEarthObjects.largest_astroid(date)} ft. in diameter."
    puts "\nHere is a list of objects with details:"
    puts divider
    puts header
    self.create_rows(NearEarthObjects.astroid_list(date), @column_data)
    puts divider
  end
end
