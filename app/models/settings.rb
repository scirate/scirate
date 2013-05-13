module Settings
  # Definable application-wide settings which can be
  # overrided by values of ENV. This is nicer than accessing
  # ENV directly as it will throw a NameError rather than
  # return nil in cases of typos.

  # Modern feed names which arxiv will provide in rss form 
  # as per message at http://export.arxiv.org/rss/doesnotexist
  CURRENT_FEEDS = ['astro-ph', 'cond-mat', 'cs', 'gr-qc', 'hep-ex', 'hep-lat', 'hep-ph', 'hep-th', 'math', 'math-ph', 'nlin', 'nucl-ex', 'nucl-th', 'physics', 'q-bio', 'q-fin', 'quant-ph', 'stat']

  ENV.each do |key, val|
    begin
      Settings.send(:remove_const, key) if Settings.const_defined?(key, false)
      Settings.const_set(key, val)
    rescue NameError # Ruby constants have a stricter syntax than ENV
    end
  end
end
