#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'scratchrsc'
require 'rubygems'
require 'watir'
require 'watir-webdriver'

class PrintRSC < RSCWatcher
  def initialize
    super
    broadcast 'goto'
    broadcast 'input'
    broadcast 'click'
    broadcast 'flash'
    @url = 'http://scratch.mit.edu/'
    @browser = Watir::Browser.new :chrome
    @index = 0
    @text = ''
  end

  def on_sensor_update(name, value) # when a variable or sensor is updated
    if name == "url" && value != '0'
      if value =~ /^http:\/\//
        @url = value
      else
        @url = "http://#{value}"
      end
    end
    if name == "index"
      @index = value.to_i
    end
    if name == "text"
      @text = value
    end
  end

  def broadcast_goto
    puts "goto #{@url}"
    @browser.goto @url
  end

  def broadcast_input
    puts "input index:#{@index}, text:#{@text}"
    @browser.text_field(:index, @index).value = @text.force_encoding('UTF-8')
  end

  def broadcast_click
    puts "click index:#{@index}"
    @browser.button(:index, @index).click
  end

  def broadcast_flash
    puts "flash index:#{@index}"
    @browser.text_field(:index, @index).flash
  end

  def on_broadcast(name)
  end
end

begin
  watcher = PrintRSC.new # you can provide the host as an argument
  watcher.sensor_update "connected", "1"
  loop { watcher.handle_command }
rescue Errno::ECONNREFUSED
  puts "\033[31m\033[1mError: Scratch may not be running or remote sensor connections are not enabled.\033[00m\n"
rescue => e
  puts "\033[31m\033[1mError: #{e.message}\033[00m\n"
end
