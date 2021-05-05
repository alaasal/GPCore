class memory extends uvm_object;
    //TODO: REVIEW MEMORY OPS ARE PERFORMED CORRECTLY
    bit [pkg_memory::t_mem_data] mem [pkg_memory::t_mem_addr];
    
    pkg_memory::t_byte_addr b_addr;
    pkg_memory::t_word word;

    `uvm_object_utils(memory)
    `uvm_object_new

    request_tran  req_tran;
    response_tran resp_tran;
    
    function void initialize(string path);
        $readmemh(path , mem);
    endfunction

    function void dump(string path);
        int file, size;
        pkg_memory::t_mem_addr index;

        file  = $fopen(path, "w");
        size  = mem.size();
        mem.first(index);

        $fdisplay(file, "address, data");
        for (int i = 0; i < size; i++) begin
            $fdisplay(file, $sformatf("%h, %h", index, mem[index]));
            if(mem.next(index)) begin
                `uvm_error("Next entry in memory cannot be found")
                break;
            end
        end
        $fclose(file);
    endfunction

    function bit [7:0] read_byte(pkg_memory::t_mem_addr addr);        
        bit [7 :0] data;

        if (mem.exists(addr)) begin
            word   = mem[addr];
            b_addr = addr[pkg_memory::BYTE_ADDR-1 : 0];
            data   = word[b_addr];

            `uvm_info($sformatf("Read Byte  : Addr[0x%0h], Data[0x%0h]", addr, data), UVM_HIGH)
        end else begin
            `uvm_error($sformatf("read to uninitialzed addr 0x%0h", addr))
        end 
        return data;
    endfunction

    function void write_byte(pkg_memory::t_mem_addr addr,  pkg_memory::t_word data);
        word         = mem[addr];
        b_addr       = addr[pkg_memory::BYTE_ADDR-1 : 0];
        word[b_addr] = data[b_addr];
        mem[addr]    = word;
        
        `uvm_info($sformatf("Write Byte : Addr[0x%0h], Data[0x%0h]", addr, data), UVM_HIGH)
    endfunction

    function void write(input mem_addr_t addr, mem_data_t data);
        mem[addr] = data;

        `uvm_info($sformatf("Write word : Addr[0x%0h], Data[0x%0h]", addr, data), UVM_HIGH)
    endfunction

    function pkg_memory::t_mem_data read(pkg_memory::t_mem_addr addr);
        pkg_memory::t_mem_data data;
        data = mem[data];

        `uvm_info($sformatf("Read word  : Addr[0x%0h], Data[0x%0h]", addr, data), UVM_HIGH)
        return data;
    endfunction
endclass : memory
