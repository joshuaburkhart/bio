#!/usr/bin/ruby

#Usage: result_builder.rb <YAML cfg file> <ERB template file>

#Example: result_builder.rb photoperiod_cfg.yml photoperiod_plotter.R.erb

require 'yaml'
YAML::ENGINE.yamler = 'syck'
require 'erb'

cfgFileName = ARGV[0]
plotterFileName = ARGV[1]

cfgData = YAML.load_file(cfgFileName)
xFileName = cfgData['xfile']['name']
yFileName = cfgData['yfile']['name']

main_lab =    cfgData['main_lab']
xlab_left =   cfgData['xlab_left']
xlab_right =  cfgData['xlab_right']
ylab_top =    cfgData['ylab_top']
ylab_bottom = cfgData['ylab_bottom']

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

puts "Join on common identifying attribute..."
%x(ma_intersect.rb #{xFileStripped} #{yFileStripped})

intsct = "#{xFileStripped}-#{yFileStripped}.intsct.csv"

puts "Extract values used for coordinates..."
%x(coord_extractor.sh #{intsct} 2)

xCoords = "#{intsct}.odd_coords"
yCoords = "#{intsct}.even_coords"

if(cfgData['xfile']['reverse'] == 'true')
    %x(reverse_vals.sh #{xCoords})
    xCoords = "#{xCoords}.reverse"
end

if(cfgData['yfile']['reverse'] == 'true')
    %x(reverse_vals.sh #{yCoords})
    yCoords = "#{yCoords}.reverse"
end

puts "Combine values..."
%x(ma_coord_combiner.rb #{xCoords} #{yCoords})


puts "Write plotter for +/- sequences..."
plotterRenderer = ERB.new(File.read(plotterFileName))
intsctPlotter = "plot_#{xFileName}-#{yFileName}_intersect_only.R"
intsctPlotterHandl = File.open(intsctPlotter,"w")
intsctPlotterHandl.puts(plotterRenderer.result())
intsctPlotterHandl.close()

combinedCoords = "#{xCoords}-#{yCoords}.combined"

puts "Produce plot for +/- sequences..."
%x(Rscript #{intsctPlotter} #{combinedCoords})
%x(mv Rplots.pdf intsct_plot.pdf)

puts "Filter sequences uniquely expressed in each assay..."
%x(filter_unique.sh #{xFileStripped} #{intsct})
%x(filter_unique.sh #{yFileStripped} #{intsct})

xFileUnique = "#{xFileStripped}.unique"
yFileUnique = "#{yFileStripped}.unique"

puts "Fill with corresponding 0's..."
%x(add_zs.sh 1 #{xFileUnique})
%x(add_zs.sh 0 #{yFileUnique})

xFileCoordsZs = "#{xFileUnique}.zs"
yFileCoordsZs = "#{yFileUnique}.zs"

puts "Write plotter for +/0 sequences..."
plotterRenderer = ERB.new(File.read(plotterFileName))
uniquePlotter = "plot_#{xFileName}-#{yFileName}_intersect_and_unique.R"
uniquePlotterHandl = File.open(uniquePlotter,"w")
uniquePlotterHandl.puts(plotterRenderer.result())
uniquePlotterHandl.close()

puts "Produce plot for +/0 sequences..."
%x(Rscript #{uniquePlotter} #{combinedCoords} #{xFileCoordsZs} #{yFileCoordsZs})
%x(mv Rplots.pdf intersect_and_unique_plot.pdf)

puts "Move plots and data into separate directory..."
%x(mkdir -p results)
%x(mv #{combinedCoords} results/)
%x(mv #{xFileCoordsZs} results/)
%x(mv #{yFileCoordsZs} results/)
%x(mv *.pdf results/)

puts "done."
