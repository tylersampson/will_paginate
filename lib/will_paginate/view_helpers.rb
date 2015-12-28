# encoding: utf-8
require 'will_paginate/core_ext'
require 'will_paginate/i18n'
require 'will_paginate/deprecation'

module WillPaginate
  # = Will Paginate view helpers
  #
  # The main view helper is +will_paginate+. It renders the pagination links
  # for the given collection. The helper itself is lightweight and serves only
  # as a wrapper around LinkRenderer instantiation; the renderer then does
  # all the hard work of generating the HTML.
  module ViewHelpers
    class << self
      # Write to this hash to override default options on the global level:
      #
      #   WillPaginate::ViewHelpers.pagination_options[:page_links] = false
      #
      attr_accessor :pagination_options
    end

    # default view options
    self.pagination_options = Deprecation::Hash.new \
      :class          => 'pagination'.freeze,
      :previous_label => nil,
      :next_label     => nil,
      :inner_window   => 4, # links around the current page
      :outer_window   => 1, # links around beginning and end
      :link_separator => ' '.freeze, # single space is friendly to spiders and non-graphic browsers
      :param_name     => :page,
      :params         => nil,
      :page_links     => true,
      :container      => true

    label_deprecation = Proc.new { |key, value|
      "set the 'will_paginate.#{key}' key in your i18n locale instead of editing pagination_options" if defined? Rails
    }
    pagination_options.deprecate_key(:previous_label, :next_label, &label_deprecation)
    pagination_options.deprecate_key(:renderer) { |key, _| "pagination_options[#{key.inspect}] shouldn't be set globally" }

    include WillPaginate::I18n

    # Returns HTML representing page links for a WillPaginate::Collection-like object.
    # In case there is no more than one page in total, nil is returned.
    #
    # ==== Options
    # * <tt>:class</tt> -- CSS class name for the generated DIV (default: "pagination")
    # * <tt>:previous_label</tt> -- default: "« Previous"
    # * <tt>:next_label</tt> -- default: "Next »"
    # * <tt>:inner_window</tt> -- how many links are shown around the current page (default: 4)
    # * <tt>:outer_window</tt> -- how many links are around the first and the last page (default: 1)
    # * <tt>:link_separator</tt> -- string separator for page HTML elements (default: single space)
    # * <tt>:param_name</tt> -- parameter name for page number in URLs (default: <tt>:page</tt>)
    # * <tt>:params</tt> -- additional parameters when generating pagination links
    #   (eg. <tt>:controller => "foo", :action => nil</tt>)
    # * <tt>:renderer</tt> -- class name, class or instance of a link renderer (default in Rails:
    #   <tt>WillPaginate::ActionView::LinkRenderer</tt>)
    # * <tt>:page_links</tt> -- when false, only previous/next links are rendered (default: true)
    # * <tt>:container</tt> -- toggles rendering of the DIV container for pagination links, set to
    #   false only when you are rendering your own pagination markup (default: true)
    #
    # All options not recognized by will_paginate will become HTML attributes on the container
    # element for pagination links (the DIV). For example:
    #
    #   <%= will_paginate @posts, :style => 'color:blue' %>
    #
    # will result in:
    #
    #   <div class="pagination" style="color:blue"> ... </div>
    #
    def will_paginate(collection, options = {})
      # early exit if there is nothing to render
      return nil unless collection.total_pages > 1

      options = WillPaginate::ViewHelpers.pagination_options.merge(options)

      options[:previous_label] ||=
        will_paginate_translate(:previous_label) { '&#8592; Previous'.freeze }
      options[:next_label] ||=
        will_paginate_translate(:next_label) { 'Next &#8594;'.freeze }

      # get the renderer instance
      renderer = case options[:renderer]
      when nil
        raise ArgumentError, ":renderer not specified"
      when String
        klass = if options[:renderer].respond_to? :constantize then options[:renderer].constantize
          else Object.const_get(options[:renderer]) # poor man's constantize
          end
        klass.new
      when Class then options[:renderer].new
      else options[:renderer]
      end
      # render HTML for pagination
      renderer.prepare collection, options, self
      output = renderer.to_html
      output = output.html_safe if output.respond_to?(:html_safe)
      output
    end

    # Returns HTML representing link ref tags links for a
    # WillPaginate::Collection-like object.
    #
    # A port of something that is already in Kaminari:
    # https://github.com/amatsuda/kaminari/pull/200/files
    #
    # ==== Examples
    # Basic usage:
    #
    #   In head:
    #   <head>
    #     <title>My Website</title>
    #     <%= yield :head %>
    #   </head>
    #
    #   Somewhere in body:
    #   <% content_for :head do %>
    #     <%= pagination_link_tags @items %>
    #   <% end %>
    #
    #   #-> <link rel="next" href="http://example.com/items/page/3" />
    #       <link rel="prev" href="http://example.com/items/page/1" />
    #
    def pagination_link_tags(collection, params = {})
      output = []
      link = '<link rel="%s" href="%s" />'.freeze
      output << link % ['prev'.freeze,
        url_for(params.merge(page: collection.previous_page, only_path: false)
        )] if collection.previous_page
      output << link % ['next'.freeze,
        url_for(params.merge(page: collection.next_page, only_path: false))
        ] if collection.next_page
      output.join('\n'.freeze).html_safe
    end

    # Renders a message containing number of displayed vs. total entries.
    #
    #   <%= page_entries_info @posts %>
    #   #-> Displaying posts 6 - 12 of 26 in total
    #
    # The default output contains HTML. Use ":html => false" for plain text.
    def page_entries_info(collection, options = {})
      model = options[:model]
      model = collection.first.class unless model or collection.empty?
      model ||= 'entry'.freeze
      model_key = if model.respond_to? :model_name
                    model.model_name.i18n_key  # ActiveModel::Naming
                  else
                    model.to_s.underscore
                  end

      if options.fetch(:html, true)
        b, eb = '<b>'.freeze, '</b>'.freeze
        sp = '&nbsp;'.freeze
        html_key = '_html'.freeze
      else
        b = eb = html_key = ''.freeze
        sp = ' '.freeze
      end

      model_count = collection.total_pages > 1 ? 5 : collection.size
      defaults = ["models.#{model_key}".freeze]
      defaults << Proc.new { |_, opts|
        if model.respond_to? :model_name
          model.model_name.human(:count => opts[:count])
        else
          name = model_key.to_s.tr('_'.freeze, ' '.freeze)
          raise "can't pluralize model name: #{model.inspect}" unless name.respond_to? :pluralize
          opts[:count] == 1 ? name : name.pluralize
        end
      }
      model_name = will_paginate_translate defaults, :count => model_count

      if collection.total_pages < 2
        i18n_key = :"page_entries_info.single_page#{html_key}"
        keys = [:"#{model_key}.#{i18n_key}", i18n_key]

        will_paginate_translate keys, :count => collection.total_entries, :model => model_name do |_, opts|
          case opts[:count]
          when 0; "No #{opts[:model]} found"
          when 1; "Displaying #{b}1#{eb} #{opts[:model]}"
          else    "Displaying #{b}all#{sp}#{opts[:count]}#{eb} #{opts[:model]}"
          end
        end
      else
        i18n_key = :"page_entries_info.multi_page#{html_key}"
        keys = [:"#{model_key}.#{i18n_key}", i18n_key]
        params = {
          :model => model_name, :count => collection.total_entries,
          :from => collection.offset + 1, :to => collection.offset + collection.length
        }
        will_paginate_translate keys, params do |_, opts|
          %{Displaying %s #{b}%d#{sp}-#{sp}%d#{eb} of #{b}%d#{eb} in total} %
            [ opts[:model], opts[:from], opts[:to], opts[:count] ]
        end
      end
    end
  end
end
