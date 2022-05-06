### 程序CPU占用率飙升，如何定位线程的堆栈信息

#### 1. 获取java进程id

##### 1.1使用`jps`查看
```shell
~ » jps                             
2261 cpu-take-up-high-test-snapshot.jar
2957 Jps
1775 GradleDaemon
```
##### 1.2使用`ps`查看
*命令`echo $(ps -ef | grep  BootJarPath | grep -v grep | awk '{print $2}')`*
```shell
echo $(ps -ef | grep  cpu-take-up-high-test-snapshot.jar | grep -v grep | awk '{print $2}')
```

#### 2. 查看进程信息
使用命令`top -p <pid>`,显示java进程的CPU情况
```shell
top - 18:55:05 up 51 min,  1 user,  load average: 1.13, 1.09, 0.99
Tasks:   1 total,   0 running,   1 sleeping,   0 stopped,   0 zombie
%Cpu(s): 50.1 us,  0.3 sy,  0.0 ni, 49.6 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :  15969.0 total,  14534.9 free,    892.8 used,    541.3 buff/cache
MiB Swap:   4096.0 total,   4096.0 free,      0.0 used.  14792.5 avail Mem

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
   2261 dousx     20   0 3650172 217528  28384 S 100.0   1.3  26:42.24 java
```

#### 3. 按H(大写) 获取每个线程的CPU情况

找到内存和CPU占用最高的`tid`,第一列的`PID`就是`tid`,且值为`十进制`,比如:2263 
```shell
top - 18:55:19 up 51 min,  1 user,  load average: 1.10, 1.08, 0.99
Threads:  45 total,   1 running,  44 sleeping,   0 stopped,   0 zombie
%Cpu(s): 50.3 us,  0.0 sy,  0.0 ni, 49.4 id,  0.0 wa,  0.0 hi,  0.3 si,  0.0 st
MiB Mem :  15969.0 total,  14534.9 free,    892.8 used,    541.3 buff/cache
MiB Swap:   4096.0 total,   4096.0 free,      0.0 used.  14792.5 avail Mem

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
   2263 dousx     20   0 3650172 217528  28384 R  99.7   1.3  26:52.43 java
   2268 dousx     20   0 3650172 217528  28384 S   0.3   1.3   0:00.38 G1 Service
   2261 dousx     20   0 3650172 217528  28384 S   0.0   1.3   0:00.00 java
   2264 dousx     20   0 3650172 217528  28384 S   0.0   1.3   0:00.01 GC Thread#0
   2265 dousx     20   0 3650172 217528  28384 S   0.0   1.3   0:00.00 G1 Main Marker
   2266 dousx     20   0 3650172 217528  28384 S   0.0   1.3   0:00.01 G1 Conc#0
   2267 dousx     20   0 3650172 217528  28384 S   0.0   1.3   0:00.00 G1 Refine#0
   2272 dousx     20   0 3650172 217528  28384 S   0.0   1.3   0:00.07 VM Thread
   2275 dousx     20   0 3650172 217528  28384 S   0.0   1.3   0:00.00 Reference Handl
   2276 dousx     20   0 3650172 217528  28384 S   0.0   1.3   0:00.00 Finalizer
   2279 dousx     20   0 3650172 217528  28384 S   0.0   1.3   0:00.00 Signal Dispatch
   2280 dousx     20   0 3650172 217528  28384 S   0.0   1.3   0:00.00 Service Thread
   2281 dousx     20   0 3650172 217528  28384 S   0.0   1.3   0:00.06 Monitor Deflati
   2282 dousx     20   0 3650172 217528  28384 S   0.0   1.3   0:01.62 C2 CompilerThre
   2283 dousx     20   0 3650172 217528  28384 S   0.0   1.3   0:00.72 C1 CompilerThre
   2285 dousx     20   0 3650172 217528  28384 S   0.0   1.3   0:00.00 Sweeper thread
   2288 dousx     20   0 3650172 217528  28384 S   0.0   1.3   0:00.00 Notification Th
   2289 dousx     20   0 3650172 217528  28384 S   0.0   1.3   0:00.96 VM Periodic Tas
   2290 dousx     20   0 3650172 217528  28384 S   0.0   1.3   0:00.00 Common-Cleaner
   2297 dousx     20   0 3650172 217528  28384 S   0.0   1.3   0:00.01 GC Thread#1
```

#### 4.将`tid`转换为`十六进制(小写)`

`printf '%x\n' 十进制`

```shell
~ » printf '%x\n' 2263                                                                       
8d7
```

#### 5.执行 `jstack  <pid> | grep  -A  10  <thread 0x16 tid>`得到线程堆栈所在行的后10行
```shell
~/cpu-take-up-high-test (main) » jstack 2261 | grep -A 10 8d7                               
"main" #1 prio=5 os_prio=0 cpu=42000.14ms elapsed=47.68s tid=0x00007fbb90023bd0 nid=0x8d7 runnable  [0x00007fbb94cb1000]
   java.lang.Thread.State: RUNNABLE
        at cn.cruder.ctuh.runner.AppRunner.run(AppRunner.java:26)
        at org.springframework.boot.SpringApplication.callRunner(SpringApplication.java:768)
        at org.springframework.boot.SpringApplication.callRunners(SpringApplication.java:758)
        at org.springframework.boot.SpringApplication.run(SpringApplication.java:310)
        at org.springframework.boot.SpringApplication.run(SpringApplication.java:1312)
        at org.springframework.boot.SpringApplication.run(SpringApplication.java:1301)
        at cn.cruder.ctuh.Application.main(Application.java:15)
        at jdk.internal.reflect.NativeMethodAccessorImpl.invoke0(java.base@17.0.3/Native Method)
        at jdk.internal.reflect.NativeMethodAccessorImpl.invoke(java.base@17.0.3/NativeMethodAccessorImpl.java:77)
```

通过定位查看到代码`cn.cruder.ctuh.runner.AppRunner.run(AppRunner.java:26)`
