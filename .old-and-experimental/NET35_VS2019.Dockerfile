FROM mcr.microsoft.com/dotnet/framework/sdk:3.5-20210525-windowsservercore-ltsc2019

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

ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:/vs_buildtools_16.exe

# Desktop development with C++
RUN start /w C:/vs_buildtools_16.exe --quiet --wait --norestart --nocache modify --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools" --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended	 || IF "%ERRORLEVEL%"=="3010" EXIT 0    

######################################################
# Secondary tools
######################################################

# Install Chocolatey
RUN powershell -Command \
        iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')); \
        choco feature disable --name showDownloadProgress

# Install Python
RUN choco install -y python --version=3.9.0

# Install git
RUN choco install -y git

######################################################
# Post-Dependencies Checks
######################################################

# We want the image building process to fail if MSBuild is not found in the path
#
# Note: if you get an error during the build process that Microsoft.Cpp.Default.props is missing could be caused by MSBuild not being in the path
RUN MSBuild.exe /version

# Run MSBuild version as default command
CMD MSBuild.exe /version
