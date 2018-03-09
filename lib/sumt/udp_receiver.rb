# frozen_string_literal: true

#———————————————————————————————————————————————————————————————————————————————
# Copyright 2018 MSP-Greg
# License: The MIT License (MIT)
#———————————————————————————————————————————————————————————————————————————————

=begin 
ruby E:/GitHub/SUMT/lib/sumt/udp_receiver.rb
=end

require 'socket'

# Run with stand-alone ruby, starts a UDP socket to receive data from SUMT.
#
module UDPReceiver

  def self.run
    skt = UDPSocket.new
    skt.bind '127.0.0.1', 50_000
    loop do
      str = skt.recvfrom(2048)[0]
      $stdout.write str
    end
  end
end
UDPReceiver.run
