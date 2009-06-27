require 'lib/soundwave.rb'

file1 = open("samples/wav/wav1.wav")
w1 = Wave.new(file1)
w2 = Wave.new("samples/wav/wav2.wav")
new_w = w1.add(w2)
new_w.save('add.wav')
