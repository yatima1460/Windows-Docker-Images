# Windows-Docker-Images

[![docker build](https://github.com/yatima1460/Windows-Docker-Images/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/yatima1460/Windows-Docker-Images/actions/workflows/docker-publish.yml)

Collection of useful Windows Docker Images

# F.A.Q.

## When installing some build tools I get error 2148734499 or 87

Build Tools install the .NET framework, but it can't be installed on Windows Server Core, you need to use an image with them already installed and only then install the build tools

Something like this:

`FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019`

Will work

## LNK1318: Unexpected PDB error; RPC (23) '(0x000006E7)'

Happens when using Hyper-V + host machine folder mounted inside using a bind volume

The linker gets crazy and dies because it uses some obscure Windows Kernel APIs to read the files it needs that Docker doesn't support

To prevent it:

- Use Process Isolation

or

- Don't mount host machine folders

https://github.com/docker/for-win/issues/829
