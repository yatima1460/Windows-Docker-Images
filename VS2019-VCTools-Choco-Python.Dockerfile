#escape=`

FROM yatima1460/windows:VS2019-VCTools

#########
# choco #
#########
RUN powershell -Command `
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')); `
    choco feature disable --name showDownloadProgress

##########
# Python #
##########
RUN choco install -y python --version=3.9.0
