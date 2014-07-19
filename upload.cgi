#!/usr/bin/ruby --

require 'cgi'

print "Content-type: text/html\n\n"

cgi = CGI.new
value = cgi.params['file'][0]
puts "file name:" << value.origial_filename << "<br/>"
puts vale.read