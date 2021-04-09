
i=0
if sims -sys=manycore -vlt_build -vlt_build_args=--trace -vlt_build_args=-CFLAGS -vlt_build_args=-DVERILATOR_VCD -gpcore | grep -q 'Error:'; then
   echo "error in design"

else 
echo build pass

if sims -sys=manycore -gpcore -vlt_run add.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo add pass
else 
echo "error in add"

fi

 

if sims -sys=manycore -gpcore -vlt_run addi.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo addi pass
else 
echo "error in addi"

fi

 

if sims -sys=manycore -gpcore -vlt_run and.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo and pass
else 
echo "error in and"

fi


 

if sims -sys=manycore -gpcore -vlt_run andi.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo andi pass
else 
echo "error in andi"

fi


 

if sims -sys=manycore -gpcore -vlt_run auipc.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo auipc pass
else 
echo "error in auipc"

fi


 

if sims -sys=manycore -gpcore -vlt_run beq.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo beq pass
else 
echo "error in beq"

fi


 

if sims -sys=manycore -gpcore -vlt_run bge.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo bge pass
else 
echo "error in bge"

fi


 

if sims -sys=manycore -gpcore -vlt_run bgeu.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo bgeu pass
else 
echo "error in bgeu"

fi


 

if sims -sys=manycore -gpcore -vlt_run blt.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo blt pass
else 
echo "error in blt"

fi


 

if sims -sys=manycore -gpcore -vlt_run bltu.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo bltu pass
else 
echo "error in bltu"

fi


 

if sims -sys=manycore -gpcore -vlt_run bne.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo bne pass
else 
echo "error in bne"

fi


 

if sims -sys=manycore -gpcore -vlt_run div.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo div pass
else 
echo "error in div"

fi




if sims -sys=manycore -gpcore -vlt_run divu.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo divu pass
else 
echo "error in divu"

fi




if sims -sys=manycore -gpcore -vlt_run j.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo j pass
else 
echo "error in j"

fi




if sims -sys=manycore -gpcore -vlt_run jal.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo jal pass
else 
echo "error in jal"

fi




if sims -sys=manycore -gpcore -vlt_run jalr.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo jalr pass
else 
echo "error in jalr"

fi


 

if sims -sys=manycore -gpcore -vlt_run lui.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo lui pass
else 
echo "error in lui"

fi


 

if sims -sys=manycore -gpcore -vlt_run mul.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo mul pass
else 
echo "error in mul"

fi


 

if sims -sys=manycore -gpcore -vlt_run mulh.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo mulh pass
else 
echo "error in mulh"

fi


 

if sims -sys=manycore -gpcore -vlt_run mulhsu.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo mulhsu pass
else 
echo "error in mulhsu"

fi


 

if sims -sys=manycore -gpcore -vlt_run mulhu.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo mulhu pass
else 
echo "error in mulhu"

fi


 

if sims -sys=manycore -gpcore -vlt_run or.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo or pass
else 
echo "error in or"

fi


 

if sims -sys=manycore -gpcore -vlt_run ori.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo ori pass
else 
echo "error in ori"

fi


 

if sims -sys=manycore -gpcore -vlt_run rem.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo rem pass
else 
echo "error in rem"

fi


 

if sims -sys=manycore -gpcore -vlt_run remu.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo remu pass
else 
echo "error in remu"

fi

 

if sims -sys=manycore -gpcore -vlt_run sll.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo sll pass
else 
echo "error in sll"

fi

 

if sims -sys=manycore -gpcore -vlt_run slli.S | grep -q 'PASS'; then
   i=$((i+1))  
echo slli pass
else 
echo "error in slli"

fi

 

if sims -sys=manycore -gpcore -vlt_run slt.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo slt pass
else 
echo "error in slt"

fi


 

if sims -sys=manycore -gpcore -vlt_run sra.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo sra pass
else 
echo "error in sra"

fi


 

if sims -sys=manycore -gpcore -vlt_run srl.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo srl pass
else 
echo "error in srl"

fi


 

if sims -sys=manycore -gpcore -vlt_run srli.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo srli pass
else 
echo "error in srli"

fi

 

if sims -sys=manycore -gpcore -vlt_run sub.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo sub pass
else 
echo "error in sub"

fi

 

if sims -sys=manycore -gpcore -vlt_run xor.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo xor pass
else 
echo "error in xor"

fi


 

if sims -sys=manycore -gpcore -vlt_run xori.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo xori pass
else 
echo "error in xori"

fi


 

if sims -sys=manycore -gpcore -vlt_run csrm.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo csrm pass
else 
echo "error in csrm"

fi


 

if sims -sys=manycore -gpcore -vlt_run csrs.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo csrs pass
else 
echo "error in csrs"

fi

 

if sims -sys=manycore -gpcore -vlt_run mbreak.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo mbreak pass
else 
echo "error in mbreak"

fi


 

if sims -sys=manycore -gpcore -vlt_run mcall.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo mcall pass
else 
echo "error in mcall"

fi

 

if sims -sys=manycore -gpcore -vlt_run mcsr.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo mcsr pass
else 
echo "error in mcsr"

fi



 

if sims -sys=manycore -gpcore -vlt_run sbreak.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo sbreak pass
else 
echo "error in sbreak"

fi



 

if sims -sys=manycore -gpcore -vlt_run scall.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo scall pass
else 
echo "error in scall"

fi



 

if sims -sys=manycore -gpcore -vlt_run sw_misaligned.S | grep -q 'PASS'; then
   i=$((i+1)) 
echo sw_misaligned pass
else 
echo "error in sw_misaligned"

fi





fi


