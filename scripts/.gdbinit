# pwndbg
source ~/.local/pwndbg/gdbinit.py

# pwngdb
source ~/.local/Pwngdb/pwngdb.py
source ~/.local/Pwngdb/angelheap/gdbinit.py

define hook-run
    python
import angelheap
angelheap.init_angelheap()
    end
end

define gef-init
    python sys.path.insert(0, "/root/.gef"); from gef import *; Gef.main()
end
