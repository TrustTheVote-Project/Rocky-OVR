class CsvFormatter
  def self.wrap
    lines = []
    yield lines
    lines.map { |line| process_line(line) }.join("\n")
  end

  def self.rename_array_item(arr, from, to)
    arr.index(from).tap do |index|
      arr[index] = to if index
    end
  end

  def self.process_line(line)
    quote(
      line
        .map{ |v| format(v) }
        .map{ |v| escape(v) }
    )
  end

  def self.format(value)
    case
      when value.nil?
        ''
      when value.is_a?(Time)
        value.strftime('%Y-%m-%d %H:%M:%S')
      when tmp = [false, true].index(value)
        tmp.to_s
      else
        value.to_s
    end
  end

  def self.escape(value)
    value.gsub('"', '""')
  end

  def self.quote(array)
    '"' + array.join('","') + '"'
  end

  private_class_method :process_line, :format, :quote, :escape

end
