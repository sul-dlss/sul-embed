# frozen_string_literal: true

require 'open3'
require 'fileutils'

SCREENSHOT_BASELINE_DIR = Rails.root.join('spec/screenshots')
SCREENSHOT_ACTUAL_DIR = Rails.root.join('tmp/screenshots')
PIXELMATCH = 'pixelmatch'

RSpec::Matchers.define :match_screenshot do |name, threshold: 0.1|
  attr_reader :baseline_path, :actual_path, :diff_path, :diff_output

  match do |page|
    @baseline_path = SCREENSHOT_BASELINE_DIR.join("#{name}.png")
    @actual_path   = SCREENSHOT_ACTUAL_DIR.join("#{name}.png")
    @diff_path     = SCREENSHOT_ACTUAL_DIR.join("#{name}_diff.png")

    FileUtils.mkdir_p(@baseline_path.dirname)
    FileUtils.mkdir_p(@actual_path.dirname)

    page.save_screenshot(@actual_path.to_s)

    unless @baseline_path.exist?
      FileUtils.cp(@actual_path, @baseline_path)
      @baseline_created = true
      return true
    end

    @diff_output, status = Open3.capture2e(
      'npm', 'exec',
      PIXELMATCH,
      @baseline_path.to_s,
      @actual_path.to_s,
      @diff_path.to_s,
      threshold.to_s
    )

    status.success?
  end

  failure_message do
    if @baseline_created
      "New baseline screenshot saved to #{baseline_path}. " \
        'Commit this file to establish the visual baseline.'
    else
      "Screenshot '#{name}' does not match the baseline.\n  " \
        "Baseline : #{baseline_path}\n  " \
        "Actual   : #{actual_path}\n  " \
        "Diff     : #{diff_path}\n  " \
        "#{diff_output.to_s.strip}\n" \
        'If the change is intentional, delete the baseline and re-run to create a new one.'
    end
  end

  failure_message_when_negated do
    "Expected screenshot '#{name}' not to match the baseline at #{baseline_path}, but it did."
  end

  description { "match screenshot '#{name}'" }
end
