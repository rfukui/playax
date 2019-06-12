ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require_relative '../lib/importers/pdf_ecad'


['app', 'lib'].each do |path|
    $:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', path)))
  end
