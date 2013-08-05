#!/usr/bin/ruby

#Usage: 2d_photoperiod_plot_generator.rb <YAML cfg file> <ERB template file>

#Example: 2d_photoperiod_plot_generator.rb photoperiod_cfg.yml photoperiod_plotter.R.erb

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

main_lab = cfgData['main_lab']
xlab_pos = cfgData['xlab_pos']
xlab_neg = cfgData['xlab_neg']
ylab_pos = cfgData['ylab_pos']
ylab_neg = cfgData['ylab_neg']

puts "Write plotter..."
plotterRenderer = ERB.new(File.read(plotterFileName))
plotter = "plot_#{xFileName}-#{yFileName}.R"
plotterHandl = File.open(plotter,"w")
plotterHandl.puts(plotterRenderer.result())
plotterHandl.close()

puts "Filtering insignificantly differentially expressed sequences out..."
%x(ma_qual.rb #{xFileName} 0.05 false)
%x(ma_qual.rb #{yFileName} 0.05 false)

xFileQual = "#{xFileName}.qual.csv"
yFileQual = "#{yFileName}.qual.csv"

xFileStripped = "#{xFileName}.stripped"
yFileStripped = "#{yFileName}.stripped"

puts "Remove header..."
%x(tail -n+2 #{xFileQual} > #{xFileStripped})
%x(tail -n+2 #{yFileQual} > #{yFileStripped})

xFileUnique = "#{xFileStripped}.unique"
yFileUnique = "#{yFileStripped}.unique"

combinedCoords = "#{xFileName}-#{yFileName}.origin"
intsct = "#{xFileStripped}-#{yFileStripped}.intsct.csv"

if(!File.zero?(xFileStripped) && !File.zero?(yFileStripped))
    puts "Join on common identifying attribute..."
    %x(ma_intersect.rb #{xFileStripped} #{yFileStripped})
end

if(File.exist?(intsct) && !File.zero?(intsct))
    puts "Extract values used for coordinates..."
    %x(coord_extractor.sh #{intsct} 2)

    xCoords = "intsct.1"
    yCoords = "intsct.2"

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

    combinedCoords = "intsct.12"

    puts "Combine values..."
    %x(paste #{xCoords} #{yCoords} > #{combinedCoords})

    puts "Produce plot for +/- sequences..."
    %x(Rscript #{plotter} #{combinedCoords})
    %x(mv Rplots.pdf intersect_only_plot.pdf)

    puts "Filter sequences uniquely expressed in each assay..."
    %x(filter_unique.sh #{xFileStripped} #{intsct})
    %x(filter_unique.sh #{yFileStripped} #{intsct})
else
    combinedCoordsHandl = File.open(combinedCoords,"w")
    combinedCoordsHandl.puts("0 0")
    combinedCoordsHandl.close()
    %x(cat #{xFileStripped} | awk -F' ' '{print $2}' > #{xFileUnique})
    %x(cat #{yFileStripped} | awk -F' ' '{print $2}' > #{yFileUnique})
end

plot_args = combinedCoords

if(File.exist?(xFileUnique) && !File.zero?(xFileUnique))
    if(cfgData['xfile']['reverse'])
        puts "Reversing x values..."
        %x(reverse_vals.sh #{xFileUnique})
        xFileUnique = "#{xFileUnique}.reverse"
    end

    puts "Filling unique x coords with trailing 0's..."
    %x(add_zs.sh 1 #{xFileUnique})
    xFileCoordsZs = "#{xFileUnique}.zs"
    plot_args << " " << xFileCoordsZs
end

if(File.exist?(yFileUnique) && !File.zero?(yFileUnique))
    if(cfgData['yfile']['reverse'])
        puts "Reversing y values..."
        %x(reverse_vals.sh #{yFileUnique})
        yFileUnique = "#{yFileUnique}.reverse"
    end

    puts "Filling unique y coords with leading 0's..."
    %x(add_zs.sh 0 #{yFileUnique})
    yFileCoordsZs = "#{yFileUnique}.zs"
    plot_args << " " << yFileCoordsZs
end

puts "Produce plot for +/0 sequences..."
%x(Rscript #{plotter} #{plot_args})
%x(mv Rplots.pdf intersect_and_unique_plot.pdf)

puts "Move plots and data into separate directory..."
%x(mkdir -p #{experiment})
%x(mv *.combined #{experiment}/)
%x(mv *.zs #{experiment}/)
%x(mv *.pdf #{experiment}/)
%x(mv *.R #{experiment}/)
%x(mv *.origin #{experiment}/)
%x(mv intsct.* #{experiment}/)

intermediate_dir = "#{experiment}_intermediate_files"

puts "Move intermediate files into separate directory..."
%x(mkdir -p #{intermediate_dir})
%x(mv #{xFileName}.* #{intermediate_dir}/)
%x(mv #{yFileName}.* #{intermediate_dir}/)

puts "done."
