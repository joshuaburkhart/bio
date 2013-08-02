#!/usr/bin/ruby

#Usage: 3d_photoperiod_plot_generator.rb <YAML cfg file> <ERB template file>

#Example: 3d_photoperiod_plot_generator.rb photoperiod_cfg.3d.yml 3d_plot.oct.erb

require 'yaml'
YAML::ENGINE.yamler = 'syck'
require 'erb'

cfgFileName = ARGV[0]
plotterFileName = ARGV[1]

puts "Consume configuration..."
cfgData = YAML.load_file(cfgFileName)
experiment = cfgData['experiment']

xFileName = cfgData['xfile']['name']
yFileName = cfgData['yfile']['name']
zFileName = cfgData['zfile']['name']

main_lab    = cfgData['main_lab']
xlab_left   = cfgData['xlab_left']
xlab_right  = cfgData['xlab_right']
ylab_top    = cfgData['ylab_top']
ylab_bottom = cfgData['ylab_bottom']
zlab_front  = cfgData['zlab_front']
zlab_back   = cfgData['zlab_back']
3d_dat_file = "intsct.123" #default

puts "Write plotter..."
plotterRenderer = ERB.new(File.read(plotterFileName))
plotter = "plot_#{xFileName}-#{yFileName}-#{zFileName}.oct"
plotterHandl = File.open(plotter,"w")
plotterHandl.puts(plotterRenderer.result())
plotterHandl.close()

puts "Filtering insignificantly differentially expressed sequences out..."
%x(ma_qual.rb #{xFileName} 0.05 false)
%x(ma_qual.rb #{yFileName} 0.05 false)
%x(ma_qual.rb #{zFileName} 0.05 false)

xFileQual = "#{xFileName}.qual.csv"
yFileQual = "#{yFileName}.qual.csv"
zFileQual = "#{zFileName}.qual.csv"

xFileStripped = "#{xFileName}.stripped"
yFileStripped = "#{yFileName}.stripped"
zFileStripped = "#{zFileName}.stripped"

puts "Remove header..."
%x(tail -n+2 #{xFileQual} > #{xFileStripped})
%x(tail -n+2 #{yFileQual} > #{yFileStripped})
%x(tail -n+2 #{zFileQual} > #{zFileStripped})

xFileUnique = "#{xFileStripped}.unique"
yFileUnique = "#{yFileStripped}.unique"
zFileUnique = "#{zFileStripped}.unique"

combinedCoords = "#{xFileName}-#{yFileName}-#{zFileName}.origin"
intsct = "#{xFileStripped}-#{yFileStripped}-#{zFileStripped}.intsct.csv"

if(!File.zero?(xFileStripped) && !File.zero?(yFileStripped) && !File.zero?(zFileStripped))
    puts "Join on common identifying attribute..."
    %x(ma_intersect.rb #{xFileStripped} #{yFileStripped} #{zFileStripped})
end

if(File.exist?(intsct) && !File.zero?(intsct))
    puts "Extract values used for coordinates..."
    %x(coord_extractor.sh #{intsct} 2 3)

    xCoords = "#{intsct}.1"
    yCoords = "#{intsct}.2"
    zCoords = "#{intsct}.3"

    if(cfgData['xfile']['reverse'])
        puts "Reversing x values..."
        %x(reverse_vals.sh #{xCoords})
        xCoords = "#{xCoords}.reverse"
    end

    if(cfgData['yfile']['reverse'])
        puts "Reversing y values..."
        %x(reverse_vals.sh #{yCoords})
        yCoords = "#{yCoords}.reverse"
    end

    if(cfgData['zfile']['reverse']
       puts "Reversing z values..."
       %x(reverse_vals.sh #{zCoords})
       zCoords = "#{zCoords}.reverse"
    end

    combinedCoords = "#{xCoords}-#{yCoords}-#{zCoords}.combined"

    puts "Combine values..."
    %x(paste #{xCoords} #{yCoords} #{zCoords} > #{combinedCoords})

    puts "Produce plot for +/- sequences..."
    %x(Rscript #{plotter} #{combinedCoords})
    %x(mv Rplots.pdf intersect_only_plot.pdf)

    puts "Filter sequences uniquely expressed in each assay..."
    %x(filter_unique.sh #{xFileStripped} #{intsct})
    %x(filter_unique.sh #{yFileStripped} #{intsct})
end

puts "Move plots and data into separate directory..."
%x(mkdir -p #{experiment})
%x(mv *.combined #{experiment}/)
%x(mv *.zs #{experiment}/)
%x(mv *.pdf #{experiment}/)
%x(mv *.R #{experiment}/)
%x(mv *.origin #{experiment}/)

intermediate_dir = "#{experiment}_intermediate_files"

puts "Move intermediate files into separate directory..."
%x(mkdir -p #{intermediate_dir})
%x(mv #{xFileName}.* #{intermediate_dir}/)
%x(mv #{yFileName}.* #{intermediate_dir}/)
%x(mv #{zFileName}.* #{intermediate_dir}/)

puts "done."