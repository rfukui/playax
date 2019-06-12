require "pdf-reader"
require_relative '../importers'

class Importers::PdfEcad
  NAME = 12
  TITLE = 34
  PSEUDO = 50
  SOCIETY_NAME = 80
  SITUATION = 90


  CATEGORIES = {"CA" => "Author", "E" => "Publisher", "V" => "Versionist", "SE" => "SubPublisher"}
   def initialize(path)
     @all_works = []
     @path = path
     @line = ""
   end

   def works
     return @all_works unless @all_works.length == 0

     file = PDF::Reader.new(@path)
     text =[]
     actual_work = {}
     file.pages.each do |page|
       page.text.each_line do |line|
         @line = line
         if work?
           @all_works<< actual_work if actual_work != {}
           actual_work = work @line
         end
        actual_work[:right_holders]<< right_holder(@line) if holder?
       end
     end
     @all_works<< actual_work
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

   def id
     @line.slice(0..11).strip
   end

   def iswc
     @line.slice(12..28).strip
   end

   def ipi
     ipi_ = match(/[0-9]?[0-9]?[0-9]\.[0-9]?[0-9]?[0-9]\.[0-9]?[0-9]?[0-9]\.[0-9]?[0-9]?[0-9]/).gsub(".","")
     return ipi_ if ipi_.length > 0

   end

    def role
     CATEGORIES[match(/[A-Z][A-Z]/, 106)]
    end

   def share
    match(/[0-9]?[0-9]?[0-9]\,[0-9]?[0-9]?[0-9]?/).gsub(",",".").to_f
   end

   def name
     words NAME
   end

   def title
     words TITLE
   end

   def pseudo
     words PSEUDO
   end

   def society_name
     words SOCIETY_NAME
   end

   def situation
    words SITUATION
   end

   def created_at
     match(/[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9][0-9][0-9]/)
   end


   def words(index)
     match(/(?<=\s)([^\s].*?)(?=\s\s)/, index)
   end

   def match(regex, index = 0)
     @line.slice(index..).match(regex).to_s
   end


   def holder?
     @line.length>123 and @line =~ /^[0-9]/ and not @line =~ /^[0-9][0-9]\/[0-9][0-9]/
   end

   def work?
      @line =~ /[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9][0-9][0-9]\n/
   end
end
