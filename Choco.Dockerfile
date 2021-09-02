#escape=`

FROM mcr.microsoft.com/windows/servercore:ltsc2019-amd64

# Choco
RUN powershell -Command `
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')); `
    choco feature disable --name showDownloadProgress

# Show container info at boot
COPY Init.bat C:\Init.bat
ENTRYPOINT [ "C:\\Init.bat", "&&"]
CMD ["cmd"]