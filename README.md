# freesurfer-vnc

Freesurfer in a Docker container with TurboVNC

## Prerequisites

Before running `freesurfer-vnc` locally, you'll need the following:

- A Linux, macOS, or Windows machine
- The OpenSSH client (usually included with Linux and macOS, and available for Windows via [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) or [Cygwin](https://www.cs.odu.edu/~zeil/cs252/latest/Public/loggingin/cygwin.mmd.html) [note that the Windows 10+ built-in OpenSSH client will not work])
- A VNC client/viewer ([TurboVNC viewer](https://www.turbovnc.org) is recommended for all platforms)
- Docker Desktop ([Windows](https://docs.docker.com/desktop/install/windows-install/), [macOS](https://docs.docker.com/desktop/install/mac-install/), [Linux](https://docs.docker.com/desktop/install/linux-install/))

Follow the instructions below to set up your machine correctly:

### Installing TurboVNC

#### Linux

To install TurboVNC, download the latest version from [here](https://sourceforge.net/projects/turbovnc/files). On Debian/Ubuntu, you will need to download the file ending with `arm64.deb`. On RHEL/CentOS/Rocky/Fedora, you will need to download the file ending with `x86_64.rpm`. Then, install it by running `sudo dpkg -i <filename>` on Debian/Ubuntu or `sudo rpm -i <filename>` on RHEL/CentOS/Rocky/Fedora.

#### macOS

To install TurboVNC, download the latest version from [here](https://sourceforge.net/projects/turbovnc/files). On an M1 Mac (newer), you will need to download the file ending with `arm64.dmg`. On an Intel Mac (older), you will need the file ending with `x86_64.dmg`. Then, open the `.dmg` file and launch the installer inside.

#### Windows

To install TurboVNC, download the latest version from [here](https://sourceforge.net/projects/turbovnc/files). You will need the file ending with `x64.exe`. Run the program to install TurboVNC.

## Usage

### Linux/macOS

Open a command prompt window (such as the built-in command prompt, PowerShell, or Windows Terminal), and then run the following command to launch the container with a VNC server running on port 5900:

```bash
docker run --name fvnc --rm -it -v "$HOME":/myhome -p 127.0.0.1:5900:5900 ghcr.io/uw-psych/freesurfer-vnc:latest
```

### Windows 

#### WSL2
Open the Windows WSL terminal prompt and run the following command to launch the container with a VNC server running on port 5900, and your Windows home directory mounted as `/userhome` inside the container:

```bash
docker run --name fvnc --rm -it -v "$HOME"/myhome -p 127.0.0.1:5900:5900 ghcr.io/uw-psych/freesurfer-vnc:latest
```

Next, open TurboVNC Viewer and connect to `localhost:5900`. When prompted, enter the password `password`.
