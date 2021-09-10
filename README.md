# Windows-Docker-Images

Collection of useful Windows Docker Images

| Image | Contains |
|-|-|
|VS2019-VCTools|Microsoft.VisualStudio.Workload.VCTools+Recommended|
|VS2019-VCTools-Choco-Python|Microsoft.VisualStudio.Workload.VCTools+Recommended, Chocolatey, Python 3.9.0|
|NET4.8-VS2019-VCTools|NET4.8 SDK, Microsoft.VisualStudio.Workload.VCTools+Recommended|
|Choco|Chocolatey|
|Android-r20|Android NDK r20, Android SDK 26.1.1|
|UWP (TODO)|UWP for x86,x64,ARM|
|XboxOne (TODO)|XboxOne SDK explanation on how to create an image given you already have the Microsoft files|
|Xbox Series XS (TODO)|Xbox Series XS SDK explanation on how to create an image given you already have the Microsoft files|
|PS4 (TODO)|PS4 SDK explanation on how to create an image given you already have the Sony files|
|PS5 (TODO)|PS5 SDK explanation on how to create an image given you already have the Sony files|


# F.A.Q.

## When installing some build tools I get error 2148734499 or 87

Build Tools install the .NET framework, but it can't be installed on Windows Server Core, you need to use an image with them already installed and only then install the build tools

Something like this:

`FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019`

Will work

## When using Hyper-V compiling is slow

By default Hyper-V will run a VM with just 2 cores and 512MB of RAM

Use `--cpus=%NUMBER_OF_PROCESSORS%` and `--memory=4GB` with `docker run`

https://github.com/docker/for-win/issues/1877

> :warning: when doing `docker build` you can only use `--memory`
> https://github.com/moby/moby/issues/38387

## VS2015 or VS2019 projects crashes, aka: `LNK1318: Unexpected PDB error; RPC (23) '(0x000006E7)'`

Happens when using Hyper-V + host machine folder mounted inside using a bind volume

The linker gets crazy and dies because it uses some obscure Windows Kernel APIs to read the files it needs that Docker doesn't support

To prevent it:

- Disable .pdb files creation

or

- Use Process Isolation

or

- Don't mount host machine folders

or

- Mount a volume read only and copy the files

https://github.com/docker/for-win/issues/829

### In detail

Ok so mspdbsrv.exe uses some type of kernel API/system call to let the linker CL.exe write the .pdb files in parallel when using multithreaded compilation /MT


**context**

Docker Windows containers by default run on Windows using actually a VM, so yeah, Docker is crap on Windows and just runs as a real VM running an entire kernel inside too
(unlike Linux in which a Docker Linux container is actually just a process with less permissions)

the Hyper-V hypervisor when mounting files inside the Docker VM needs to let communicate the internal kernel with the external one


**the problem?**

my theory is that Microsoft forgot the kernel API in the internal simplified VM kernel...

OR

both kernels have the API but Hyper-V does a bad communication between the two kernels


**the effect?**

when something tries to use that asynchronous writing file API the process will corrupt/crash

how VS2019 fixed it?

considering there is no Hyper-V patch (otherwise it wouldn't happen even with VS2015) my theory is that Microsoft just removed the usage of that API and used one that is also inside the internal container kernel


**the fix?**

*don't let mspdbsrv.exe write .pdb files inside a container volume that is actually a host directory mounted inside*

This is confirmed to work with VS2017

**Patch A "mirror":**
1. mount the source code inside as a read-only volume
2. copy it to a real container folder
3. start compilation there
4. then copy the artifacts to a read/write volume so they can be extracted from the container as artifacts
   
> :warning: I have no idea if this works for VS2015

> :heavy_check_mark: Seems to work well for VS2017

**Patch B "layer":**
1. bake the source code inside the container as a new Docker layer on top
2. start compilation
3. then copy the artifacts to a read/write volume so they can be extracted from the container as artifacts

> :warning: I have never tried this solution

**Patch C "black magic":**
1. add the source code inside the container as a new Docker layer on top
2. actually start compilation not as a running container, but as an image creation process (docker build)
3. run the container with read/write volume
4. then copy the artifacts to a read/write volume so they can be extracted from the container as artifacts

> :heavy_check_mark: Seems to work well for VS2015

> :warning: I have no idea if this works for VS2017

**advantage?**

the stablest one, there are never possibly unstable Hyper-V volumes mounted when compiling


**disadvantage?**

max dual-core compilation


## `'MSBuild' is not recognized as an internal or external command, operable program or batch file` OR VC Targets path cl.exe not found or similar errors

You need to initialize the msbuild environment

`call C:\BuildTools\VC\Auxiliary\Build\vcvarsall.bat <architecture>`

Check the [vcvarsall documentation](https://docs.microsoft.com/en-us/cpp/build/building-on-the-command-line?view=msvc-160#vcvarsall-syntax)

## `Error response from daemon: hcsshim::CreateComputeSystem {container_guid}: The requested resource is in use.`

1. Restart Hyper-V Compute Service
2. Wait a bit
3. Restart Docker

## MSCOREE.lib is missing

You need an image with the .NET SDK installed

## I need Windows 8.1 SDK how can I install it inside a container?

Use choco, it's stable for that

```Dockerfile
RUN choco install -y windows-sdk-8.1
```

## When I try to use Hyper-V on AWS it doesn't work

You need a bare metal instance

https://aws.amazon.com/blogs/compute/running-hyper-v-on-amazon-ec2-bare-metal-instances/

## I want to run a Windows container when a custom AWS AMI starts

Something like

```
<powershell>
docker run --rm imagename ...
</powershell>
```

After setting up the userdata remember to run:

`C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeInstance.ps1 –Schedule`


before shutdown and before saving the AMI

https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2-windows-user-data.html

> :warning: Be careful of subnet gateways, you risk to mess up the route tables if you create the custom AMI in one subnet and then run it in another, the AMI will download the user data from a specific Amazon internal IP, as a rule of thumb just run it in the same subnet it was created if you don't want problems
> https://aws.amazon.com/premiumsupport/knowledge-center/waiting-for-metadata/

