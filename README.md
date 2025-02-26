# ASTRA-sim 2.0
ASTRA-sim is a distributed machine learning system simulator, developed as a joint collaboration between Georgia Tech, Meta, and Intel.
The previous version, ASTRA-sim 1.0, is available in the `ASTRA-sim-1.0` [branch](https://github.com/astra-sim/astra-sim/tree/ASTRA-sim-1.0).

Here is a concise visual summary of our simulator:
![alt text](https://github.com/astra-sim/astra-sim/blob/master/docs/images/astrasim_overview_codesign.png)

For a comprehensive understanding of the tool, and to gain insights into its capabilities, please refer to our paper:

William Won, Taekyung Heo, Saeed Rashidi, Srinivas Sridharan, Sudarshan Srinivasan, and Tushar Krishna, "ASTRA-sim2.0: Modeling Hierarchical Networks and Disaggregated Systems for Large-model Training at Scale". In Proceedings of the IEEE International Symposium on Performance Analysis of Systems and Software (ISPASS), April 2023. [[pdf]](https://arxiv.org/pdf/2303.14006.pdf) [[slides]](https://astra-sim.github.io/assets/papers/astra-sim2/ASTRA-sim2-ISPASS_2023.pdf) [[video]](https://youtu.be/QGilXx_GEXs?si=CPSZxvGDEm56iOp6)

For tutorials on how to use ASTRA-sim, please visit our [tutorial page](https://astra-sim.github.io/).

## Citation
If you use ASTRA-sim in your research, please cite our paper:
```
@inproceedings{astrasim2,
    author={Won, William and Heo, Taekyung and Rashidi, Saeed and Sridharan, Srinivas and Srinivasan, Sudarshan and Krishna, Tushar},
    booktitle={2023 IEEE International Symposium on Performance Analysis of Systems and Software (ISPASS)},
    title={ASTRA-sim2.0: Modeling Hierarchical Networks and Disaggregated Systems for Large-model Training at Scale},
    year={2023},
    pages={283-294},
    doi={10.1109/ISPASS57527.2023.00035}
}
```

## Build Instructions
ASTRA-sim can be built either (i) in your local environment or (ii) within a Docker container.
The following steps will guide you through both methods.

### 1. Build ASTRA-sim Locally
#### (i) Installing Dependencies
To build ASTRA-sim locally, you first need to install the necessary packages.

- #### Debian-based Linux Distribution
For Debian-based Linux distributions, including Ubuntu, you can install dependencies using the following commands:
```bash
$ sudo apt update
$ sudo apt upgrade
$ sudo apt install \
    gcc g++ make cmake \
    libboost-dev libboost-program-options-dev \
    libprotobuf-dev protobuf-compiler \
    python3 python3-pip git
```

NOTE: For the ns3 backend `python2`, `gcc-5.0` and `g++-5.0` are also required. This is because the ns3 backend is based on an older ns3 version. We recommend using virtual environments to isolate python instances. Even with the ns3 backend, `python3` is still used to create the workload using Chakra.

- #### macOS
For macOS, you can first install required dependencies using [homebrew](https://brew.sh). (Note: The ns3 backend has not yet been confirmed to build within macOS)
```bash
$ brew update
$ brew upgrade
$ brew install boost cmake coreutils
```

Then, you have to install protobuf 3.6.1 locally. You can download protobuf 3.6.1 here: [[GitHub]](https://github.com/protocolbuffers/protobuf/releases/tag/v3.6.1) [[protobuf-all-3.6.1.tar.gz]](https://github.com/protocolbuffers/protobuf/releases/download/v3.6.1/protobuf-all-3.6.1.tar.gz).
```bash
# Installing protobuf 3.6.1 locally
$ ./configure
$ make -j$(nproc)
$ make check -j$(nproc)  # checking compilation finished successfully
$ sudo make install  # register protobuf to PATH
$ which protoc  # system should be able to locate protoc
$ protoc --version  # should be 3.6.1
```

- #### Windows
ASTRA-sim is not natively supporting Windows environment at this moment. We suggest to use Docker or Windows Subsystem for Linux ([WSL](https://learn.microsoft.com/en-us/windows/wsl/install)).

#### (ii) Installing Required Python Packages
Now, you can install required Python packages, either through conda or pip3.

- #### Conda
If you are managing Python environments through conda, you can run below commands to create a new environment for astra-sim.
```bash
$ conda create -n astra-sim python=3.7
$ conda activate astra-sim
$ conda install protobuf=3.6.1 graphviz python-graphviz pydot
```

- #### pip3
You can also install required Python packages natively using pip3.
```bash
$ pip3 install --upgrade pip
$ pip3 install protobuf==3.6.1 pydot
```

#### (iii) Downloading ASTRA-sim

Once the packages are installed, you will need to clone this repository onto your local machine using the following command:
```bash
$ git clone --recurse-submodules git@github.com:astra-sim/astra-sim.git
$ cd ./astra-sim/
```

#### (iv) Compiling ASTRA-sim
Then, based on your target network backend, execute the corresponding build script:
```bash
# For the analytical network backend
$ ./build/astra_analytical/build.sh

# For the ns3 network backend. Python2 required.
$ ./build/astra_ns3/build.sh -c
```

### 2. Build ASTRA-sim in a Docker Image
Alternatively, you can build ASTRA-sim within a Docker container. (Note: The ns3 backend has not yet been confirmed to build within a Docker image)

Start by cloning this repository to your local machine using the same command as above:
```bash
$ git clone --recurse-submodules git@github.com:astra-sim/astra-sim.git
$ cd ./astra-sim/
```

Next, create a Docker image using the following command:
```bash
$ docker build -t astra-sim .
```

Once the Docker image is created, you can run it with this command:
```bash
$ docker run -it astra-sim
```

Finally, similar to the local build process, depending on your target network backend, you should run the corresponding build script:
```bash
# For the analytical network backend
$ ./build/astra_analytical/build.sh
```

## Running ASTRA-sim
Once ASTRA-sim is built, conduct experiments by passing the required configurations.
You might need to provide additional configurations based on the network backend.
The following configurations are mandatory:
* --workload-configuration: Path prefix to the execution trace. The naming rule for execution traces follows the format `{path prefix}.{npu_id}.et`. This argument provides the path prefix.
* --system-configuration: Path to the system configuration. Example system configurations can be found at `./inputs/system/`.
* --network-configuration: Path to the network configuration Example network configurations can be found at `./inputs/network/`.

Execution traces can be created using Chakra tools. You have the option of using either [the execution trace generator (et_generator)](https://github.com/chakra-et/chakra#execution-trace-generator-et_generator)
or [the execution trace converter (et_converter)](https://github.com/chakra-et/chakra#execution-trace-converter-et_converter).
The et_generator can be used to define and generate any execution traces, functioning as a test case generator. Meanwhile, the et_converter is a trace schema conversion tool, supporting PyTorch and FlexFlow execution traces, as well as ASTRA-sim 1.0 input files.

### Using the Execution Trace Generator
You can generate execution traces with et_generator with the following commands.
```bash
$ cd ./extern/graph_frontend/chakra
$ pip3 install .
$ python3 -m chakra.et_generator.et_generator --num_npus 64 --num_dims 1
```

To run one of the example traces (`one_comm_coll_node_allreduce`), execute the following command.
```bash
# For the analytical network backend
$ cd -
$ ./build/astra_analytical/build/bin/AstraSim_Analytical_Congestion_Unaware \
  --workload-configuration=./extern/graph_frontend/chakra/one_comm_coll_node_allreduce \
  --system-configuration=./inputs/system/Switch.json \
  --network-configuration=./inputs/network/analytical/Switch.yml \
  --remote-memory-configuration=./inputs/remote_memory/analytical/no_memory_expansion.json

# For the ns3 network backend. Python2 required.
# After editing the configuration files in the following script
$ ./build/astra_ns3/build.sh -r

# Or, alternatively:
$ cd ./extern/network_backend/ns3/simulation
$ ./waf --run "scratch/AstraSimNetwork \
  --workload-configuration=../../../../extern/graph_frontend/chakra/one_comm_coll_node_allreduce \
  --system-configuration=../../../../inputs/system/Switch.json \
  --network-configuration=mix/config.txt \
  --remote-memory-configuration=../../../../inputs/remote_memory/analytical/no_memory_expansion.json \
  --logical-topology-configuration=../../../../inputs/network/ns3/sample_64nodes_1D.json \
  --comm-group-configuration=\"empty\""
$ cd -
```

Upon completion, ASTRA-sim will display the number of cycles it took to run the simulation.
```bash
sys[0] finished, 50904 cycles
sys[1] finished, 50904 cycles
...
sys[62] finished, 50904 cycles
sys[63] finished, 50904 cycles
```

### Using the Execution Trace Converter
You can convert ASTRA-sim 1.0 text input files into Chakra traces with the following commands.
```bash
$ cd ./extern/graph_frontend/chakra/
$ pip3 install .
$ python3 -m chakra.et_converter.et_converter \
    --input_type Text \
    --input_filename ../../../inputs/workload/ASTRA-sim-1.0/Resnet50_DataParallel.txt \
    --output_filename ../../../inputs/workload/ASTRA-sim-2.0/Resnet50_DataParallel \
    --num_npus 64 \
    --num_dims 1 \
    --num_passes 1
```

Run the following command.
```bash
$ cd -
$ ./build/astra_analytical/build/bin/AstraSim_Analytical_Congestion_Unaware \
  --workload-configuration=./inputs/workload/ASTRA-sim-2.0/Resnet50_DataParallel \
  --system-configuration=./inputs/system/Switch.json \
  --network-configuration=./inputs/network/analytical/Switch.yml \
  --remote-memory-configuration=./inputs/remote_memory/analytical/no_memory_expansion.json

# Similarly, for ns3, run the previous command while only changing the workload.
```

Upon completion, ASTRA-sim will display the number of cycles it took to run the simulation.
```bash
sys[62] finished, 6749042 cycles
sys[61] finished, 6749042 cycles
...
sys[0] finished, 6749042 cycles
sys[63] finished, 6749042 cycles
```

### Using Chakra Execution Trace and Kineto Traces Generated By PyTorch
By adding a few lines to any PyTorch workload, you can generate the PyTorch Execution Trace (ET) and Kineto traces for each GPU (and its corresponding CPU thread).
Details on how to tweak the PyTorch files to get PyTorch-ET and Kineto traces can be found elsewhere (we'll throw in some guidelines later).
With these traces for each GPU, we merge the PyTorch-ET and Kineto trace into a single enhanced ET.
From there, it's all about feeding this enhanced ET into a converter that converts the enhanced ET into the Chakra format.
```bash
# First, navigate to the param submodule where you'll find sample Pytorch-ET and Kineto input files and that handy merger script
$ cd extern/graph_frontend/param/train/compute/python/
$ pip3 install -r requirements.txt
$ pip3 install .

# Second, unzip the input files
$ cd ./test/data
$ tar -xzf dlrm_kineto.tar.gz
$ tar -xzf dlrm_pytorch_et.tar.gz
$ cd ../../

# Now, we'll fire up the script that leverages the already whipped up Pytorch-ET+Kineto traces (from a single training loop of DLRM on 8 GPUs) and fuses them into that enhanced ET we keep talking about
$ python3 ./tools/trace_link.py --et-file test/data/dlrm_pytorch_et/dlrm_eg_0.json --kineto-file test/data/dlrm_kineto/worker0* --exact-match --annotation 'enumerate(DataLoader)#_MultiProcessingDataLoaderIter.__next__'
$ python3 ./tools/trace_link.py --et-file test/data/dlrm_pytorch_et/dlrm_eg_1.json --kineto-file test/data/dlrm_kineto/worker1* --exact-match --annotation 'enumerate(DataLoader)#_MultiProcessingDataLoaderIter.__next__'
$ python3 ./tools/trace_link.py --et-file test/data/dlrm_pytorch_et/dlrm_eg_2.json --kineto-file test/data/dlrm_kineto/worker2* --exact-match --annotation 'enumerate(DataLoader)#_MultiProcessingDataLoaderIter.__next__'
$ python3 ./tools/trace_link.py --et-file test/data/dlrm_pytorch_et/dlrm_eg_3.json --kineto-file test/data/dlrm_kineto/worker3* --exact-match --annotation 'enumerate(DataLoader)#_MultiProcessingDataLoaderIter.__next__'
$ python3 ./tools/trace_link.py --et-file test/data/dlrm_pytorch_et/dlrm_eg_4.json --kineto-file test/data/dlrm_kineto/worker4* --exact-match --annotation 'enumerate(DataLoader)#_MultiProcessingDataLoaderIter.__next__'
$ python3 ./tools/trace_link.py --et-file test/data/dlrm_pytorch_et/dlrm_eg_5.json --kineto-file test/data/dlrm_kineto/worker5* --exact-match --annotation 'enumerate(DataLoader)#_MultiProcessingDataLoaderIter.__next__'
$ python3 ./tools/trace_link.py --et-file test/data/dlrm_pytorch_et/dlrm_eg_6.json --kineto-file test/data/dlrm_kineto/worker6* --exact-match --annotation 'enumerate(DataLoader)#_MultiProcessingDataLoaderIter.__next__'
$ python3 ./tools/trace_link.py --et-file test/data/dlrm_pytorch_et/dlrm_eg_7.json --kineto-file test/data/dlrm_kineto/worker7* --exact-match --annotation 'enumerate(DataLoader)#_MultiProcessingDataLoaderIter.__next__'

$ mkdir ./test/data/et_plus
$ mv ./test/data/dlrm_pytorch_et/*_plus.json ./test/data/et_plus/

# Next, shuffle the enhanced ETs over to the chakra submodule for that transformation into Chakra goodness
$ mv test/data/et_plus ../../../../../graph_frontend/chakra/
$ cd ../../../../../graph_frontend/chakra/
$ pip3 install .

# Almost there! The script below will make those enhanced PyTorch-ETs dance in Chakra format, getting them all prepped for a session with astrasim
$ python3 -m chakra.et_converter.et_converter --input_type PyTorch --input_filename et_plus/dlrm_eg_0_plus.json --output_filename et_plus/dlrm_chakra.0.et --num_dims 1
$ python3 -m chakra.et_converter.et_converter --input_type PyTorch --input_filename et_plus/dlrm_eg_1_plus.json --output_filename et_plus/dlrm_chakra.1.et --num_dims 1
$ python3 -m chakra.et_converter.et_converter --input_type PyTorch --input_filename et_plus/dlrm_eg_2_plus.json --output_filename et_plus/dlrm_chakra.2.et --num_dims 1
$ python3 -m chakra.et_converter.et_converter --input_type PyTorch --input_filename et_plus/dlrm_eg_3_plus.json --output_filename et_plus/dlrm_chakra.3.et --num_dims 1
$ python3 -m chakra.et_converter.et_converter --input_type PyTorch --input_filename et_plus/dlrm_eg_4_plus.json --output_filename et_plus/dlrm_chakra.4.et --num_dims 1
$ python3 -m chakra.et_converter.et_converter --input_type PyTorch --input_filename et_plus/dlrm_eg_5_plus.json --output_filename et_plus/dlrm_chakra.5.et --num_dims 1
$ python3 -m chakra.et_converter.et_converter --input_type PyTorch --input_filename et_plus/dlrm_eg_6_plus.json --output_filename et_plus/dlrm_chakra.6.et --num_dims 1
$ python3 -m chakra.et_converter.et_converter --input_type PyTorch --input_filename et_plus/dlrm_eg_7_plus.json --output_filename et_plus/dlrm_chakra.7.et --num_dims 1

# And, as all good things come to an end, head back home to the root directory of astrasim
$ cd ../../../

# Update network topology
$ vi ./inputs/network/analytical/FullyConnected.yml

npus_count: [ 8 ]  # number of NPUs
```

Run the following command.

```bash
# This is a sample script that runs astrasim with the sample chakra files of DLRM that we just created

$ ./build/astra_analytical/build/bin/AstraSim_Analytical_Congestion_Unaware \
  --workload-configuration=./extern/graph_frontend/chakra/et_plus/dlrm_chakra \
  --system-configuration=./inputs/system/FullyConnected.json \
  --network-configuration=./inputs/network/analytical/FullyConnected.yml \
  --remote-memory-configuration=./inputs/remote_memory/analytical/no_memory_expansion.json
```

Upon completion, ASTRA-sim will display the number of cycles it took to run the simulation.
```bash
ring of node 0, id: 0 dimension: local total nodes in ring: 8 index in ring: 0 offset: 1total nodes in ring: 8
ring of node 0, id: 0 dimension: local total nodes in ring: 8 index in ring: 0 offset: 1total nodes in ring: 8
...
sys[0] finished, 13271344 cycles
sys[1] finished, 14249000 cycles
```

## Enable Roofline Models
ASTRA-sim 2.0 supports two computational performance models: the measured runtime model and the roofline model. You can enable the roofline model by setting the 'roofline-enabled' field to 1 in the system configuration file. Additionally, specify the local memory bandwidth (in GB/sec) and peak performance (in TFLOPS).
```
...
"roofline-enabled": 1,
"local-mem-bw": 50,
"peak-perf": 2000,
...
```
When creating execution traces, ensure to include the number of floating point operations and the tensor size for each compute operator.


## Enable Communicator Groups
ASTRA-sim 2.0 supports [communicator groups](https://docs.nvidia.com/deeplearning/nccl/user-guide/docs/usage/communicators.html).
You can pass a communicator group configuration file by specifying the file path using `--comm-group-configuration`.
If you do not pass a communicator group configuration file, by default, it will create a single group with all GPUs.
A valid communication group file is a JSON file with the following format.
```
{
  "<communicator_group_id>" : [gpu_ids]
}
```
For example, you can create two communicator groups with the following configuration file.
The first communicator group, with ID 0, includes GPU IDs from 0 to 3. The second communicator group, with ID 1, includes GPU IDs from 4 to 7.
```
{
  "0": [0, 1, 2, 3],
  "1": [4, 5, 6, 7]
}
```

## Features Under Active Development
We are constantly working to improve ASTRA-sim and expand its capabilities. Here are some of the features that are currently under active development:

* Network Backends
    * Garnet (for chiplet fabrics)
* Detailed Statistics Report (Network Utilization)
 
Please note that these features are under active development and, while we aim to have them available as soon as possible, the completion timeline can vary. Check back regularly for updates on the progress of these and other features. This is an open-source project and we also value PRs from the community on features they have added.

We appreciate your interest and support in ASTRA-sim!


## Contact Us
For any questions about using ASTRA-sim, you can email the ASTRA-sim User Mailing List: astrasim-users@googlegroups.com

To join the mailing list, please fill out the following form: https://forms.gle/18KVS99SG3k9CGXm6

This project is a collaboration of dedicated professionals. The core developers and contributors are acknowledged below.

| Developer | Organization | Responsibility |
|-----------|--------------|----------------|
| Saeed Rashidi | Hewlett Packard Labs | ASTRA-sim 1.0, system layer, collective communication |
| William Won | Georgia Tech | Network layer |
| Taekyung Heo | Georgia Tech | Chakra, workload layer, graph execution engine, memory API |
| Changhai Man | Georgia Tech | Chakra |
| Jinsun Yoo   | Georgia Tech | NS3 Network Layer Integration |
| Srinivas Sridharan | NVIDIA | Chakra, General inquiries |
| Tushar Krishna | Georgia Tech | General inquiries |
