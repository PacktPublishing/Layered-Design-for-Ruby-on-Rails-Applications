# frozen_string_literal: true

# Rouge is only installed during the first run,
# so we should ignore the failure
begin
  require "rouge"
rescue LoadError
end

require "tempfile"
require "ripper"

module ChapterHelpers
  TRUNCATE_WIDTH = 100

  using(Module.new do
    refine String do
      def truncate(len = TRUNCATE_WIDTH)
        return self if size <= len

        self[0..(len - 5)] + "..." + self[-1..(size)]
      end

      def red = "\e[31m#{self}\e[0m"
    end
  end)

  class << self
    def extensions = @extensions ||= Hash.new { |h, k| h[k] = [] }

    def extend!(type, obj) = extensions[type].each { obj.instance_eval(&_1) }
  end

  class RackResponseDecorator < SimpleDelegator
    def inspect = __getobj__.status.inspect

    # Make it posssible to access flash from response
    def flash
      headers["rails.flash"]
    end
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

    def configure(&block)
      ChapterHelpers.extensions[:config] << block
    end

    def request(path, params: {}, method: :get, cookies: {}, env: {}, headers: {})
      request_env = Rack::MockRequest.env_for(
        "http://localhost:3000#{path}",
        params:,
        method:
      )

      env["HTTP_COOKIE"] = cookies.map { |k, v| "#{k}=#{v}" }.join(";") unless cookies.empty?
      env["HTTP_X_CHAPTER"], env["HTTP_X_EXAMPLE"] = caller_locations(1, 3).find do |cl|
        cl.path.match(/\bChapter(\d+)\/(\d+)-/)
      end.then { Regexp.last_match&.captures }

      headers&.each { request_env["HTTP_#{_1.upcase.tr("-", "_")}"] = _2 }

      request_env.merge!(env) unless env.empty?

      response = Rails.application.call(request_env)
      # Make flash accesible on the response object
      response[1]["rails.flash"] = ActionDispatch::Request.new(request_env.merge({"HTTP_COOKIE" => response[1]["Set-Cookie"]})).flash.to_h
      RackResponseDecorator.new(ActionDispatch::Response.new(*response))
    end

    def get(path, **options)
      request(path, **options)
    end

    def patch(path, **options)
      request(path, method: :patch, **options)
    end

    def post(path, **options)
      request(path, method: :post, **options)
    end

    def delete(path, **options)
      request(path, method: :delete, **options)
    end

    def url_for(...) = Rails.application.routes.url_helpers.url_for(...)

    # Prints the code and executes it,
    # paragraph by paragraph
    def annotate(code, path)
      bind = TOPLEVEL_BINDING.eval("binding")

      if defined?(::Rouge)
        formatter = Rouge::Formatters::Terminal256.new
        lexer = Rouge::Lexers::Ruby.new
      end

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

        debugging = paragraph.match(/\bdebugger\b/)

        if debugging
          $stdout = original_stdout
        else
          file = Tempfile.new("#{path}_#{i}")
          $stdout.reopen(file, "w")
          $stdout.sync = true
        end

        exception = nil
        result =
          begin
            bind.eval paragraph, path, line_num
          rescue => err
            exception = err
            nil
          end

        if paragraph.include?('require_relative "./prelude"')
          raise exception if exception
          next
        end

        ignore = paragraph.match(/# :ignore:(output)?/)
        ignore_output = ignore

        if ignore && ignore[1]
          ignore_output = true
          ignore = nil
        end

        ignore_output ||= paragraph.match?(/^(class|module|def\s|require "|RSpec\.describe)/)

        paragraph.sub!(/# :ignore:(output)?/, "")

        source = paragraph.chomp

        unless result.nil? || ignore_output
          result = result.to_ary if result.respond_to?(:to_ary)
          source += " #=> #{result.inspect.truncate}"
        end

        unless ignore
          formatted =
            if formatter
              formatter.format(lexer.lex(source))
            else
              source
            end

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

  refine Object do
    def remove_const(name)
      Object.send(:remove_const, name)
    end
  end

  refine Binding do
    # Add #render to binding to render ERB templates within the context
    # of the current scope
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
end
