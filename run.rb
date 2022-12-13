require_relative "./lib/helpers"

using ChapterHelpers

ARGV.each do |filename|
  contents = File.read(filename)

  eval <<~CODE # rubocop:disable Security/Eval, Style/EvalWithLocation
    annotate(
      %q(#{contents}),
      filename
    )
  CODE
end
