# -*- coding: utf-8 -*-

require 'aws-sdk-core'
require 'term/ansicolor'
require 'net/http'

Aws.config[:region] = 'ap-northeast-1'
@color = Term::ANSIColor
@sample_paths = []
ARGV.each do |path|
  @sample_paths << path
end

if @sample_paths.empty?
  puts 'Usage:'
  puts ' $ ruby check_cf.rb <path>....'
  puts " ex. $ ruby check_cf.rb '/images/a.jpg' '/images/b.jpg'"
  exit
end

def check_res(host)
  @sample_paths.each do |path|
    res = Net::HTTP.get_response(host, path)
    if res.code == "200"
      puts @color.green "#{host}#{path} got #{res.code} ok."
    else
      puts @color.red "#{host}#{path} got #{res.code}. Something wrong!!"
    end
  end
end

cloudfront = Aws::CloudFront.new
cloudfront.list_distributions.distribution_list.items.each do |item|
  check_res(item.domain_name)
  item.origins.items.each do |it|
    check_res(it.domain_name)
  end
end
