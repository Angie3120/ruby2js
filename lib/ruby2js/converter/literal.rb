module Ruby2JS
  class Converter

    # (int 1)
    # (float 1.1)
    # (str "1"))

    handle :str do |value|
      put value.inspect
    end

    handle :int, :float do |value|
      put number_format(value)
    end

    handle :octal do |value|
      put '0' + number_format(value.to_s(8))
    end

    def number_format(number)
      return number.to_s unless es2021
      parts = number.to_s.split('.')
      parts[0] = parts[0].gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1_")
      parts[1] = parts[1].gsub(/(\d\d\d)(?=\d)/, "\\1_") if parts[1]
      parts.join('.')
    end
  end
end
