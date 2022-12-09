# frozen_string_literal: true

module ChapterHelpers
  class << self
    def extensions = @extensions ||= Hash.new { |h, k| h[k] = [] }
    def extend!(type, obj) = extensions[type].each { obj.instance_eval(&_1) }
  end

  refine Kernel do
    def gems(&block)
      ChapterHelpers.extensions[:gemfile] << block
    end

    def schema(&block)
      ChapterHelpers.extensions[:schema] << block
    end
  end
end
