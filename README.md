# NorESM_docker

Test a simple NorESM configuration with docker

NorESM docker container for 1850_CAM60%NORESM_CLM50%SP_CICE%PRES_DOCN%DOM_MOSART_SGLC_SWAV compset and resolution f19_tn14.

- A tarbal was prepared for this particular simulation with all the necessary input dataset and it is available on zenodo (3.1 GB)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4501307.svg)](https://doi.org/10.5281/zenodo.4501307)

## Running NorESM-CAM6 with docker

### NorESM source code

The [NorESM](https://noresm-docs.readthedocs.io/en/latest) source code is now freely available from https://github.com/NorESMhub

```
mkdir -p /opt/uio/packages
cd /opt/uio/packages
git clone -b release-noresm2.0.2 https://github.com/NorESMhub/NorESM.git

cd NorESM
rm -rf manage_externals
git clone -b manic-v1.1.8 https://github.com/ESMCI/manage_externals.git
sed -i.bak "s/'checkout'/'checkout', '--trust-server-cert', '--non-interactive'/" ./manage_externals/manic/repository_svn.py
./manage_externals/checkout_externals -v
```

The NorESM source code is then passed to the docker container for running norESM.

### NorESM docker

Make sure inputdata and norESM source code are available (it won't download them as we suppose they both are already on disk). 
- The location of the inputdata is `/opt/uio/inputdata` 
- The location of the norESM source code is `/opt/uio/packages/noresm-dev` 
- Model outputs are stored in `/opt/uio/archive` along with the `case` folder (it can be interesting to check timing).

**Important**: the folder /opt/uio/archive needs to be writable by unix group `users` (see Dockerfile) otherwise you will get a permission denied when running.

```
sudo chgrp -R users /opt/uio/archive
sudo chmod -R g+w /opt/uio/archive
```

You can check it:

```
ls -lrt /opt/uio | grep archive
```

You should have:

```
drwxrwxr-x.  8 centos users        4096 Nov  9 15:21 archive
```

### Pull and run images

```
docker pull nordicesmhub/noresm:latest
docker run --shm-size 8G -i -v /opt/uio/inputdata:/home/cesm/inputdata -v /opt/uio/archive:/home/cesm/archive \
                            -v /opt/uio/packages:/home/cesm/packages -t nordicesmhub/noresm:latest
```

- Here we are running a 5 days simulation using only 4 processors (which is really not much), and with this configuration we allocate 2GB per processor (this typically makes it possible to run on a laptop/desktop)

- The case directory will remain available outside the container (in a folder called for thie example /opt/uio/archive/cases/cN1850)

```
  total pes active           : 4
  mpi tasks per node               : 4
  pe count for cost estimate : 4

  Overall Metrics:
    Model Cost:             655.24   pe-hrs/simulated_year
    Model Throughput:         0.15   simulated_years/day

    Init Time   :     375.254 seconds
    Run Time    :    8078.297 seconds     1615.659 seconds/day
    Final Time  :       1.535 seconds

```
You can now exit the container.

### To return into the same container

Find the Container ID:
```
docker ps --all

CONTAINER ID        IMAGE                        COMMAND             CREATED             STATUS                      PORTS               NAMES
d40294d23839        nordicesmhub/noresm:latest   "/bin/bash"         25 minutes ago      Exited (0) 59 seconds ago                       objective_meitner
```

Then execute:
```
docker start d40294d23839
d40294d23839
```

You can check that the container is now up again:
```
docker ps --all
CONTAINER ID        IMAGE                        COMMAND             CREATED             STATUS              PORTS               NAMES
d40294d23839        nordicesmhub/noresm:latest   "/bin/bash"         25 minutes ago      Up 2 seconds                            objective_meitner
```

and go back into it by typing:
```
docker exec -it d40294d23839 bash
cesm@d40294d23839:~$ ls
archive  cases  inputdata  packages  run_noresm  work
```
