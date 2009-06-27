class Wave
  def make_wave(time, exp) #�g�`�쐬�̋��ʏ���
    @time = time
    body_size  = time * @sample_rate
    @data_body = Array.new(body_size)
    @data_size = body_size * @block_size
    @data_body.each_index do |i|
      @data_body[i] = exp.call(i)
      @data_body[i] *= 32768 * @channel_num
    end
    self
  end

  def make_sin(freq, amp, time=1) #�f�[�^���T�C���g�ɂ���(���g���A�U���A����)
    exp = lambda {|i| amp * sin(2.0 * PI * freq * i / @sample_rate)}
    make_wave(time, exp)
  end

  def make_saw(freq, amp, time=1) #�f�[�^���m�R�M���g�ɂ���(���g���A�U���A����)
    sample_per_freq = @sample_rate / freq
    peak_pos = sample_per_freq / 2 #�g�`�̃s�[�N�̈ʒu
    val_per_sample = amp / peak_pos
    exp = lambda {|i| 
      val = val_per_sample * (i % peak_pos)  
      if i % sample_per_freq < peak_pos
        val  
      else
        val - amp 
      end
    }
    make_wave(time, exp)
  end

  def make_sin_saw(freq, amp, time=1) #�f�[�^���m�R�M���g�ɂ���(���g���A�U���A����)
    exp = lambda{|i| 
      #sin�̊|�����킹�Ńm�R�M���g�����
      val = 0
      1.upto(15) do |n|
        val += amp / n * sin(2.0 * PI * freq * i * n / @sample_rate)
      end
      val
    }
    make_wave(time, exp)
  end

  def make_square(freq, amp, time=1) #�f�[�^����`�g�ɂ���(���g���A�U���A����)
    sample_per_freq = @sample_rate / freq
    peak_pos = sample_per_freq / 2 #�g�`�̃s�[�N�̈ʒu
    exp = lambda {|i| 
      if i % sample_per_freq < peak_pos
        amp
      else
        -amp
      end
    }
    make_wave(time, exp)
  end
  
  def make_sin_square(freq, amp, time=1) #�f�[�^����`�g�ɂ���(���g���A�U���A����)
    @exp = lambda{|i| 
      #sin�̊|�����킹�ŋ�`�g�����
      val = 0
      1.upto(15) do |n|
        val += amp / n * sin(2.0 * PI * freq * i * n / @sample_rate) if n % 2 == 1
      end
      val
    }
    make_wave(time, exp)
  end
end
