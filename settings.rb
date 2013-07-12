module Settings
  # Definable application-wide settings which can be
  # overrided by either a local_settings.rb file or values
  # of ENV (in that order). Intended to separate Scirate
  # settings (some of which are sensitive) from general Rails 
  # configuration.
  

  ARXIV_CATEGORY_TOPLEVEL = ['cond-mat', 'physics', 'math', 'nlin', 'physics', 'quant-ph', 'math', 'cs', 'q-bio', 'q-fin', 'stat']

  ARXIV_CATEGORY_FULLNAMES = {
    # cond-mat
    'cond-mat' => "Condensed Matter",
    'cond-mat.dis-nn' => "Disordered Systems and Neural Networks",
    'cond-mat.mtrl-sci' => "Materials Science",
    'cond-mat.mes-hall' => "Mesoscale and Nanoscale Physics",
    'cond-mat.other' => "Other Condensed Matter",
    'cond-mat.quant-gas' => "Quantum Gases",
    'cond-mat.soft' => "Soft Condensed Matter",
    'cond-mat.stat-mech' => "Statistical Mechanics",
    'cond-mat.str-el' => "Strongly Correlated Electrons",
    'cond-mat.supr-con' => "Superconductivity",

    # physics
    'physics' => "Physics",
    'physics.acc-ph' => "Accelerator Physics",
    'physics.ao-ph' => "Atmospheric and Oceanic Physics",
    'physics.atom-ph' => "Atomic Physics",
    'physics.atm-clus' => "Atomic and Molecular Clusters",
    'physics.bio-ph' => "Biological Physics",
    'physics.chem-ph' => "Chemical Physics",
    'physics.class-ph' => "Classical Physics",
    'physics.comp-ph' => "Computational Physics",
    'physics.data-an' => "Data Analysis, Statistics and Probability",
    'physics.flu-dyn' => "Fluid Dynamics",
    'physics.gen-ph' => "General Physics",
    'physics.geo-ph' => "Geophysics",
    'physics.hist-ph' => "History and Philosophy of Physics",
    'physics.ins-det' => "Instrumentation and Detectors",
    'physics.med-ph' => "Medical Physics",
    'physics.optics' => "Optics",
    'physics.ed-ph' => "Physics Education",
    'physics.soc-ph' => "Physics and Society",
    'physics.plasm-ph' => "Plasma Physics",
    'physics.pop-ph' => "Popular Physics",
    'physics.space-ph' => "Space Physics",

    # math
    'math' => "Mathematics",
    'math.AG' => "Algebraic Geometry",
    'math.AT' => "Algebraic Topology",
    'math.AP' => "Analysis of PDEs",
    'math.CT' => "Category Theory",
    'math.CA' => "Classical Analysis and ODEs",
    'math.CO' => "Combinatorics",
    'math.AC' => "Commutative Algebra",
    'math.CV' => "Complex Variables",
    'math.DG' => "Differential Geometry",
    'math.DS' => "Dynamical Systems",
    'math.FA' => "Functional Analysis",
    'math.GM' => "General Mathematics",
    'math.GN' => "General Topology",
    'math.GT' => "Geometric Topology",
    'math.GR' => "Group Theory",
    'math.HO' => "History and Overview",
    'math.IT' => "Information Theory",
    'math.KT' => "K-Theory and Homology",
    'math.LO' => "Logic",
    'math.MP' => "Mathematical Physics",
    'math.MG' => "Metric Geometry",
    'math.NT' => "Number Theory",
    'math.NA' => "Numerical Analysis",
    'math.OA' => "Operator Algebras",
    'math.OC' => "Optimization and Control",
    'math.PR' => "Probability",
    'math.QA' => "Quantum Algebra",
    'math.RT' => "Representation Theory",
    'math.RA' => "Rings and Algebras",
    'math.SP' => "Spectral Theory",
    'math.ST' => "Statistics Theory",
    'math.SG' => "Symplectic Geometry",

    # nlin
    'nlin' => "Nonlinear Sciences",
    'nlin.AO' => "Adaptation and Self-Organizing Systems",
    'nlin.CG' => "Cellular Automata and Lattice Gases",
    'nlin.CD' => "Chaotic Dynamics",
    'nlin.SI' => "Exactly Solvable and Integrable Systems",
    'nlin.PS' => "Pattern Formation and Solitons",

    # q-bio
    'q-bio.BM' => "Biomolecules",
    'q-bio.CB' => "Cell Behavior",
    'q-bio.GN' => "Genomics",
    'q-bio.MN' => "Molecular Networks",
    'q-bio.NC' => "Neurons and Cognition",
    'q-bio.OT' => "Other Quantitative Biology",
    'q-bio.PE' => "Populations and Evolution",
    'q-bio.QM' => "Quantitative Methods",
    'q-bio.SC' => "Subcellular Processes",
    'q-bio.TO' => "Tissues and Organs",
 
     # stat
    'stat.AP' => "Applications",
    'stat.CO' => "Computation",
    'stat.ML' => "Machine Learning",
    'stat.ME' => "Methodology",
    'stat.OT' => "Other Statistics",
    'stat.TH' => "Statistics Theory",
  }

  # Rails secret token for signing cookies, should be in ENV for production
  if ENV['RAILS_ENV'] != 'production'
    SECRET_TOKEN = '4b4d948fe0bdde9d1f66af4bcbe15cec68339f7445038032f5313e2f00c36eacb2c8b780fe40e5e9106c9ecbc175893a579f9d138942195eb3fe76e51a767ebe'
  end

  # Hostname to put in emails and such
  HOST = "scirate.com"


  #####
  # Sensitive development settings
  # Define in local_settings.rb
  #####

  # Gmail auth details used in development to test UserMailer mail
  GMAIL_SMTP_USER = ''
  GMAIL_SMTP_PASSWORD = ''


  #####
  # Sensitive production settings
  # Define in Heroku ENV config
  #####

  # Sendgrid auth details used in production to send UserMailer mail
  # SENDGRID_USERNAME = ''
  # SENDGRID_PASSWORD = ''
  
  # New Relic app monitoring auth details
  # NEW_RELIC_LICENSE_KEY = ''
  # NEW_RELIC_APP_NAME = ''


  def self.override(key, val)
    Settings.send(:remove_const, key) if Settings.const_defined?(key, false)
    Settings.const_set(key, val)
  end
end

begin
  require File.expand_path('../local_settings', __FILE__)

  # To override settings for development purposes, make
  # a local_settings.rb file which looks like this:
  #
  # module LocalSettings
  #   SOME_SETTING = 'foo'
  # end

  LocalSettings.constants.each do |key|
    Settings.override(key, LocalSettings.const_get(key))
  end
rescue LoadError # Don't worry if there's no local_settings.rb file
end

ENV.each do |key, val|
  begin
    Settings.override(key, val)
  rescue NameError # Ruby constants have a stricter syntax than ENV
  end
end
