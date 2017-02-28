module Liquid
  class Variable
    alias_method :render_orig, :render

    def render(context)
      obj = render_orig(context)
      return obj if @filters.any?{|filter| ['permalink', 'nowrap'].include?(filter.first) }
      return obj unless @filters.any?{|filter| filter.first == 'editable' }

      if @name.kind_of?(Liquid::VariableLookup)
        var = context.find_variable(context.evaluate(@name.name))
        if var.kind_of?(DataObject) && var.respond_to?(:__MODEL__)
          obj = "<span class=\"tt-span\" data-model=\"#{var.__MODEL__}\" data-instance=\"#{var.__INSTANCE__}\">#{obj}</span>"
        elsif var.kind_of?(Hash) && var.has_key?('__MODEL__')
          obj = "<span class=\"tt-span\" data-model=\"#{var['__MODEL__']}\" data-instance=\"#{var['__INSTANCE__']}\">#{obj}</span>"
        end
      end

      obj
    end
  end
end

module Jekyll
  module NoWrap
    def nowrap(data, *args)
      data
    end
  end
end
Liquid::Template.register_filter(Jekyll::NoWrap)

module Jekyll
  module Editable
    def editable(data, *args)
      data
    end
  end
end
Liquid::Template.register_filter(Jekyll::Editable)
