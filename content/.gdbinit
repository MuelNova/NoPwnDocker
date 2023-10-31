define init-pwndbg
source /usr/local/pwndbg/gdbinit.py
end
document init-pwndbg
Initializes PwnDBG
end

define init-gef
source /usr/local/.gdbinit-gef.py
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
source /usr/local/pwndbg/gdbinit.py
source /usr/local/Pwngdb/pwngdb.py
source /usr/local/Pwngdb/angelheap/gdbinit.py


