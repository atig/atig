# This is a memory profiler for Ruby. Once started, it runs in a thread in the
# background, periodically inspecting Ruby's ObjectSpace to look for new
# objects and printing a count of objects added and removed since the previous
# cycle.
#
# To use the profiler, do something like this:
#
#   require 'memory_profiler'
#
#   MemoryProfiler.start
#
# The profiler will write logs to ./log/memory_profiler.log.
#
# If you start MemoryProfiler with the ':string_debug => true' option, then it
# will dump a list of all strings in the app into the log/ directory after
# each cycle.  You can then use 'diff' to spot which strings were added
# between runs.
class MemoryProfiler
  DEFAULTS = {:delay => 10, :string_debug => false}

  def self.start(opt={})
    opt = DEFAULTS.dup.merge(opt)

    Thread.new do
      prev = Hash.new(0)
      curr = Hash.new(0)
      curr_strings = []
      delta = Hash.new(0)

      file = File.open("log/memory_profiler.#{Time.now.to_i}.log",'w')

      loop do
        begin
          GC.start
          curr.clear

          curr_strings = [] if opt[:string_debug]

          ObjectSpace.each_object do |o|
            curr[o.class] += 1 #Marshal.dump(o).size rescue 1
            if opt[:string_debug] and o.class == String
              curr_strings.push o
            end
          end

          if opt[:string_debug]
            File.open("log/memory_profiler_strings.log.#{Time.now.to_i}",'w') do |f|
              curr_strings.sort.each do |s|
                f.puts s
              end
            end
            curr_strings.clear
          end

          delta.clear
          (curr.keys + delta.keys).uniq.each do |k,v|
            delta[k] = curr[k]-prev[k]
          end

          file.puts "Top 20: #{Time.now}"
          delta.sort_by { |k,v| -v.abs }[0..19].sort_by { |k,v| -v}.each do |k,v|
            file.printf "%+5d: %s (%d)\n", v, k.name, curr[k] unless v == 0
          end
          file.flush

          delta.clear
          prev.clear
          prev.update curr
          GC.start
        rescue Exception => err
          STDERR.puts "** memory_profiler error: #{err}"
        end
        sleep opt[:delay]
      end
    end
  end
end
