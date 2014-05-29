require 'yaml'

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
  class Content
    attr_reader :seed, :meta, :exercises

    def initialize(data)
      @seed = data['seed'].to_i
      @meta = {
        :title => data['meta']['title'].to_s,
        :description => data['meta']['description'].to_s
      }
      @exercises = []
      data['exercises'].each do |ex|
        questions = []
        ex['questions'].each do |q|
          q = {
            'question' => q,
            'explanation' => ""
          } if q.is_a?(String)
          ans = q['question'].scan(/__+([^_]+)__+/).map do |m|
            m[0]
          end
          ques = q['question'].gsub(/(__+)[^_]+(__+)/, '\1\2')
          questions << {
            :question => ques,
            :answer => ans,
            :explanation => q['explanation']
          }
        end
        @exercises << {
          :subject => ex['subject'],
          :questions => questions,
        }
      end
    end

    def correct?(eidx, qidx, ans)
      b = true
      @exercises[eidx][:questions][qidx][:answer].each_with_index do |a, idx|
        b = false unless /^\(.+\)$/ =~ a || a == ans[idx]
      end
      b
    end

    def self.load_yaml(io)
      data = YAML.load(io)
      self.new(data)
    end
  end

  class Runner
    def self.run(content)
      puts
      puts ("Ex. %d" % [content.seed]).bold
      puts content.meta[:title].indent(4)
      puts
      puts content.meta[:description].indent(4)
      puts

      results = []

      content.exercises.each.with_index do |ex, eidx|
        section = eidx + 1
        puts ("%d.%d" % [content.seed, section]).bold
        puts ex[:subject].indent(4)
        puts
        nq = ex[:questions].length
        nc = 0;
        ex[:questions].each.with_index do |q, qidx|
          puts "%d. %s" % [qidx + 1, q[:question]]
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

          if content.correct?(eidx, qidx, ans)
            res = 'Correct'.green
            nc += 1
          else
            res = 'Incorrect'.red
          end
          puts "#{res}: #{q[:answer].join(", ")}"
          puts
          unless q[:explanation].empty?
            puts "#{q[:explanation]}".indent(4)
            puts
          end
        end
        results << { :section => section, :correct => nc, :divisor => nq }
        puts
      end

      unless results.empty?
        puts "Results:".bold
        puts

        nc = 0
        nq = 0
        results.each do |rs|
          puts ("%d.%d - %.2f %d/%d" % [
            content.seed,
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

      else
        puts "Nothing to do".bold
        puts
      end
    end
  end
end
