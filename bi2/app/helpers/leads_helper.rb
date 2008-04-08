module LeadsHelper
  def clean_number num
    unless num.nil?
      num.lstrip!    # Remove leading white space
      num.gsub!(/-/,'')
      unless num[0] == '+'
        if num[0] != '1'
          num.insert(0, '1')
        end
      end
    end
    num
  end
end
