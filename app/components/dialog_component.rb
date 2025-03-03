# frozen_string_literal: true

class DialogComponent < ViewComponent::Base
  def initialize(dialog_id:, stimulus_target:)
    @dialog_id = dialog_id
    @stimulus_target = stimulus_target
  end

  renders_one :header
  renders_one :main
  renders_one :footer

  attr_reader :dialog_id, :stimulus_target

  def header_id
    "#{dialog_id}-modal-header"
  end
end
