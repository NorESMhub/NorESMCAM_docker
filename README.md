# NorESM_docker

Test a simple NorESM configuration with docker

CESM docker container for 1850_CAM60%NORESM_CLM50%SP_CICE%PRES_DOCN%DOM_MOSART_SGLC_SWAV compset and resolution f19_tn14.

- Input dataset is stored and available in zenodo (5.8GB)

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3542460.svg)](https://doi.org/10.5281/zenodo.3542460)

## Running NorESM-CAM6 with docker

### NorESM source code

The [NorESM](https://noresm-docs.readthedocs.io/en/latest/) source code is not freely available so we assumed you have access to the private [Noresm-dev repository](https://github.com/metno/noresm-dev):

```
mkdir -p /opt/uio/packages
cd /opt/uio/packages
git clone -b featureCESM2.1.0-OsloDevelopment https://github.com/metno/noresm-dev.git

# Remove obsolete python 2 prints
sed -i.bak 's/print /#AF print /' noresm-dev/cime/scripts/Tools/../../scripts/lib/CIME/case/case_submit.py
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
docker run -i -v /opt/uio/inputdata:/home/cesm/inputdata -v /opt/uio/archive:/home/cesm/archive \
              -v /opt/uio/packages:/home/cesm/packages -t nordicesmhub/noresm:latest
```

- We are running 5 days using 8 processors. With this configuration, it uses about 1.3GB per processors.

```
  total pes active           : 8
  mpi tasks per node               : 4
  pe count for cost estimate : 8

  Overall Metrics:
    Model Cost:             660.29   pe-hrs/simulated_year
    Model Throughput:         0.29   simulated_years/day

    Init Time   :     162.902 seconds
    Run Time    :    4070.297 seconds      814.059 seconds/day
    Final Time  :       0.005 seconds
```
