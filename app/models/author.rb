class Author < ActiveRecord::Base
  has_many :authorships
  has_many :papers, through: :authorships

  def self.make_uniqid(model)
    Digest::SHA1.hexdigest(model.forenames.inspect+model.keyname.inspect+model.suffix.inspect+model.affiliation.inspect)
  end

  def self.arxiv_import(models, opts={})
    uniqids = models.map { |model| Author.make_uniqid(model) }
    existing_uniqids = Author.where(uniqid: uniqids).map(&:uniqid)

    columns = [:uniqid, :affiliation, :forenames, :keyname, :suffix, :fullname, :searchterm]
    values = []

    models.each_with_index do |model, i|
      uniqid = uniqids[i]
      next if existing_uniqids.include?(uniqid)
      values << [
        uniqid,
        model.affiliation,
        model.forenames,
        model.keyname,
        model.suffix,
        Author.make_fullname(model),
        Author.make_searchterm(model)
      ]
    end

    result = Author.import(columns, values, opts)
    unless result.failed_instances.empty?
      SciRate3.notify_error("Error importing authors: #{result.failed_instances.inspect}")
    end

    puts "Read #{models.length} authors: #{values.length} new [#{models[0].keyname} to #{models[-1].keyname}]"
  end

  # Makes a searchterm of the form e.g. 
  # "Biagini_M" from "Maria Enrica Biagini"
  def self.make_searchterm(model)
    if model.forenames
      term = "#{model.keyname}_#{model.forenames[0][0]}"
    else
      # No forenames can happen in case of collaboration pseudonames
      spl = model.keyname.split(/\s+/)
      if spl.length == 0
        term = spl[0]
      else
        term = "#{spl[-1]}_#{spl[0]}"
      end
    end

    term.mb_chars.normalize(:kd).gsub(/[^\x00-\x7f]/n, '').to_s
  end

  def self.make_fullname(model)
    fullname = model.keyname
    fullname = model.forenames + ' ' + fullname if model.forenames
    fullname = fullname + ' ' + model.suffix if model.suffix
    fullname
  end
end
