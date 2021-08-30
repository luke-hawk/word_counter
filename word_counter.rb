require "csv"
require "tty-prompt"


class Configs
  def self.set
    options = {}
    prompt = TTY::Prompt.new

    options[:filepath] = prompt.ask("Where is your CSV file located?", default: "./example")
    file_options = Dir["#{options[:filepath]}/*.csv"]

    options[:filename] = File.basename(prompt.select("In which file do you want to count words?", file_options))
    col_header = CSV.open("#{options[:filepath]}/#{options[:filename]}", &:readline)
    
    options[:col_sep] = prompt.ask("What separator does your CSV use?", default: ",")
    
    options[:ref_column] = prompt.select("In which column would you like to count words?", col_header)
    
    options[:min_count] = prompt.ask("How many occurences do you require to count a word?", convert: :int, default: 2)
    
    options[:use_id] = prompt.yes?("Do you want to copy a value of a certain column to the resulting CSV? (e.g. an id)")
    if options[:use_id]
      options[:id_column] = prompt.select("Which column do you want to use as id?", col_header)
    end

    options[:output] = prompt.ask("Where shall the result be saved?", default: "./example")

    return options
  end
end

class CounterHelper
  def self.count(string, exclude_list)
    return string.scan(/[[:alpha:]]+/) 
      .group_by {|w| w}
      .map {|k,v| [k.gsub(/[!@%&",.:\/]/,'').downcase,v.size]}
      .sort_by(&:last)
      .reverse
      .to_h
      .reject! { |key| exclude_list.include?(key) }
  end
end

class WordCounter
  def self.call
    options = Configs.set
    exclude_list = File.readlines('exclude.txt').join.split(",")
    
    words_array = []
    CSV.foreach("#{options[:filepath]}/#{options[:filename]}", col_sep: options[:col_sep], headers: true) do |row|
      words_hash = {}
      if options[:use_id]
        words_hash[options[:id_column]] = row[options[:id_column]]
      end
      count_hash = CounterHelper.count(row[options[:ref_column]].to_s, exclude_list) || {}
      words_array.push(words_hash.merge(count_hash))
    end

    counted_words = words_array.flat_map(&:keys).uniq.reject! do |key|
     occurences = words_array.map {|row| row[key].to_i }.reduce(0, :+)
     occurences <= options[:min_count]
    end

    CSV.open("#{options[:filepath]}/#{options[:filename].split(".")[0]}_result.csv", "w") do |csv|
      csv << counted_words
      words_array.each do |row|
        csv << row.values_at(*counted_words)
      end
    end
  end
end

WordCounter.call