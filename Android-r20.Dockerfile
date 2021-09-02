FROM mcr.microsoft.com/windows/servercore:ltsc2019-amd64

# We set cmd as default shell
SHELL ["cmd", "/S", "/C"]

# Install Chocolatey
RUN powershell -Command \
        iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')); \
        choco feature disable --name showDownloadProgress

RUN choco install -y android-ndk --version=20.0
ENV ANDROID_NDK_DIR=C:\Android\android-ndk-r20

RUN choco install -y android-sdk
ENV ANDROID_SDK_DIR=C:\Android\android-sdk

# Show container info at boot
COPY Init.bat C:\Init.bat
ENTRYPOINT [ "C:\\Init.bat", "&&"]
CMD ["cmd"]