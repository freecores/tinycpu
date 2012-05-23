class Register8
  attr_accessor :number
  def initialize(num)
	@number=num
  end
  
end

def mov_r8_imm8(reg,imm)
  p (0xB0+reg.number).to_s(16)+' '+(imm.to_s)
end

def mov(arg1,arg2)
  if arg1.kind_of? Register8 and arg2.kind_of? Integer and arg2<0x100 then mov_r8_imm8 arg1,arg2 end
  
end

ax=Register8.new(0)
bx=Register8.new(3)
cx=Register8.new(1)
dx=Register8.new(2)

mov ax,0x10
