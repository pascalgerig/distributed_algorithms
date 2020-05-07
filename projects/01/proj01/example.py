import subprocess
import time

#params
nodes = 5
E = "./etcdctl"
EPT1 = "--endpoints=127.0.0.1:10001"    # Connect to node 1
EPT2 = "--endpoints=127.0.0.1:10002"    # Connect to node 2
EPT3 = "--endpoints=127.0.0.1:10003"    # Connect to node 3
EPT4 = "--endpoints=127.0.0.1:10004"    # Connect to node 4
EPT5 = "--endpoints=127.0.0.1:10005"    # Connect to node 5
# Use --consistency=l for linearizable reads (atomic)
# or  --consistency=s for serializable (local reads)
ECONS = '--consistency=s'
EPRINT = '--print-value-only'

def write(k, v, EPT):
    etcd = subprocess.Popen([E, 'put', str(k), str(v), str(EPT)], 
                            stdout=subprocess.PIPE, 
                            stderr=subprocess.STDOUT)
    stdout, stderr = etcd.communicate()
    print('Node: write('+ k, v+')')
    return

def read(k, EPT):
    etcd = subprocess.Popen([E, 'get', str(k), str(EPT), ECONS, EPRINT], 
                            stdout=subprocess.PIPE, 
                            stderr=subprocess.STDOUT)
    stdout, stderr = etcd.communicate()
    tmp = (str(stdout))[2:-3]
    print("Node: read("+ str(k) +") => " + tmp)

def main():
    k, v1, v2 = 'k', '1', '2'
    write(k, v, EPT1)
    write(k, v, EPT2)
    read(k, EPT1)
    read(k, EPT2)
    read(k, EPT3)
    read(k, EPT4)
    read(k, EPT5)

if __name__ == "__main__":
    main()
