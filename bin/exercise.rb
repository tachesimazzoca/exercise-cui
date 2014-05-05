#!/usr/bin/env ruby

require 'yaml'
require 'open-uri'

class String
  def colorize(code)
    "\e[#{code}m#{self}\e[0m"
  end

  def bold
    colorize(1)
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def indent(n)
    sp = " " * n
    s = ""
    self.lines do |ln|
      s << (sp + ln)
    end
    s
  end
end

module Exercise
  class Unit
    attr_reader :number, :contents, :exercises

    def initialize(data)
      @number = data['number'].to_i
      @contents = {
        :title => data['title'].to_s,
        :description => data['description'].to_s
      }
      @exercises = []
      data['exercises'].each do |ex|
        questions = []
        ex['questions'].each do |q|
          ans = q.scan(/__+([^_]+)__+/).map do |m|
            m[0]
          end
          ques = q.gsub(/(__+)[^_]+(__+)/, '\1\2')
          questions << {
            :question => ques,
            :answer => ans,
          }
        end
        @exercises << {
          :subject => ex['subject'],
          :questions => questions
        }
      end
    end

    def self.load_yaml(io)
      data = YAML.load(io)
      self.new(data)
    end
  end

  class Runner
    def self.run(unit)
      puts
      puts ("Unit %d" % [unit.number]).bold
      puts unit.contents[:title].indent(4)
      puts
      puts unit.contents[:description].indent(4)
      puts

      results = []

      unit.exercises.each.with_index do |ex, exi|
        section = exi + 1
        puts ("%d.%d" % [unit.number, section]).bold
        puts ex[:subject].indent(4)
        puts
        nq = ex[:questions].length
        nc = 0;
        ex[:questions].each.with_index do |q, qni|
          puts "%d. %s" % [qni + 1, q[:question]]
          ans = []
          q[:answer].each do |a|
            begin
              ans << STDIN.gets.chomp
            rescue Interrupt
              puts
              return
            rescue Exception => e
              raise e
            end
          end

          if q[:answer] == ans
            res = 'Correct'.green
            nc += 1
          else
            res = 'Incorrect'.red
          end
          puts "#{res}: #{q[:answer].join(", ")}"
          puts
        end
        results << { :section => section, :correct => nc, :divisor => nq }
        puts
      end

      puts "Results:".bold
      puts

      nc = 0
      nq = 0
      results.each do |rs|
        puts ("%d.%d - %.2f %d/%d" % [
          unit.number,
          rs[:section],
          100 * rs[:correct] / rs[:divisor],
          rs[:correct],
          rs[:divisor]
        ]).indent(2)
        nc += rs[:correct]
        nq += rs[:divisor]
      end

      puts
      puts "Total %.2f" % [100 * nc / nq]
    end
  end
end

module Exercise
  Runner.run(Unit.load_yaml(open(ARGV[0])))
end
