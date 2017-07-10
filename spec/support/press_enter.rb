module PressEnter

  def press_enter(receiver)
    send_key(receiver, :enter)
  end

  def send_key(receiver, key)
    selector = "##{receiver}" if receiver.kind_of?(String) or receiver.kind_of?(Symbol)
    selector ||= "##{receiver[:in]}" if receiver.kind_of?(Hash)
    raise 'no selector given' unless selector

    find(:css, selector).native.send_key(key)
  end

end