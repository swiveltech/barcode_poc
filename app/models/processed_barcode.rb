class ProcessedBarcode < ApplicationRecord
  # Constants
  MASK = '*#####RRRRRRRRRRRR########$$$$$$$'
  
  # Validations
  validates :barcode_number, presence: true
  validates :mask_used, presence: true
  
  # Scopes
  scope :recent, -> { order(processed_at: :desc) }
  
  # Callbacks
  before_save :ensure_proper_mask
  
  private
  
  def ensure_proper_mask
    self.mask_used = MASK
  end
end
