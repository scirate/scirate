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

  def self.make_searchterm(model)
    term = "#{model.keyname.tr('-','_').mb_chars.normalize(:kd).gsub(/[^\x00-\x7f]/n, '').to_s}"
    term += "_#{model.forenames[0][0]}" if model.forenames
  end

  def self.make_fullname(model)
    fullname = model.keyname
    fullname = model.forenames + ' ' + fullname if model.forenames
    fullname = fullname + ' ' + model.suffix if model.suffix
    fullname
  end
end
