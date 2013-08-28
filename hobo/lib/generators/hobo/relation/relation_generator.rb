require 'rails/generators/active_record'

module Hobo
  class RelationGenerator < Rails::Generators::NamedBase

    argument :attributes,
             :type => :array,
             :default => [],
             :banner => "field:type field:type"

    class_option :timestamps,
                 :type => :boolean

    def generate_hobo_relation
      for hm in hms
        inject_has_many hm
      end
      for bt in bts
        inject_belongs_to bt
      end
    end

    protected

    def inject_has_many(hm)
      inject_into_file model_path, "  has_many :#{hm}, :dependent => :destroy\n\n", :before => "  # --- Permissions --- #"
    end

    def inject_belongs_to(bt)
      inject_into_file model_path, "  belongs_to :#{bt}\n\n", :before => "  # --- Permissions --- #"
      attr_accessible_line = File.open(model_path).lines.to_a.find{|l| l =~ /attr/}.gsub("\n", "")
      inject_into_file model_path, ", :#{bt}", :after => attr_accessible_line
    end

    def model_path
      @model_path ||= File.join("app", "models", "#{file_path}.rb")
    end

    def hms
      attributes.select { |a| a.name == "hm" }.*.type
    end

    def bts
      attributes.select { |a| a.name == "bt" }.*.type
    end

  end
end
