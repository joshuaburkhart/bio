#!/usr/bin/ruby

#Usage: ma2plottable_csv.rb <ma data file on x-axis> <ma data file on y-axis> <DEET *.seqs.csv file>

#NOTE: you may have to use ma_inverter.rb to create desired MA input files

#NOTE: this program produces a file with below headers, containing DEET status 2 (best representative sequence)
#      and status 3 (paralog) sequences with below header and filename.
#
#HEADER: Sequence ID,X Coordinate from PBSD22-KCSD22,Y Coordinate from PBLD22-KCLD22,Q value from PBSD22-KCSD22, Q value from PBLD22-KCLD22,,X q<0.05,Y q<0.05,X&Y = 0?,UpLeft,Vertical,UpRight,Horizon,LowRight,LowLeft
#
#FILE NAME: <ma data file on x-axis>-<ma data file on y-axis>.csv

DEETDataRow = Struct.new(:id, :status, :name, :locusTag, :ncbiAccNum, :paralogNum, :exprSig)
MADataRow = Struct.new(:gene, :M, :A, :t, :pvalue, :qvalue, :B)
OutputDataRow = Struct.new(:seqId, :xCoor, :yCoord, :qXor0ifLtLim, :qYor0ifLtLim, :qXisLtLim, :qYisLtLim, :qXandqYis0, :upLeft, :vertical, :upRight, :horizon, :lowRight, :lowLeft)
Q_LIMIT = 0.05 #q values should be below this limit
T = "TRUE"
F = "FALSE"

def LoadDEETIntoHash(fn)
  fh = File.open(fn, "r")
  hsh = Hash.new

  fh.gets #skip 1-line header
  puts "creating filter hash from #{fn}..."

  count = 0
  while (dataLine = fh.gets)
    if (count % 1000 == 0)
      print "."
      STDOUT.flush
    end
    dataLineAry = dataLine.split(/~/)

    #puts "#{fn} at #{count}: '#{dataLine}'"

    id = dataLineAry[0]
    status = Float(dataLineAry[1])
    name = dataLineAry[2]
    locusTag = dataLineAry[3]
    ncbiAccNum = dataLineAry[4]
    exprSig = dataLineAry[5]

    hsh[id] = DEETDataRow.new(id, status, name, locusTag, ncbiAccNum, exprSig)

    count += 1
  end
  fh.close
  puts
  return hsh
end

def LoadMAIntoHash(fn)
  fh = File.open(fn, "r")
  hsh = Hash.new

  fh.gets #skip 1-line header
  puts "building sequence hash from #{fn}..."

  count = 0
  while (dataLine = fh.gets)
    if (count % 1000 == 0)
      print "."
      STDOUT.flush
    end
    dataLineAry = dataLine.split(/\s/)
    gene = dataLineAry[0]
    _M = Float(dataLineAry[1])
    _A = Float(dataLineAry[2])
    t = Float(dataLineAry[3])
    pvalue = Float(dataLineAry[4])
    qvalue = Float(dataLineAry[5])
    _B = Float(dataLineAry[6])
    hsh[gene] = MADataRow.new(gene, _M, _A, t, pvalue, qvalue, _B)

    count += 1
  end
  fh.close
  puts
  return hsh
end

maXfn = ARGV[0]
maYfn = ARGV[1]
deetfn = ARGV[2]

maXfn.match(/.*limma\.([0-9A-Z-]+)[\.a-z]*/)
prettyMaXfn = $1

maYfn.match(/.*limma\.([0-9A-Z-]+)[\.a-z]*/)
prettyMaYfn = $1

maXhsh = LoadMAIntoHash(maXfn)
maYhsh = LoadMAIntoHash(maYfn)
deethsh = LoadDEETIntoHash(deetfn)

CSV_FN = "#{prettyMaXfn}-#{prettyMaYfn}.csv"
csvFh = File.open(CSV_FN, "w")

puts "writing header to #{CSV_FN}..."

column_A = "Sequence ID"
column_B = "X Coordinate from #{prettyMaXfn}"
column_C = "Y Coordinate from #{prettyMaYfn}"
column_D = "Q value from #{prettyMaXfn}"
column_E = "Q value from #{prettyMaYfn}"
column_F = "X q<#{Q_LIMIT}?"
column_G = "Y q<#{Q_LIMIT}?"
column_H = "X&Y = 0?"
column_I = "UpLeft"
column_J = "Vertical"
column_K = "UpRight"
column_L = "Horizon"
column_M = "LowRight"
column_N = "LowLeft"

csvFh.puts "#{column_A},#{column_B},#{column_C},#{column_D},#{column_E},#{column_F},#{column_G},#{column_H},#{column_I},#{column_J},#{column_K},#{column_L},#{column_M},#{column_N}"

puts "writing data to #{CSV_FN}..."
count = 0
deethsh.each { |kv_pair|
  if (count % 1000 == 0)
    print "."
    STDOUT.flush
  end
  deetDataRow = kv_pair[1]
  #if (deetDataRow.status == 2 || deetDataRow.status == 3)
    xDataRow = maXhsh[kv_pair[0]]
    yDataRow = maYhsh[kv_pair[0]]

  if(!xDataRow.nil? &&
    !yDataRow.nil? &&
    !xDataRow.M.nil? &&
    !yDataRow.M.nil?)
    column_A = kv_pair[0] #seqId
    column_B = xDataRow.M
    column_C = yDataRow.M
    column_D = xDataRow.qvalue
    column_E = yDataRow.qvalue
    column_F = column_D < Q_LIMIT ? column_B : 0 #=IF(D2>0.0499999,0,B2)
    column_G = column_E < Q_LIMIT ? column_C : 0 #=IF(E2>0.049999, 0, C2)
    column_H = column_F == 0 && column_G == 0 ? T : F #=AND(F2=0, G2=0)
    column_I = column_F < 0 && column_G > 0 ? T : F #=AND(F2<0, G2>0) -- UpLeft
    column_J = column_F == 0 && column_G != 0 ? T : F #=AND(F2=0, G2<>0) -- Vertical
    column_K = column_F > 0 && column_G > 0 ? T : F #=AND(F2>0, G2>0) -- UpRight
    column_L = column_F != 0 && column_G == 0 ? T : F #=AND(F2<>0, G2=0) -- Horizon
    column_M = column_F > 0 && column_G < 0 ? T : F #=AND(F2>0, G2<0) -- LowRight
    column_N = column_F < 0 && column_G < 0 ? T : F #=AND(F2<0, G2<0) -- LowLeft

    csvFh.puts "#{column_A},#{column_B},#{column_C},#{column_D},#{column_E},#{column_F},#{column_G},#{column_H},#{column_I},#{column_J},#{column_K},#{column_L},#{column_M},#{column_N}"

    count += 1
  end
}
csvFh.close

puts
puts "#{count} data rows written to #{CSV_FN}."
puts "done."
