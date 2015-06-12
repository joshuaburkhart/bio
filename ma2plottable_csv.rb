#!/usr/bin/ruby

#Usage: ma2plottable_csv.rb <ma data file on x-axis> <ma data file on y-axis> <DEET *.seqs.csv file>

#NOTE: you may have to use ma_inverter.rb to create desired MA input files

#NOTE: this program produces a file with below headers, containing DEET status 2 (best representative sequence)
#      and status 3 (paralog) sequences with below header and filename.
#
#HEADER: Sequence ID,X Coordinate from PBSD22-KCSD22,Y Coordinate from PBLD22-KCLD22,Q value from PBSD22-KCSD22, Q value from PBLD22-KCLD22,,X q<0.05,Y q<0.05,X&Y = 0?,UpLeft,Vertical,UpRight,Horizon,LowRight,LowLeft
#
#FILE NAME: <ma data file on x-axis>-<ma data file on y-axis>.csv

DEETDataRow   = Struct.new(:id,:status,:name,:locusTag,:ncbiAccNum,:paralogNum,:exprSig)
MADataRow     = Struct.new(:gene,:M,:A,:t,:pvalue,:qvalue,:B)
OutputDataRow = Struct.new(:seqId,:xCoor,:yCoord,:qXor0ifLtLim,:qYor0ifLtLim,:qXisLtLim,:qYisLtLim,:qXandqYis0,:upLeft,:vertical,:upRight,:horizon,:lowRight,:lowLeft)
Q_LIMIT       = 0.05 #q values should be below this limit
T             = "TRUE"
F             = "FALSE"

def LoadDEETIntoHash(fn)
    fh = File.open(fn,"r")
    hsh = Hash.new

    fh.gets #skip 1-line header
    puts "creating filter hash from #{fn}..."

    count = 0
    while(dataLine = fh.gets)
        if(count % 1000 == 0)
            print "."
            STDOUT.flush
        end
        dataLineAry = dataLine.split(/~/)

        #puts "#{fn} at #{count}: '#{dataLine}'"

        id         = dataLineAry[0]
        status     = Float(dataLineAry[1]) 
        name       = dataLineAry[2]
        locusTag   = dataLineAry[3]
        ncbiAccNum = dataLineAry[4]
        exprSig    = dataLineAry[5]

        hsh[id] = DEETDataRow.new(id,status,name,locusTag,ncbiAccNum,exprSig)

        count += 1
    end
    fh.close
    puts
    return hsh
end

def LoadMAIntoHash(fn)
    fh = File.open(fn,"r")
    hsh = Hash.new

    fh.gets #skip 1-line header
    puts "building sequence hash from #{fn}..."

    count = 0
    while(dataLine = fh.gets)
        if(count % 1000 == 0)
            print "."
            STDOUT.flush
        end
        dataLineAry = dataLine.split(/\s/)
        gene      = dataLineAry[0]
        _M        = Float(dataLineAry[1])
        _A        = Float(dataLineAry[2])
        t         = Float(dataLineAry[3])
        pvalue    = Float(dataLineAry[4])
        qvalue    = Float(dataLineAry[5])
        _B        = Float(dataLineAry[6])
        hsh[gene] = MADataRow.new(gene,_M,_A,t,pvalue,qvalue,_B)

        count += 1
    end
    fh.close
    puts
    return hsh
end

maXfn  = ARGV[0]
maYfn  = ARGV[1]
deetfn = ARGV[2]

maXfn.match(/.*limma\.([0-9A-Z-]+)[\.a-z]*/)
prettyMaXfn = $1

maYfn.match(/.*limma\.([0-9A-Z-]+)[\.a-z]*/)
prettyMaYfn = $1

maXhsh  = LoadMAIntoHash(maXfn)
maYhsh  = LoadMAIntoHash(maYfn)
deethsh = LoadDEETIntoHash(deetfn)

CSV_FN = "#{prettyMaXfn}-#{prettyMaYfn}.csv"
csvFh  = File.open(CSV_FN,"w")

puts "writing header to #{CSV_FN}..."

seqId        = "Sequence ID"
xCoord       = "X Coordinate from #{prettyMaXfn}"
yCoord       = "Y Coordinate from #{prettyMaYfn}"
qXor0ifLtLim = "Q value from #{prettyMaXfn}"
qYor0ifLtLim = "Q value from #{prettyMaYfn}"
qXisLtLim    = "X q<#{Q_LIMIT}?"
qYisLtLim    = "Y q<#{Q_LIMIT}?"
qXandqYis0   = "X&Y = 0?"
upLeft       = "UpLeft"
upRight      = "UpRight"
lowRight     = "LowRight"
lowLeft      = "LowLeft"
vertical     = "Vertical"
horizon      = "Horizon"

csvFh.puts "#{seqId},#{xCoord},#{yCoord},#{qXor0ifLtLim},#{qYor0ifLtLim},#{qXisLtLim},#{qYisLtLim},#{qXandqYis0},#{upLeft},#{vertical},#{upRight},#{horizon},#{lowRight},#{lowLeft}"

puts "writing data to #{CSV_FN}..."
count = 0
deethsh.each {|kv_pair|
    if(count % 1000 == 0)
        print "."
        STDOUT.flush
    end
    deetDataRow = kv_pair[1]
    if(deetDataRow.status == 2 || deetDataRow.status == 3)
        xDataRow = maXhsh[kv_pair[0]]
        yDataRow = maYhsh[kv_pair[0]]

        seqId        = kv_pair[0]
        xCoord       = xDataRow.M
        yCoord       = yDataRow.M
        qXor0ifLtLim = xDataRow.qvalue < Q_LIMIT ? xDataRow.qvalue : 0
        qYor0ifLtLim = yDataRow.qvalue < Q_LIMIT ? yDataRow.qvalue : 0
        qXisLtLim    = xDataRow.qvalue < Q_LIMIT ? T : F
        qYisLtLim    = yDataRow.qvalue < Q_LIMIT ? T : F
        qXandqYis0   = qXor0ifLtLim == 0 && qYor0ifLtLim == 0 ? T : F
        upLeft       = yCoord > 0 && xCoord < 0 ? T : F
        upRight      = yCoord > 0 && xCoord > 0 ? T : F
        lowRight     = yCoord < 0 && xCoord > 0 ? T : F
        lowLeft      = yCoord < 0 && xCoord < 0 ? T : F
        vertical     = xCoord == 0 ? T : F
        horizon      = yCoord == 0 ? T : F

        csvFh.puts "#{seqId},#{xCoord},#{yCoord},#{qXor0ifLtLim},#{qYor0ifLtLim},#{qXisLtLim},#{qYisLtLim},#{qXandqYis0},#{upLeft},#{vertical},#{upRight},#{horizon},#{lowRight},#{lowLeft}"

        count += 1
    end
}
csvFh.close

puts
puts "#{count} data rows written to #{CSV_FN}."
puts "done."

