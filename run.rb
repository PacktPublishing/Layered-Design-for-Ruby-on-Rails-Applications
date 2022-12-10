require_relative "./lib/helpers"

using ChapterHelpers

ARGV.each do |filename|
  contents = File.read(filename)

  eval <<~CODE
    annotate(
      %q(#{contents}),
      filename
    )
  CODE
end
