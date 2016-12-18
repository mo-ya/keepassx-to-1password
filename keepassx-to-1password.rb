#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'yaml'
require 'pp'
require 'optparse'
require 'logger'
require 'rexml/document'

class KeepassxTo1Password

  Version = "0.1"

  def initialize(opts = {})

    # Parse Command Line Arguments
    @opts = {
      :argv       => [],
    }.merge(opts)

    # Arguments are received as input files by default
    @files = []

    # Set default behavior
    @modes =
      {
      :print => true,
      :output => false,
      :log => "#{$PROGRAM_NAME}".sub(/\.rb$/, '.log'),
      :debug => false,
    }

    OptionParser.new do |parser|
      parser.version = Version
      parser.on("-p", "--print", "Print mode (default)") {|v| @modes[:print] = v}
      parser.on("-o", "--outout PATH", "Output file path") {|v| @modes[:output] = v}
      parser.on("-l", "--log PATH", "log file (default: #{@modes[:log]})") {|v| @modes[:log] = v}
      parser.on("-D", "--debug", "DEBUG mode") {|v| @modes[:debug] = v}
      parser.banner = "Usage: #{$PROGRAM_NAME} [options] <XML file>\n\nOptions: "
      @files = parser.parse!(@opts[:argv])
      if @files.size < 1
        print parser.help
        exit 1
      end
    end

    print "   [DEBUG MODE]\n" if @modes[:debug]
    
    if @modes[:debug]
      debug_pp "@files", @files
      debug_pp "@modes", @modes
    end
    
  end

  def debug_pp(name, obj)
    if @modes[:debug]
      pobj = { name => obj }
      pp pobj
    end
  end

  def load_xml
    file = @files[0]

    lines = Array.new
      
    STDERR.print  "  [Info] Convert <br/> to \\n in \"#{file}\" ... "
    open(file) {|file|
      while l = file.gets
        lines.push l.gsub(/<br\/>/, "\n").gsub(/\"/, "\"\"")
      end
    }
    xml_converted = lines.join("\n")
    STDERR.puts "done."

    STDERR.print  "  [Info] \"#{file}\" is loaded ... "
    xml = REXML::Document.new(xml_converted)
    STDERR.puts "done."
    return xml
  end

  def parse_xml
    xml = load_xml
    one_password_csv_lines = Array.new
    xml.elements.each('database/group')  { |group|
      group_name =  group.elements['title'].text
#      if group_name =~ /^(ﾊﾞｯｸｱｯﾌﾟ|バックアップ|Backup)$/i
#        print "group_name=\"#{group_name}\" is ignored.\n"
#        next
#      end
      group.elements.each('entry') { |entry|
        title = entry.elements['title'].text
        url = entry.elements['url'].text
        username = entry.elements['username'].text
        password = entry.elements['password'].text
        comment = entry.elements['comment'].text

        one_password_csv_lines.push "\"#{title}: #{group_name}\",\"#{url}\",\"#{username}\",\"#{password}\",\"#{comment}\"\n"
      }
    }
    return one_password_csv_lines.join("\n")
  end

  def print_stdout
    print parse_xml
  end

  def print_stdout_debug
    xml = load_xml
    puts "#### loaded xmls ####"
    xml.elements.each('database/group')  { |group|
      print "Group Title: "
      pp group.elements['title'].text
      group.elements.each('entry') { |entry|
        print "  Entry Title: "
        pp entry.elements['title'].text
        ['username', 'password', 'url'].each{ |name|
          print "    #{name}: "
          pp entry.elements[name].text
        }
        pp entry.elements[5].text
        pp entry.elements[6].text
        entry.elements.each('comment') { |comment|
          print "    comment: "
          pp comment.text
        }
      }
    }
  end
  
  def output
    return false unless @modes[:output]
    output_file = @modes[:output]
    csv = parse_xml
    STDERR.print "  [Info] \"#{output_file}\" is generated ... "
    f = open(output_file,'w')
    f.puts(csv)
    f.close
    STDERR.puts "done."
    return true
  end
  
  def run
    if @modes[:output]
      output
    else
      print_stdout
    end
  end
end
KeepassxTo1Password.new({:argv => ARGV}).run if $0 == __FILE__
