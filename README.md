# Windows-Docker-Images

Collection of useful Windows Docker Images

# F.A.Q.

## LNK1318: Unexpected PDB error; RPC (23) '(0x000006E7)'

Happens when using Hyper-V + host machine folder mounted inside using a bind volume

The linker gets crazy and dies because it uses some obscure Windows Kernel APIs to read the files it needs that Docker doesn't support

To prevent it:

- Use Process Isolation

or

- Don't mount host machine folders

https://github.com/docker/for-win/issues/829
