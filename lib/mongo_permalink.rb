# coding: utf-8
module MongoPermalink

  def self.included(model)
    class << model
      attr_accessor :source_key
    end
    model.class_eval do
      model.extend( ClassMethods )
    end
  end

  module ClassMethods

    def has_permalink(source_key_param)
      key :permalink, String
      validates_uniqueness_of :permalink
      before_validation :create_permalink

      send :include, InstanceMethods

      self.source_key = source_key_param
    end

  end

  module InstanceMethods

    private
      def create_permalink
        self.permalink = String.new(read_attribute(self.class.source_key).force_encoding("utf-8")) || ""
        remove_special_chars
        random_permalink if permalink.blank?
        create_unique_permalink
      end

      def remove_special_chars
        permalink.gsub!(/[àáâãäå]/i,'a')
        permalink.gsub!(/[èéêë]/i,'e')
        permalink.gsub!(/[íìîï]/i,'i')
        permalink.gsub!(/[óòôöõ]/i,'o')
        permalink.gsub!(/[úùûü]/i,'u')
        permalink.gsub!(/æ/i,'ae')
        permalink.gsub!(/ç/i, 'c')
        permalink.gsub!(/ñ/i, 'n')
        permalink.gsub!(/[^\x00-\x7F]+/, '') # Remove anything non-ASCII entirely (e.g. diacritics).
        permalink.gsub!(/[^\w_ \-]+/i, '') # Remove unwanted chars.
        permalink.gsub!(/[ \-]+/i, '-') # No more than one of the separator in a row.
        permalink.gsub!(/^\-|\-$/i, '') # Remove leading/trailing separator.
        permalink.downcase!
      end

      def create_unique_permalink
        permalink_src = permalink
        i = 1
        while is_unique(permalink_src)==false do
          permalink_src = permalink+i.to_s
          i = i+1
        end
        permalink = permalink_src
      end

      def random_permalink
        #self.permalink = Digest::SHA1.hexdigest("#{Time.now}")
        self.permalink = rand(9999999999).to_s
      end

      def is_unique(current_permalink)
        self.class.find_by_permalink(current_permalink)==self || self.class.find_by_permalink(current_permalink)==nil
      end

  end

end

