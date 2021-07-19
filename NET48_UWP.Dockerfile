FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019

# We set cmd as default shell
SHELL ["cmd", "/S", "/C"]

######################################################
# Install dependencies
######################################################
#
# Command lines parameters of vs_builttools.exe
# https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2019
#
# Packages inside 2019
# https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2019
#
# Packages inside 2017
# https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2017
#
# Other MS info
# https://docs.microsoft.com/en-us/visualstudio/install/advanced-build-tools-container?view=vs-2019

# Install Chocolatey
RUN powershell -Command \
        iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')); \
        choco feature disable --name showDownloadProgress


# Install git
RUN choco install -y git

# --nocache modify

ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:/vs_buildtools_16.exe

# .NET desktop build tools
RUN start /w C:/vs_buildtools_16.exe --quiet --wait --norestart --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools" --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools  || IF "%ERRORLEVEL%"=="3010" EXIT 0 

# MSBuild Tools
RUN start /w C:/vs_buildtools_16.exe --quiet --wait --norestart --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools" --add Microsoft.VisualStudio.Workload.MSBuildTools              || IF "%ERRORLEVEL%"=="3010" EXIT 0    

# .NET build tools
RUN start /w C:/vs_buildtools_16.exe --quiet --wait --norestart --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools" --add Microsoft.VisualStudio.Workload.NetCoreBuildTools         || IF "%ERRORLEVEL%"=="3010" EXIT 0    

# UWP
RUN start /w C:/vs_buildtools_16.exe --quiet --wait --norestart --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools" --add Microsoft.VisualStudio.Workload.UniversalBuildTools       || IF "%ERRORLEVEL%"=="3010" EXIT 0 

# Desktop development with C++
RUN start /w C:/vs_buildtools_16.exe --quiet --wait --norestart --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools" --add Microsoft.VisualStudio.Workload.VCTools                   || IF "%ERRORLEVEL%"=="3010" EXIT 0    

# Windows10SDK 18362
RUN start /w C:/vs_buildtools_16.exe --quiet --wait --norestart --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools" --add Microsoft.VisualStudio.Component.Windows10SDK.18362       || IF "%ERRORLEVEL%"=="3010" EXIT 0 

# Install VS2017
RUN start /w C:/vs_buildtools_16.exe --quiet --wait --norestart --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools" --add Microsoft.VisualStudio.Component.VC.v141.x86.x64          || IF "%ERRORLEVEL%"=="3010" EXIT 0    


ADD https://aka.ms/vs/15/release/vs_buildtools.exe C:/vs_buildtools_15.exe

# .NET desktop build tools
RUN start /w C:/vs_buildtools_15.exe --quiet --wait --norestart --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\BuildTools" --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools  || IF "%ERRORLEVEL%"=="3010" EXIT 0 

# MSBuild Tools
RUN start /w C:/vs_buildtools_15.exe --quiet --wait --norestart --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\BuildTools" --add Microsoft.VisualStudio.Workload.MSBuildTools              || IF "%ERRORLEVEL%"=="3010" EXIT 0    

# .NET build tools
RUN start /w C:/vs_buildtools_15.exe --quiet --wait --norestart --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\BuildTools" --add Microsoft.VisualStudio.Workload.NetCoreBuildTools         || IF "%ERRORLEVEL%"=="3010" EXIT 0    

# UWP
RUN start /w C:/vs_buildtools_15.exe --quiet --wait --norestart --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2017\BuildTools" --add Microsoft.VisualStudio.Workload.UniversalBuildTools       || IF "%ERRORLEVEL%"=="3010" EXIT 0 

# Microsoft Windows SDK for Windows 10 and .NET Framework 4.7 10.1.18362.1
RUN choco install -y windows-sdk-10.1

# Windows Software Development Kit for Windows 10 Version 1903 (All Features) 10.0.18362.0
RUN choco install -y windows-sdk-10-version-1903-all

# Fails if VsDevCmd does not exist
RUN dir "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\Common7\Tools\VsDevCmd.bat"



# --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools"
