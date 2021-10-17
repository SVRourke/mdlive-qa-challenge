class App < ApplicationRecord
  def self.simpleQ(params)
    by, offset, limit, order = params.values_at(:by, :offset, :limit, :order)
    return App.order("#{by} #{order}").limit(limit).offset(offset)
  end
end
