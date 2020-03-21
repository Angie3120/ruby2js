module Ruby2JS
  class Converter

    # (xnode str hash) 

    # NOTE: xnode is a synthetic 

    handle :xnode do |nodename, *args|
      attrs = {}
      children = []

      args.each do |arg|
        if arg.type == :hash
          arg.children.each do |pair|
            name = pair.children[0].children[0]
            if name == :class and attrs[name]
              if attrs[name].type == :str and pair.children[1].type == :str
                attrs[name] = s(:str, pair.children[1].children[0] + ' ' + attrs[name].children[0])
              else
                attrs[name] = s(:send, s(:send, attrs[name], :+, 
                  s(:str, ' ')), :+, pair.children[1])
              end
            else
              attrs[name] = pair.children[1]
            end
          end
        elsif arg.type == :begin
          children += arg.children
        else
          children << arg
        end
      end

      put '<'
      put nodename

      attrs.each do |name, value|
        put ' '
        put name
        put '='
        if value.type == :str
          parse value
        else
          put '{'
          parse value
          put '}'
        end
      end

      if children.empty?
        put '/>'
      else
        put '>'
        put @nl unless children.length == 1 and children.first.type != :xnode

        children.each_with_index do |child, index|
          put @nl unless index == 0
          if child.type == :str
            put child.children.first
          elsif child.type == :xnode
            parse child
          else
            put '('
            parse child
            put '}'
          end
        end

        put @nl unless children.length == 1 and children.first.type != :xnode

        put '</'
        put nodename
        put ">"
      end
    end
  end
end
