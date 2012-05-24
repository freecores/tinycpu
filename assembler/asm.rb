PREFIX = "MemIn <= x\"";
SUFFIX = "\";";
SEPERATOR = "\n";



class OpcodeByte1
  attr_accessor :op, :register, :cond;
  def to_hex
    s = (op << 4 | register.number << 1 | cond).to_s(16);
    if s.length == 1
      "0"+s;
    elsif s.length == 0
      "00";
    else
      s
    end
  end
end

  

class Register8
  attr_accessor :number
  def initialize(num)
	@number=num
  end
end

$iftr = 0; #0 for no condition, 1 for if TR, 2 for if not TR
$useextra = 0;

def mov_r8_imm8(reg,imm)
  o = OpcodeByte1.new();
  o.op = 0;
  o.register=reg;
  if $iftr<2 then
    o.cond=$iftr;
  else
    raise "if_tr_notset is not allowed with this opcode";
  end
  puts PREFIX + o.to_hex + imm.to_s(16) + SUFFIX;
  puts SEPERATOR;
end
def mov_rm8_imm8(reg,imm)
  o=OpcodeByte1.new();
  o.op=1;
  o.register=reg;
  if $iftr<2 then
    o.cond=$iftr;
  else
    raise "if_tr_notset is not allowed with this opcode";
  end
  puts PREFIX + o.to_hex + imm.to_s(16) + SUFFIX;
  puts SEPERATOR;
end
  

def mov(arg1,arg2)
  if arg1.kind_of? Register8 and arg2.kind_of? Integer and arg2<0x100 then
    mov_r8_imm8 arg1,arg2 
  elsif arg1.kind_of? Array and arg2.kind_of? Integer and arg2<0x100 then
    if arg1.length>1 or arg1.length<1 then
      raise "memory reference is not correct. Only a register is allowed";
    end
    reg=arg1[0];
    mov_rm8_imm8 reg, arg2
  else
    raise "No suitable mov opcode found";
  end
    
end
def if_tr_set
  $iftr = 1
  yield
  $iftr = 0
end


r0=Register8.new(0)
r1=Register8.new(1)
r2=Register8.new(2)
r3=Register8.new(3)

#test code follows. Only do it here for convenience.. real usage should prefix assembly files with `require "asm.rb"` 
if_tr_set{
  mov r1,0x10
}
mov r1,0x20
mov [r1], 0x50