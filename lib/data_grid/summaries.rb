# Methods defined in this module are available as summary in DataGrid

module DataGrid
  # Grid summaries
  class Summaries
    
    def self.average(a)
      result = 0 
      unless a.blank?
        a.each{|p| result += p.to_f} 
        result /= a.size
      end
      result.to_s
    end

    def self.sum(a)
      result = 0
      a.each{|p| result += p.to_f} unless a.blank?
      result.to_s
    end
    
    def self.sum_price(a)
      result = 0
      unless a.blank?
        a.each do |p|
          result += p.match(/\-*\d+\,\d+/)[0].gsub(',', '.').to_f if p.match(/\d+\,\d+/) and p.match(/\d+\,\d+/)[0] 
        end
      end
      result = sprintf("%.2f", result.to_f.round(2)).to_s 
      result
    end
  end
end

