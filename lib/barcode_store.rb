require 'singleton'

class BarcodeStore
  include Singleton

  def initialize
    @store = {}
    @history = []
  end

  def add_barcode(crn, provider_details)
    @store[crn] = provider_details
  end

  def find_by_crn(crn)
    @store[crn]
  end

  def delete_barcode(crn)
    @store.delete(crn)
  end

  def list_by_provider(provider_id)
    @store.select { |_, details| details[:provider_id] == provider_id }
  end

  def add_to_history(barcode, mask, success)
    @history << {
      barcode: barcode,
      mask: mask,
      success: success,
      timestamp: Time.now
    }
  end

  def get_history
    @history
  end
end
