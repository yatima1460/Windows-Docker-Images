# escape=`

#   _____________________
#   |         |         |    Container OS: Windows 
#   |         |         |    Tag: ltsc2019-amd64
#   |         |         |
#   |_________|_________|    Command lines parameters of vs_builttools.exe
#   |         |         |    https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2019
#   |         |         |
#   |         |         |    Packages inside vs_builttools.exe
#   |_________|_________|    https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2019

FROM mcr.microsoft.com/windows/servercore:ltsc2019-amd64

############################
# Set cmd as default shell #
############################
SHELL ["cmd", "/S", "/C"]

###########################
# Setup vs_buildtools.exe #
###########################

# Copy Install script.
COPY Install.cmd C:\TEMP\
# Download collect.exe in case of an install failure.
ADD https://aka.ms/vscollect.exe C:\TEMP\collect.exe
# Use the latest release channel. For more control, specify the location of an internal layout.
ADD https://aka.ms/vs/16/release/channel C:\TEMP\VisualStudio.chman
ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:\TEMP\vs_buildtools.exe

####################
# VS2019 C++ stuff #
####################
RUN C:\TEMP\Install.cmd C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --installPath C:\BuildTools `
    --channelUri C:\TEMP\VisualStudio.chman `
    --installChannelUri C:\TEMP\VisualStudio.chman `
    --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended

#################################
# Check BuildTools stuff exists #
#################################
RUN dir C:\BuildTools\VC\Auxiliary\Build\vcvarsall.bat

##################################################
# Redirect BuildTools for tools hardcoding paths #
##################################################
RUN mkdir "C:\Program Files (x86)\Microsoft Visual Studio\2019\"
# Community
RUN mklink /d "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community"    "C:\BuildTools"
## Professional
RUN mklink /d "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional" "C:\BuildTools"
## Enterprise
RUN mklink /d "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise"   "C:\BuildTools"

############################################
# Start init script to show container info #
############################################
COPY Init.bat C:\Init.bat
ENTRYPOINT [ "C:\\Init.bat", "&&"]
CMD ["cmd"]
