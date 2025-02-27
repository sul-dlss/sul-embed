# frozen_string_literal: true

class TabpanelComponent < ViewComponent::Base
  renders_one :body
  renders_one :subheading

  def initialize(id:, title:, hidden: false, data: {})
    @id = id
    @hidden = hidden
    @title = title
    @data = data
  end

  attr_reader :id, :title, :data

  def hidden?
    @hidden
  end
end
