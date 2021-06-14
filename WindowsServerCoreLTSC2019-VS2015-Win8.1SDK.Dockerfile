FROM yatima/windowsservercoreltsc2019:vs2015

RUN powershell -Command \
        iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')); \
        choco feature disable --name showDownloadProgress

RUN choco install -y windows-sdk-8.1

######################################################
# Image Metadata
######################################################

# Run MSBuild version as default command
CMD MSBuild.exe /version
