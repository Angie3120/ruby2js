module Ruby2JS
  class Converter

    # (ivasgn :@a
    #   (int 1))

    handle :ivasgn do |var, expression=nil|
      multi_assign_declarations if @state == :statement

      put "#{ var.to_s.sub('@', 'this.' + (underscored_private ? '_' : '#')) }"
      if expression
        put " = "; parse expression
      end
    end
  end
end
