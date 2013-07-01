#!/usr/bin/ruby

#Usage: coord2gene.rb <file with coordinates in rows> <file with genes in rows>

#Example: coord2gene.rb WI-WIOB.minus-KC-WI.minus.combined.manhattan.pos KC-WI.stripped-WI-WIOB.stripped.intsct.csv.stripped

coordfile = ARGV[0]
genefile = ARGV[1]

coordhandl = File.open(coordfile,"r")
outhandl = File.open("#{coordfile}.genes","w")

while(coordline = coordhandl.gets)
    print(".")
    STDOUT.flush

    x = Float(coordline.split(/\s/)[0])
    y = Float(coordline.split(/\s/)[1])
    genehandl = File.open(genefile,"r")
    while(geneline = genehandl.gets)
        name = geneline.split(/\s/)[0]
        geney = Float(geneline.split(/\s/)[1])
        if(geney == y)
            geneline = genehandl.gets
            genex = Float(geneline.split(/\s/)[1])
            if(genex == x)
                outhandl.puts(name)
            end
        else
            genehandl.gets
        end
    end
    genehandl.close
end

puts "done."

coordhandl.close
outhandl.close
