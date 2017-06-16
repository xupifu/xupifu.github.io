---
title: Sysbench OLTP Benchmark
date: 2017-02-10 19:39:11
categories: storage
tags: benchmark
---

Original link: http://www.storagereview.com/sysbench_oltp_benchmark

The Sysbench OLTP application benchmark runs on top of a MySQL database running the InnoDB storage engine. The job of the storage engine is to manage the interface from the on-disk database to the applications reading and writing data to and from the storage engine. The storage engine in turn manages IO threads and logs, and it keeps an in-memory cache to minimize disk access. <!--more-->The chart below gives a simplistic overview of the engine.

![](http://www.storagereview.com/images/mysql-innodb-disk-memory-layout.png)

Since the InnoDB engine keeps an in-memory cache called the buffer pool, performance wil be directly affected by the ratio of the working set size to the size of the buffer pool. In other words, if the buffer pool is large enough to hold the working set or the working set is small enough to fit in the buffer pool, most operations will never be IO bound. However, if the database is too large to fit into memory, then IO performance will dictate transactional response times and throughput. We are characterizing the performance of the drive in this situation where the database does not fit in memory, which leads to increased IO traffic from the InnoDB storage engine.

Multiple threads (the number depends on database configuration for high performance applications and varies from 32 to 128) read data in a random fashion from the backing store with a block size of 16Kbytes. These reads are related to database queries requesting data from the backing store. As reads are processed, they are automatically cached in the buffer pool. As the buffer pool fills up, InnoDB uses a LRU (Least Recently Used) policy to evict older pages to make room for newer data.

Database writes are first directed to the transaction log and to the buffer pool. The transaction log is a sequentially written ring buffer that is updated for every write transaction. Depending on the MySQL configuration, this update can lead to an immediate on-disk write, or it can persist temporarily in RAM as a buffer that is eventually flushed to disk by the file system. The size of this log buffer varies, but is usually around 256MB. Recommended settings for ACID compliance require that the log writes hit the disk on every database commit. These writes are 4K in length.

The log only does "physiological" writes where the delta between the previous data and the new data is written. For the original data, InnoDB writes to the buffer pool in RAM, which has to be drained asynchronously as well. The process of writing out the data back to the file system is configurable and occurs in the background. The writes are also 16K. The writes are actually double-writes where the engine first writes the data into an intermediary location called the double-write buffer. The engine then copies that data into its final location in the file system. This is necessary to avoid the "torn page" problem where a 16KB database page is partially written to disk due to a power loss or other catastrophic event.

## Origins of the Sysbench Benchmark

We brought the Sysbench test setup into our lab after several conversations with [Micron](http://www.micron.com/products/solid-state-storage) about how they simulate real-world MySQL application environments for SSD testing and measurement. They developed a test methodology around Sysbench after finding that synthetic storage benchmarks rarely provided a complete view of how a drive will behave when under a particular application workload. The Sysbench test allows Micron to simulate an environment that most closely represents a standard MySQL database workload, which are prevalent in applications such as Facebook, Craigslist and Booking.com

We worked particularly closely with Moussa Ba, who helped co-author this article. Moussa is a software engineer on Micron’s PCIe development team where his work includes application and system software optimization for high performance IO devices.

## Sysbench OLTP Benchmark

Sysbench is a system performance benchmark that includes an OnLine Transaction Processing (OLTP) test profile. The OLTP test is not an approximation of an OLTP test, but is rather a true database-backed benchmark that conducts transactional queries to an instance of MySQL in a CentOS environment.

The first step in setting up the benchmark is to create the database itself, which is done by specifying the number of tables in the database as well the number of rows per table. In our test, we defined 100 tables with 10 million rows each, which resulted in a database of 1 billion entries. This database was 260GB.

Sysbench has two operating modes: default mode which reads and writes to the database and a readonly mode. The default R/W mode will execute the following query types: 5 SELECT queries, 2 UPDATE queries, 1 DELETE query and 1 INSERT. Looking at IO counts, the observed read/write ratio is about 75% reads and 25% writes.

## Sysbench Testing Environment

Storage solutions are tested with the Sysbench OLTP benchmark in the [StorageReview Enterprise Test Lab](http://www.storagereview.com/storagereview_enterprise_test_lab) utilizing stand-alone servers. We currently utilize off-the-shelf channel PowerEdge R730s from Dell to show both realistic performance and a solid price/performance ratio, changing only the storage adapter or network interface to connect our R730 to different storage products. The PowerEdge R730 has proven itself to offer great compatibility with third-party devices, making it an excellent go-to platform for this diverse testing environment. The R730 also leverages Intel's powerful Haswell-class architecture, which gives us the compute power to properly stress a wide range of storage offerings and maximize their performance potential. 

### First Generation Sysbench Benchmark Environment

[Lenovo ThinkServer RD630](http://www.storagereview.com/lenovo_thinkserver_rd630_review) - SATA/SAS/PCIe Testing Platform

*   2594-ABU Topseller Model
*   Dual Intel E5-2650 CPUs (2.0GHz, 8-cores, 20MB Cache)
*   128GB RAM (8GB x 16 DDR3, 64GB per CPU)
*   100GB Micron [RealSSD P400e SSD](http://www.storagereview.com/micron_realssd_p400e_enterprise_ssd_review) (via LSI 9207-8i) Boot Drive
*   960GB Micron M500 (via 9207-8i) Pre-built Database Storage
*   CentOS 6.3 64-bit
*   Percona XtraDB 5.5.30-rel30.1
    +   Database Tables: 100
    +   Database Size: 10,000,000
    +   Database Threads: 32
    +   RAM Buffer: 24GB

### Second Generation Sysbench Benchmark Environment

Dell PowerEdge R730 - SATA/SAS/PCIe Testing Platform

*   Dual Intel E5-2690 v3 CPUs (2.6GHz, 12-cores, 30MB Cache) 
*   256GB RAM (16GB x 16 DDR4, 128GB per CPU)
*   100GB Boot SSD, 480GB Database Storage SSD
*   2 x Mellanox ConnectX-3 InfiniBand Adapter
*   2 x [Emulex 16GB dual-port FC HBA](http://www.storagereview.com/emulex_lightpulse_gen5_16gb_fibre_channel_hba_review)
*   2 x [Emulex 10GbE dual-port NIC](http://www.storagereview.com/emulex_oneconnect_oce11102nt_review)
*   CentOS 6.6 64-bit
*   Percona XtraDB 5.5.30-rel30.1
    +   Database Tables: 100
    +   Database Size: 10,000,000
    +   Database Threads: 32
    +   RAM Buffer: 24GB

Dell PowerEdge R730 Virtualized Sysbench 4-node Cluster

*   Eight Intel E5-2690 v3 CPUs for 249GHz in cluster (Two per node, 2.6GHz, 12-cores, 30MB Cache) 
*   1TB RAM (256GB per node, 16GB x 16 DDR4, 128GB per CPU)
*   SD Card Boot (Lexar 16GB)
*   4 x Mellanox ConnectX-3 InfiniBand Adapter (vSwitch for vMotion and VM network)
*   4 x [Emulex 16GB dual-port FC HBA](http://www.storagereview.com/emulex_lightpulse_gen5_16gb_fibre_channel_hba_review)
*   4 x [Emulex 10GbE dual-port NIC](http://www.storagereview.com/emulex_oneconnect_oce11102nt_review)
*   VMware ESXi vSphere 6.0 / Enterprise Plus 8-CPU

The main goal with this platform is highlighting how enterprise storage performs in an actual enterprise environment and workload, instead of relying on synthetic or pseudo-synthetic workloads. Synthetic workload generators are great at showing how well storage devices perform with a continuous synthetic I/O pattern, but they don't take into consideration any of the other outside variables that illuminate how devices actually work in production environments. Synthetic workload generators have the benefit of showing a clean I/O pattern time and time again, but they won't ever replicate a true production environment. Introducing application performance on top of storage products begins to show how well the storage interacts with its drivers, the local operating system, the application being tested, the network stack, the networking switching and external servers. These are variables that a synthetic workload generator simply can't take into account, and they are also an order of magnitude more resource- and infrastructure-intensive in terms of the equipment required to execute this particular benchmark.

## Overall Sysbench Performance Results

We test a wide range of storage solutions with the Sysbench OLTP benchmark that meet the minimum requirements of the testing environment. To qualify for testing, the storage device must have a usable capacity exceeding 260GB and be geared towards operating under stressful enterprise conditions. Locally-attached storage devices such as SAS, SATA and PCIe SSDs are tested on a bare-metal server with one Sysbench instance. Newer SAN and Hyper-converged platforms run either 4, 8, 12 or 16 VMs simultaneously to show how well multiple workloads operate at the same time on each. This testing methology helps demystify the performance comparisons between newer hyper-converged systems against traditional SAN storage arrays.

### Hyper-Converged / SAN Virtualized Sysbench Performance Results (16 VM Aggregate)

| Device | 32-Thread Aggregate TPS | Average Response Time (ms) | 99th Percentile Latency (ms) |
|--|--|--|--|
| [X-IO ISE 860](http://www.storagereview.com/xio_technologies_ise_860_g3_review_part_1)<br>(4) Dell R730, X-IO ISE 860 AFA<br>(2) 10TB Volumes | 6625 |  80 |  418 |

### Hyper-Converged / SAN Virtualized Sysbench Performance Results (12 VM Aggregate)


| Device | 32-Thread Aggregate TPS | Average Response Time (ms) | 99th Percentile Latency (ms) |
|--|--|--|--|
| [X-IO ISE 860](http://www.storagereview.com/xio_technologies_ise_860_g3_review_part_1)<br>(4) Dell R730, X-IO ISE 860 AFA<br>(2) 10TB Volumes | 7160 |  54 |  177 |

### Hyper-Converged / SAN Virtualized Sysbench Performance Results (8 VM Aggregate)


| Device | 32-Thread Aggregate TPS | Average Response Time (ms) | 99th Percentile Latency (ms) |
|--|--|--|--|
| [X-IO ISE 860](http://www.storagereview.com/xio_technologies_ise_860_g3_review_part_1)<br>(4) Dell R730, X-IO ISE 860 AFA<br>(2) 10TB Volumes | 6568 |  39 |  83 |
| [VMware VSAN (ESXi 6.0)](http://www.storagereview.com/vmware_virtual_san_review_sysbench_oltp_performance)<br>(4) Dell R730xd, 80 1.2TB HDDs, 16 800GB SSDs | 4259 |  60 |  131 |

### Hyper-Converged / SAN Virtualized Sysbench Performance Results (4 VM Aggregate)

| Device | 32-Thread Aggregate TPS | Average Response Time (ms) | 99th Percentile Latency (ms) | Peak Latency (ms) |
|--|--|--|--|--|
| [DotHill Ultra48 Hybrid](http://www.storagereview.com/dot_hill_assuredsan_ultra48_hybrid_review)<br>(4) Dell R730, DotHill Ultra48 Hybrid<br>(2) 14-disk RAID1 Pools, 40 1.8TB HDDs, 8 400GB SSDs | 4645 |  28 |  51 |  676 |
| [X-IO ISE 860](http://www.storagereview.com/xio_technologies_ise_860_g3_review_part_1)<br>(4) Dell R730, X-IO ISE 860 AFA<br>(2) 10TB Volumes | 4424 |  29 |  57 |  983 |
| [VMware VSAN (ESXi 6.0)](http://www.storagereview.com/vmware_virtual_san_review_sysbench_oltp_performance)<br>(4) Dell R730xd, 80 1.2TB HDDs, 16 800GB SSDs | 2830 |  45 |  94 |  480 |
| Nutanix NX-8150 (ESXi 6.0)<br>(4) NX-8150, 80 1TB HDDs, 16 800GB SSDs RAID0 x 4 vDisk Database Volume | 2390 |  54 |  173 |  4784 |
| Nutanix NX-8150 (ESXi 6.0)<br>(4) NX-8150, 80 1TB HDDs, 16 800GB SSDs Default Database Deployment | 1422 |  90 |  216 |  5508 |

### PCIe Application Accelerator / Multi-SSD/HDD RAID Sysbench Performance Results 

| Device | 32-Thread Average TPS | Average Response Time | 99th Percentile Latency |
|--|--|--|--|
| [Huawei ES3000 2.4TB](http://www.storagereview.com/huawei_tecal_es3000_application_accelerator_review)<br>MLC PCIe SSD x 1 | 2734.69 |  11.7 |  19.84 |
| [Huawei ES3000 1.2TB](http://www.storagereview.com/huawei_tecal_es3000_application_accelerator_review)<br>MLC PCIe SSD x 1 | 2615.12 |  12.23 |  21.80 |
| [Fusion ioDrive2 Duo 2.4TB](http://www.storagereview.com/fusionio_iodrive2_duo_mlc_application_accelerator_review)<br>MLC PCIe SSD x 1 | 2521.06 |  12.69 |  23.92 |
| [Micron P320h 700GB](http://www.storagereview.com/micron_realssd_p320h_enterprise_pcie_review)<br>SLC PCIe SSD x 1 | 2443.56 |  13.09 |  22.45 |
| [Micron P420m 1.4TB](http://www.storagereview.com/micron_p420m_enterprise_pcie_ssd_review)<br>MLC PCIe SSD x 1 | 2361.29 |  13.55 |  25.84 |
| [Fusion ioDrive2 1.2TB](http://www.storagereview.com/fusionio_iodrive2_duo_mlc_application_accelerator_review)<br>MLC PCIe SSD x 1 | 2354.06 |  13.59 |  29.35 |
| [Virident FlashMAX II 2.2TB](http://www.storagereview.com/virident_flashmax_ii_mlc_application_accelerator_review_22tb)<br>MLC PCIe SSD x 1 | 2278.11 |  14.04 |  26.04 |
| LSI Nytro WarpDrive 800GB<br>MLC PCIe SSD x 1 | 1977.67 |  16.18 |  39.94 |
| [LSI Nytro WarpDrive 400GB](http://www.storagereview.com/lsi_nytro_warpdrive_blp4400_application_accelerator_review)<br>MLC PCIe SSD x 1 | 1903.14 |  16.81 |  39.30 |

### Individual SAS / SATA SSD Results

| Device | 32-Thread Average TPS | Average Response Time | 99th Percentile Latency |
|--|--|--|--|
| [Toshiba HK3R2 960GB](http://www.storagereview.com/toshiba_hk3r2_review)<br>MLC SATA x 1 | 1673.23 | 19.12 | 49.65 |
| [SanDisk CloudSpeed Eco 960GB](http://www.storagereview.com/sandisk_cloudspeed_eco_review)<br>cMLC SATA x 1 | 1556.99 | 20.55 | 49.05 |
| [Intel S3700 800GB](http://www.storagereview.com/intel_ssd_dc_s3700_series_enterprise_ssd_review)<br>eMLC SATA x 1 | 1488.71 |  21.49 |  40 |
| [Toshiba PX02SM 400GB](http://www.storagereview.com/toshiba_px02sm_series_enterprise_ssd_review)<br>eMLC SAS (6Gb/s) x 1 | 1487.03 | 21.52 | 62.02 |
| [Smart Optimus 400GB](http://www.storagereview.com/smart_storage_systems_optimus_sas_enterprise_ssd_review)<br>eMLC SAS x 1 | 1477.1 | 21.66 | 52.69 |
| [OCZ Talos 2 C 480GB](http://www.storagereview.com/ocz_talos_2_enterprise_ssd_review)<br>MLC SAS x 1 | 1438.7 | 22.24 | 47.32 |
| [OCZ Intrepid 3600 400GB](http://www.storagereview.com/ocz_intrepid_3600_ssd_review)<br>eMLC SAS x 1 | 1335.3 | 23.96 | 48.42 |
| [OCZ Talos 2 R 400GB](http://www.storagereview.com/ocz_talos_2_enterprise_ssd_review)<br>eMLC SAS x 1 | 1421.15 | 22.51 | 45.06 |
| [SanDisk Extreme 480GB](http://www.storagereview.com/sandisk_extreme_ssd_review)<br>MLC SATA x 1 | 1303.48 | 24.55 | 53.56 |
| STEC s842 800GB<br>eMLC SAS x 1 | 1293.56 |  24.74 |  67.20 |
| [Intel S3500 512GB](http://www.storagereview.com/toshiba_hg6_ssd_review)<br>eMLC SATA x 1 | 1,287.65 | 24.85 | 64.15 |
| [Intel S3500 480GB](http://www.storagereview.com/intel_ssd_dc_s3500_enterprise_review)<br>eMLC SATA x 1 | 1241.59 |  25.77 |  54.27 |
| [Seagate 600 Pro 400GB](http://www.storagereview.com/seagate_600_pro_enterprise_ssd_review)<br>eMLC SATA x 1 | 1198.2 |  26.7 |  62.69 |
| [Hitachi SSD400S.B 400GB](http://www.storagereview.com/hitachi_ultrastar_ssd400sb_enterprise_ssd_review)<br>SLC SAS x 1 | 1191.47 |  26.85 |  47.87 |
| [OCZ Vector 512GB](http://www.storagereview.com/ocz_vector_ssd_review)<br>MLC SATA x 1 | 1130.03 |  28.32 |  62.67 |
| [SanDisk Extreme II 480GB](http://www.storagereview.com/sandisk_extreme_ii_ssd_review)<br>MLC SATA x 1 | 981.34 |  32.61 |  102.58 |
| [Hitachi SSD400M](http://www.storagereview.com/hitachi_ultrastar_ssd400m_enterprise_ssd_review)<br>eMLC SAS x 1 | 878.9 |  36.41 |  68.03 |
| [Toshiba eSSD](http://www.storagereview.com/toshiba_mkx001grzb_enterprise_ssd_review)<br>SLC SAS x 1 | 758.41 |  42.19 |  140.59 |
| [Micron M500 480GB](http://www.storagereview.com/micron_m500_enterprise_ssd_review)<br>MLC SATA x 1 | 668.6 |  47.86 |  461.80 |

