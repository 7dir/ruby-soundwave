require 'lib/soundwave.rb'
file1 = open("samples/wav/wav1.wav")
w1 = Wave.new(file1)
print w1.dump

