FROM mcr.microsoft.com/dotnet/framework/sdk:3.5-windowsservercore-20H2

# We set cmd as default shell
SHELL ["cmd", "/S", "/C"]

######################################################
# Install dependencies
######################################################
#
# Command lines parameters of vs_builttools.exe
# https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2019
#
# Packages inside vs_builttools.exe
# https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2019

# Install dependencies
RUN curl -SL --output vs_buildtools.exe https://aka.ms/vs/16/release/vs_buildtools.exe \
    # Install Build Tools
    && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache modify \
        --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools" \
    # MSVC v140 - VS 2015 C++ build tools (v14.00)
        --add Microsoft.VisualStudio.Component.VC.140 \
    # Build modern C++ apps for Windows using tools of your choice, including MSVC, Clang, CMake, or MSBuild.
        --add Microsoft.VisualStudio.Workload.VCTools \
        --add Microsoft.VisualStudio.Workload.UniversalBuildTools \
    # We ignore the next ones because they are unstable inside Windows Server Core containers
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 \
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 \
        --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 \
        --remove Microsoft.VisualStudio.Component.Windows81SDK \
    # We ignore error 3010 because it actually means "Install successful but needs a reboot"
        || IF "%ERRORLEVEL%"=="3010" EXIT 0) \ 
    # Cleanup                       
    && del /q vs_buildtools.exe       


######################################################
# Post-Dependencies Checks
######################################################

# We want the image building process to fail if MSBuild is not found in the path
#
# Note: if you get an error during the build process that Microsoft.Cpp.Default.props is missing could be caused by MSBuild not being in the path
RUN MSBuild.exe /version

# Install Chocolatey
RUN powershell -Command \
        iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')); \
        choco feature disable --name showDownloadProgress

# Install Windows 8.1 SDK
RUN choco install -y windows-sdk-8.1

# Install Python
RUN choco install -y python --version=3.9.0

# COPY . C:/signtool

# # Install the signtool in path (command: sign .exe_path)
# RUN "echo python C:\signtool\signtool.py C:\signtool\ %1 > C:\signtool\sign.bat"
# RUN setx path "%path%;C:\signtool"

# Run MSBuild version as default command
CMD MSBuild.exe /version

