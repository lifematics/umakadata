class Endpoint < ActiveRecord::Base
  has_many :evaluations
  has_many :prefixes
  has_many :relations
  has_many :prefix_filters
  has_one :evaluation

  scope :created_at, ->(date) { where('evaluations.created_at': date) }

  def self.rdf_graph
    endpoints = self.thin_out_attributes
    UmakaRDF.build(endpoints)
  end

  def self.thin_out_attributes
    endpoints = []
    all.each do |endpoint|
      hash = endpoint.attributes
      hash['evaluation'] = endpoint.evaluations[0].attributes.select {|key, value| /_log$/ !~ key }
      endpoints << hash
    end
    endpoints
  end

  def self.to_jsonld
    self.rdf_graph.dump(:jsonld, prefixes: UmakaRDF.prefixes)
  end

  def self.to_rdfxml
    self.rdf_graph.dump(:rdfxml, prefixes: UmakaRDF.prefixes)
  end

  def self.to_ttl
    self.rdf_graph.dump(:ttl, prefixes: UmakaRDF.prefixes)
  end

  def self.to_pretty_json
    endpoints = self.thin_out_attributes
    JSON.pretty_generate(JSON.parse(endpoints.to_json))
  end

  after_save do
    if self.issue_id.nil?
      issue = GithubHelper.create_issue(self.name)
      self.update_column(:issue_id, issue[:number]) unless issue.nil?
    else
      GithubHelper.edit_issue(self.issue_id, self.name)
    end
  end

  after_destroy do
    GithubHelper.close_issue(self.issue_id) unless self.issue_id.nil?
  end

  def self.crawled_at(date)
    day_begin = Time.zone.local(date.year, date.month, date.day, 0, 0, 0)
    day_end = Time.zone.local(date.year, date.mon, date.day, 23, 59, 59)
    self.includes(:evaluation).created_at(day_begin..day_end).references(:evaluation)
  end

  def self.get_last_crawled_date
    endpoints = self.joins(:evaluation)
    start_or_end_date = endpoints.first.evaluations.order('created_at DESC').first.created_at
    end_or_start_date = endpoints.last.evaluations.order('created_at DESC').first.created_at
    start_or_end_date > end_or_start_date ? end_or_start_date : start_or_end_date
  end

end
