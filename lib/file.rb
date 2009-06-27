#WAVE�t�@�C������͂���
#dump�������ʂ�܂���O���t�Ȃǂɂ���Δg�`�����邱�Ƃ��o����
require 'pp'
include Math

class String
  def to_long
    self.unpack("L*")[0]
  end

  def to_short
    self.unpack("S*")[0]
  end
end

class Fixnum
  def pack_long
    [self].pack("L*")
  end

  def pack_short
    [self].pack("S*")
  end
end

class Wave
  #reference : http://www.kk.iij4u.or.jp/~kondo/wave/
  attr_accessor( 
    :riff_header   , #4 byte R' 'I' 'F' 'F'  	RIFF�w�b�_  	�@
    :file_size     , #4 byte ����ȍ~�̃t�@�C���T�C�Y (�t�@�C���T�C�Y - 8) 	�@ 	�@
    :wave_header   , #4 byte W' 'A' 'V' 'E' 	WAVE�w�b�_ 	RIFF�̎�ނ�WAVE�ł��邱�Ƃ�����킷
    :fmt_difinit   , #4 byte f' 'm' 't' ' ' (���X�y�[�X���܂�) 	fmt �`�����N 	�t�H�[�}�b�g�̒�`
    :fmt_size      , #4 byte �o�C�g�� 	fmt �`�����N�̃o�C�g�� 	���j�APCM �Ȃ�� 16(10 00 00 00)
    :fmt_id        , #2 byte �t�H�[�}�b�gID ���j�APCM �Ȃ�� 1(01 00)
    :channel_num   , #2 byte �`�����l����	���m���� �Ȃ�� 1(01 00) �X�e���I �Ȃ�� 2(02 00)
    :sample_rate   , #4 byte �T���v�����O���[�g	Hz 	44.1kHz �Ȃ�� 44100(44 AC 00 00)
    :data_speed    , #4 byte �f�[�^���x (Byte/sec)44.1kHz 16bit �X�e���I �Ȃ�� 44100�~2�~2 = 176400(10 B1 02 00)
    :block_size    , #2 byte �u���b�N�T�C�Y (Byte/sample�~�`�����l����)	16bit �X�e���I �Ȃ�� 2�~2 = 4(04 00)
    :bit_per_sample, #2 byte �T���v��������̃r�b�g�� (bit/sample)WAV �t�H�[�}�b�g�ł�8bit��16bit 16bit �Ȃ�� 16(10 00)
    :extent_size   , #2 byte �g�������̃T�C�Y ���j�APCM�Ȃ�Α��݂��Ȃ�
    :extent_body   , #n byte �g������ ���j�APCM�Ȃ�Α��݂��Ȃ�
    :data_tag      , #4 byte d' 'a' 't' 'a' 	data �`�����N
    :data_size     , #4 byte �o�C�g��n 	�g�`�f�[�^�̃o�C�g�� 	�@
    :data_body     , #n byte �g�`�f�[�^
    :time            #�Đ����ԁidata_size/data_speed)
               )    

  def initialize(file=nil)
    case file.class.to_s
    when "File"
      read(file) 
    when "String" 
      open(file) {|f| read(f)}
    else
      #file���^�����Ȃ��Ƃ��̓w�b�_���f�t�H���g�l�i16�r�b�g���m�����j�ō��B
      #�ȉ��̃����o�͋�
      # @file_size, @extent_size, @extent_body
      @riff_header    = "RIFF"
      @wave_header    = "WAVE"
      @fmt_difinit    = "fmt "
      @fmt_size       = 16
      @fmt_id         = 1
      @channel_num    = 1
      @sample_rate    = 44100
      @data_speed     = 44100
      @block_size     = 2
      @bit_per_sample = 16
      @data_tag       = "data"
      @data_size      = 0
      @data_body      = []
      @time           = 0
    end
  end

  def read(file)
    begin
      file.binmode
      @riff_header    =  file.read(4)
      if @riff_header != "RIFF"
        raise "File Format Wrong. Not RIFF"
      end
      @file_size      =  file.read(4).to_long
      @wave_header    =  file.read(4)
      @fmt_difinit    =  file.read(4)
      if @wave_header + @fmt_difinit != "WAVEfmt "
        raise "File format wrong. Not WAVE"
      end
      @fmt_size       =  file.read(4).to_long
      @fmt_id         =  file.read(2).to_short
      if @fmt_id != 1
        raise "PCM only available."
      end
      @channel_num    =  file.read(2).to_short
      @sample_rate    =  file.read(4).to_long
      @data_speed     =  file.read(4).to_long
      @block_size     =  file.read(2).to_short
      @bit_per_sample =  file.read(2).to_short
      #  @extent_size    =  file.read(2)            #not read
      #  @extent_body    =  file.read(@extent_size) #not read
      @data_tag       =  file.read(4)
      @data_size      =  file.read(4).to_long
      @data_body_raw   =  file.read(@data_size)
      @data_body = []
      if @channel_num == 2
        @data_body = @data_body_raw.unpack("l*")
      elsif @channel_num == 1
        @data_body = @data_body_raw.unpack("s*")
      end
      @time =  @data_size / @data_speed.to_f
    ensure
      file.close
    end
    self
  end

  def copy #�����Ɠ����f�[�^�����A�V����Wave������ĕԂ�
    new_w = Wave.new
    new_w.riff_header    = @riff_header    
    new_w.file_size      = @file_size
    new_w.wave_header    = @wave_header   
    new_w.fmt_difinit    = @fmt_difinit   
    new_w.fmt_size       = @fmt_size      
    new_w.fmt_id         = @fmt_id        
    new_w.channel_num    = @channel_num   
    new_w.sample_rate    = @sample_rate   
    new_w.data_speed     = @data_speed    
    new_w.block_size     = @block_size    
    new_w.bit_per_sample = @bit_per_sample
    new_w.data_tag       = @data_tag       
    new_w.data_size      = @data_size
    new_w.data_body      = @data_body.dup
    new_w.time           = @time
    new_w
  end

  def save(file_name)
    #file�T�C�Y�̌v�Z
    @file_size = 4 + #wave_header   
      4 + #fmt_difinit   
      4 + #fmt_size      
      2 + #fmt_id        
      2 + #channel_num   
      4 + #sample_rate   
      4 + #data_speed    
      2 + #block_size    
      2 + #bit_per_sample
      4 + #data_tag      
      4 + #data_size     
      @data_size 
    #�f�[�^��pack
    if @channel_num == 2
      @data_body_raw = @data_body.pack("l*")
    else @channel_num == 1
      @data_body_raw = @data_body.pack("s*")
    end
    #�t�@�C���I�[�v���E��������
    f = File.open(file_name,"w")
    f.binmode
    f.write(@riff_header)
    f.write(@file_size.pack_long)
    f.write(@wave_header)
    f.write(@fmt_difinit)
    f.write(@fmt_size.pack_long)
    f.write(@fmt_id.pack_short)
    f.write(@channel_num.pack_short)
    f.write(@sample_rate.pack_long)
    f.write(@data_speed.pack_long)
    f.write(@block_size.pack_short)
    f.write(@bit_per_sample.pack_short)
    f.write(@data_tag)
    f.write(@data_size.pack_long)
    f.write(@data_body_raw)
    f.close
    self
  end

  def dump
    @data_body.join("\n")
  end

  def add(other) #�ʂ�Wave�̔g�`�ƍ�������
    unless other.class == self.class 
      raise "Cannot add. Both files need to be WAVE." 
    end
    new_w = self.copy
    data_arraysize = [@data_body.size,other.data_body.size].max
    new_w.data_body = Array.new(data_arraysize)
    new_w.data_body.each_index do |i|
      val1 = @data_body[i] || 0
      val2 = other.data_body[i] || 0
      new_val = val1 + val2
      new_w.data_body[i] = new_val
    end
    new_w.data_size = new_w.data_body.size * new_w.block_size
    new_w.time      =  new_w.data_size / new_w.data_speed.to_f
    new_w
  end

  def sub(other) #�e�T���v���̒l��ʂ�Wave�̑Ή�����l�Ō��Z����
    unless other.class == self.class 
      raise "Cannot substruct. Both files need to be WAVE." 
    end
    new_w = self.copy
    data_arraysize = [@data_body.size,other.data_body.size].max
    new_w.data_body = Array.new(data_arraysize)
    new_w.data_body.each_index do |i|
      val1 = @data_body[i] || 0
      val2 = other.data_body[i] || 0
      new_val = val1 - val2
      new_w.data_body[i] = new_val
#      printf "%d:%d:%d\n", val1, val2, new_val
    end
    new_w.data_size = new_w.data_body.size * new_w.block_size
    new_w.time      =  new_w.data_size / new_w.data_speed.to_f
    new_w
  end

  def cat(other) #other�̃f�[�^�������̃f�[�^�̌��ɂ�������
    #���[�g�̈Ⴄ�����t�@�C������������ƕςɂȂ�̂Œ��ӁI
    unless other.class == self.class 
      raise "Cannot Concat. Both files need to be WAVE." 
    end
    new_w = self.copy
    new_w.data_body.concat(other.data_body)
    new_w.data_size = new_w.data_body.size * new_w.block_size
    new_w.time      =  new_w.data_size / new_w.data_speed.to_f
    new_w
  end

  def reverse!
    self.data_body.reverse!
    self
  end

end
