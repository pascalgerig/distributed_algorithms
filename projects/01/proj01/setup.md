# Distributed Algorithms, FS 2020 - Setup instructions for Project 1

For this project, you should run a virtual machine (VM) with Linux OS. On the VM, install go [1], etcd [2] and goreman [3]. 


## 1. Install the Go programming language (Linux)

The Go programming environment should be installed. You may either install the binaries as follows:
```
curl -O https://storage.googleapis.com/golang/go1.12.9.linux-amd64.tar.gz
tar -xvf go1.12.9.linux-amd64.tar.gz
sudo chown -R root:root ./go
sudo mv go /usr/local
```
Using a text editor, open the ~/.profile file and add the following two lines to the bottom of the file:
```
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
```

Alternatively, use the native package manager to install go, for example, on Ubuntu do:
```
apt install golang
```
Then use a text editor and add the following line at the end of ~/.procfile:
```
export GOPATH=$HOME/go
```

You may have to load the commands into the current shell instance:
```
source ~/.profile
```

In both cases you should now be able to run download and compile programs written in Go.  Test the installation:
```
go version
go version go1.12.9 linux/amd64
```


## 2. Install etcd (Linux)

Download, compile, and install etcd and etcdctl from the sources:
```
go get github.com/etcd-io/etcd
```

Verify the installation:
```
cd $GOPATH
./bin/etcd --version
>> etcd Version: 3.5.0-pre
cd $GOPATH/src/go.etcd.io/etcd/etcdctl
go build
./etcdctl version
>> etcdctl version: 3.5.0-pre
>> API version: 3.5
```


## 3. Install goreman (Linux)

Goreman [3] is a Go implementation of foreman [5], a tool that makes it easy to run web apps consisting of multiple processes. Using goreman, one can declare the various processes that are needed to run an application using a Procfile. Install this from the sources as follows:
```
go get github.com/mattn/goreman
```
Verify the installation:
```
cd $GOPATH
./bin/goreman version
>> 0.2.1
```


## 4. Configure etcd 

Create a new folder for running the etcd nodes and storing their data, enter it, and make sure you can start the binaries from there:
```
mkdir ~/etcdproj
cd etcdproj
ln -s $GOPATH/bin/etcd
ln -s $GOPATH/src/go.etcd.io/etcd/etcdctl/etcdctl
ln -s $GOPATH/bin/goreman
```
Extract also the files in `proj01.zip` into this directory.

Modify `Procfile` if needed.  The default file creates and configures 5 `etcd` nodes running on the local host. They communicate with each other using `http://127.0.0.1:11001` ...  `http://127.0.0.1:11005`.  They also open these addresses and ports for client comands:
```
n1: http://0.0.0.0:10001
n2: http://0.0.0.0:10002
n3: http://0.0.0.0:10003
n4: http://0.0.0.0:10004
n5: http://0.0.0.0:10005
```
To execute the 5 etcd processes declared in this file, run the following command:
```
./goreman start
```
When you restart the cluster after changing the configuration, it is a good idea to first clean their local storage with `rm -rf node?.etcd`

Do not forget to change the path of etcd in 'Procfile' if etcd is located elsewhere.  If everything is fine, you should see something like this in your terminal:
```
14:07:38 n1 | Starting n1 on port 5000
14:07:38 n2 | Starting n2 on port 5100
...
16:27:59 n1 | {"level":"warn","ts":"2020-05-01T16:27:59.536Z","caller":"etcdmain/etcd.go:89","msg":"'data-dir' was empty; using default","data-dir":"node1.etcd"}
16:27:59 n2 | {"level":"warn","ts":"2020-05-01T16:27:59.554Z","caller":"etcdmain/etcd.go:89","msg":"'data-dir' was empty; using default","data-dir":"node2.etcd"}
...
```
The outputs like "Starting n1 on port 5000" are from goreman. Other outputs are generated by the five etcd nodes.

Test the interaction with a client, e.g., 
```
./etcdctl --endpoints=127.0.0.1:10002 member list
>> 29ce228b3d7d10a0, started, node4, http://127.0.0.2:11004, http://0.0.0.0:10004, ..
>> ...
./etcdctl --endpoints=127.0.0.1:10003 put mydata "Distributed Algorithms 2020"
>> OK
./etcdctl --endpoints=127.0.0.1:10001 get mydata
mydata
Distributed Algorithms 2020
```


## 5. Configure the client

Run the client (`etcdctl`) form the same directory. 
```
./etcdctl --endpoints=127.0.0.1:10002 get mydata
mydata
Distributed Algorithms 2020
```

Start exploring from the Python script 'example.py', which demonstrates how can you write (key,value) to etcd.
```
python example.py
```
If everything is working fine, it should output this:
```
Node 1: write(k 1)
Node 1: read(k) => 1
```


## 6. Slow down the etcd cluster

In order to execute the project, you should artificially slow down the communication among the etcd nodes. In the default `Procfile` they communicate using ports 11001..11005. You can do this (as root!) by running the `add-delay-etcd.sh` [4].  It adds a probabilistic delay with average 200ms to all traffic on the `loopback` interface to and from the etcd ports:
```
./add-delay-etcd.sh
```
Now check that the traffic on the loopback interface is delayed:
```
tc qdisc show dev lo
>> qdisc prio 1: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>> qdisc netem 2: parent 1:3 limit 1000 delay 200.0ms  100.0ms
```
To delete delayed network settings again, use this command:
```
./rm-delay-etcd.sh
```


## 7. Start developing

Your client should demonstrate a violation of atomicity.  Configure consistency mode of client reads performed by `etcdctl` like this:
```
--consistency=l # for linearizable reads (atomic)
--consistency=s # for serializable (local reads)
```


## References

[1] [Installation tutorial for go](https://www.linode.com/docs/development/go/install-go-on-ubuntu/) \
[2] [Installation tutorial for etcd](https://etcd.io/docs/v3.4.0/dl-build/) \
[3] [Installation tutorial for goreman](https://etcd.io/docs/v3.1.12/dev-guide/local_cluster/) \
[4] [How to Use the Linux Traffic Control](https://netbeez.net/blog/how-to-use-the-linux-traffic-control/)
[5] [Introducing Foreman](http://blog.daviddollar.org/2011/05/06/introducing-foreman.html)