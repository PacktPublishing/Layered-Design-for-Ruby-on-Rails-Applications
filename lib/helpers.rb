# frozen_string_literal: true

require "rouge"
require "tempfile"
require "ripper"

module ChapterHelpers
  using(Module.new do
    refine String do
      def truncate(len = 50)
        return self if size <= 30

        self[0..25] + "..." + self[-1..(size)]
      end

      def red = "\e[31m#{self}\e[0m"
    end
  end)

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

    def routes(&block)
      ChapterHelpers.extensions[:routes] << block
    end

    # Prints the code and executes it,
    # paragraph by paragraph
    def annotate(code, path)
      bind = TOPLEVEL_BINDING.eval("binding")

      formatter = Rouge::Formatters::Terminal256.new
      lexer = Rouge::Lexers::Ruby.new

      paragraphs = code.split(/^\s*$/)
      line_num = 1

      original_stdout = $stdout.dup
      file = nil
      buffer = []

      paragraphs.each.with_index do |paragraph, i|
        file&.close
        file&.unlink

        buffer << paragraph
        paragraph = buffer.join("\n")

        # Make sure that paragraph is valid Ruby code.
        # If syntax is invalid, then this is partial code,
        # add to buffer and continue
        next unless Ripper.sexp_raw(paragraph)

        # Syntax is valid, flush buffer
        buffer.clear

        file = Tempfile.new("#{path}_#{i}")
        $stdout.reopen(file, "w")
        $stdout.sync = true

        exception = nil
        result =
          begin
            bind.eval paragraph, path, line_num
          rescue => err
            exception = err
            nil
          end

        next if paragraph.include?(%q(require_relative "./prelude"))

        ignore = paragraph.match(/# :ignore:(output)?/)
        ignore_output = ignore

        if ignore && ignore[1]
          ignore_output = true
          ignore = nil
        end

        ignore_output = ignore_output ||
          paragraph.match?(/^(class|module|def\s|require \")/)

        paragraph.sub!(/# :ignore:(output)?/, "")

        source = paragraph.chomp

        unless result.nil? || ignore_output
          result = result.to_ary if result.respond_to?(:to_ary)
          source += " #=> #{result.inspect.truncate}"
        end

        unless ignore
          formatted = formatter.format(lexer.lex(source))
          original_stdout.puts(formatted)
        end

        sleep 0.2

        unless ignore_output
          file.rewind
          output = file.read.strip

          unless output.empty?
            output = output.lines
            original_stdout.puts("\n↳ #{output.first}#{output[1..].map { "  " + _1 }.join}")
          end

          sleep 0.2
        end

        if exception
          original_stdout.puts("\n 💥 #{exception.class.name}: #{exception.message}".red)
        end

        line_num += paragraph.lines.size
      end

      # Let SyntaxError bubble
      bind.eval(buffer.join, path) unless buffer.empty?
    ensure
      $stdout = original_stdout
    end
  end
end

# Add #render to binding to render ERB templates within the context
# of the current scope
class Binding
  def render(erb_str)
    locals = local_variables.each.with_object({}) do |lvar, acc|
      acc[lvar] = local_variable_get(lvar)
      acc
    end

    puts ApplicationController.render(
      locals:,
      inline: erb_str
    )
  end
end
