class Base < ApplicationRecord
  validates :baseid, presence: true
  validates :basename, presence: true
  validates :basetype, presence: true
end
