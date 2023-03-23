define init-pwndbg
source ~/pwndbg/gdbinit.py
end
document init-pwndbg
Initializes PwnDBG
end

define init-gef
source ~/.gdbinit-gef.py
end
document init-gef
Initializes GEF (GDB Enhanced Features)
end

define hook-run
python
import angelheap
angelheap.init_angelheap()
end
end

# Default Settings 
source ~/pwndbg/gdbinit.py
source ~/Pwngdb/pwngdb.py
source ~/Pwngdb/angelheap/gdbinit.py


