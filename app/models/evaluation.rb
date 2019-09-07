class Evaluation < ApplicationRecord
  belongs_to :crawl
  belongs_to :endpoint
  has_many :measurements

  attribute :exceptions, :binary_hash
end