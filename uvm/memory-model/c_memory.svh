class memory extends uvm_object;
    `uvm_object_utils(memory)
    t_mem_data mem [t_mem_addr];
    
    pkg_memory::t_byte_addr b_addr;
    pkg_memory::t_word word;
 
    function new(string name ="memory");
      super.new(name);
    endfunction 
    
    function void initialize(string path);
        $readmemh(path , mem);
    endfunction

    function void dump(string path);
        int file, size, status;
        pkg_memory::t_mem_addr index;

        file  = $fopen(path, "w");
        size  = mem.size();
        status = mem.first(index);

        $fdisplay(file, "address, data");
        for (int i = 0; i < size; i++) begin
            $fdisplay(file, $sformatf("%h, %h", index, mem[index]));
            if(!mem.next(index)) break;
        end
        $fclose(file);
    endfunction

    function bit [7:0] read_byte(pkg_memory::t_mem_addr addr);        
        bit [7 :0] data;

        if (mem.exists(addr)) begin
            word   = mem[addr];
            b_addr = addr[pkg_memory::BYTE_ADDR-1 : 0];
            data   = word[b_addr];

            `uvm_info("memory",$sformatf("Read Byte  : Addr[0x%h], Data[0x%h]", addr, data), UVM_LOW)
        end else begin
            `uvm_error("memory",$sformatf("read to uninitialzed addr 0x%h", addr))
        end 
        return data;
    endfunction

    function void write_byte(pkg_memory::t_mem_addr addr,  pkg_memory::t_word data);
        word         = mem[addr];
        b_addr       = addr[pkg_memory::BYTE_ADDR-1 : 0];
        word[b_addr] = data[b_addr];
        mem[addr]    = word;
        
        `uvm_info("memory",$sformatf("Write Byte : Addr[0x%h], Data[0x%h]", addr, data), UVM_LOW)
    endfunction

    function void write(t_mem_addr addr, t_mem_data data);
        mem[addr] = data;

        `uvm_info("memory",$sformatf("Write word : Addr[0x%h], Data[0x%h]", addr, data), UVM_LOW)
    endfunction

    function pkg_memory::t_mem_data read(pkg_memory::t_mem_addr addr);
        pkg_memory::t_mem_data data;
        data = mem[addr];

        `uvm_info("memroy",$sformatf("Read word  : Addr[0x%h], Data[0x%h]", addr, data), UVM_LOW)
        return data;
    endfunction
endclass : memory
