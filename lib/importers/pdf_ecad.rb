require "pdf-reader"

class Importers::PdfEcad
  attr_accessor :text
  CATEGORIES = {"CA" => "Author", "E" => "Publisher", "V" => "Versionist", "SE" => "SubPublisher"}
  @line = ""
   def initialize(path)
     file = PDF::Reader.new(path)
     @text = []
     file.pages.each { |page|  @text += page.text.each_line.map{ |line| line } }
   end

   def works
     all_works = []
     actual_work = {}
     @text.each do |line|
       @line = line
       if work?
         all_works<< actual_work if actual_work != {}
         actual_work = work @line
       end
       if holder?
         actual_work[:right_holders]<< right_holder(@line)
       end
     end
     all_works<< actual_work
   end

   def right_holder(line)
     @line = line
     return unless holder?

     {:name => name,
     :pseudos => [
       {:name => pseudo,
        :main => true},
     ],
     :ipi => ipi,
     :society_name => society_name,
     :share => share,
     :role => role,
     :external_ids => [
       {
         :source_name => "Ecad",
         :source_id => id}],

   }
   end

   def work(line)
     @line = line
     {
       :iswc => iswc,
       :title => title,
       :external_ids => [
         {
           :source_name => "Ecad",
           :source_id => id}
         ],
       :situation => situation,
       :created_at => created_at,
       :right_holders => [],
     }
   end
   private

   def ipi
     ipi_ = clean_string(@line.length - 65," ").gsub(".","")
     return ipi_ if ipi_.length > 0

   end

   def society_name
     clean_string @line.length - 52
   end

   def share
    @line.slice(110..115).strip.gsub(",",".").to_f
   end

   def role
    CATEGORIES[@line.slice(106..110).strip]
   end

   def iswc
     @line.slice(12..28).strip
   end

   def title
     clean_string 34
   end

   def name
     clean_string 12
   end

   def pseudo
     clean_string 50
   end

   def situation
     @line.slice(90..110).strip
   end

   def holder?
     @line.length>123 and @line =~ /^[0-9]/ and not @line =~ /^[0-9][0-9]\/[0-9][0-9]/
   end

   def created_at
     @line.slice(@line.length-11..).strip
   end

   def id
     @line.slice(0..11).strip
   end

   def clean_string(position, pattern="  ")
     @line.slice(position..(position + 1 + @line.slice(position + 2..).index(pattern))).strip
   end
   def work?
      @line =~ /[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9][0-9][0-9]\n/
   end
end
