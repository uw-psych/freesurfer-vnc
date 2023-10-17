FROM ubuntu:22.04

ARG USERNAME=freesurfer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV SHELL="/bin/bash"
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL='C.UTF-8'
ENV LANG='C.UTF-8'

# Install dependencies:
RUN apt-get update --quiet \
	&& apt-get install --yes --quiet --no-install-recommends \
		apt-utils \
		at-spi2-core \
		bash-completion \
		binutils \
		bzip2 \
		ca-certificates \
		curl \
		dbus \
		dbus-broker \
		dbus-user-session \
		dbus-x11 \
		desktop-base \
		desktop-file-utils \
		evince \
		file-roller \
		findutils \
		fontconfig \
		fontconfig-config \
		fonts-dejavu-core \
		fonts-droid-fallback \
		fonts-freefont-ttf \
		fonts-liberation \
		fonts-noto-mono \
		fonts-opensymbol \
		fonts-powerline \
		fonts-urw-base35 \
		gawk \
		git \
		gnupg \
		gpg-agent \
		gsfonts \
		gvfs \
		gvfs-backends \
		gvfs-fuse \
		iproute2 \
		less \
		libfuse2 \
		libnotify-bin \
		libpam0g \
		libturbojpeg \
		libxext6 \
		libxt6 \
		locales \
		lsb-release \
		make \
		nano \
		net-tools \
		netbase \
		netcat-openbsd \
		novnc \
		openssh-client \
		procps \
		psmisc \
		python3 \
		python3-dbus \
		python3-pip \
		python3-setuptools \
		python3-venv \
		python3-wheel \
		ristretto \
		socat \
		squashfs-tools \
		sview \
		sudo \
		thunar \
		thunar-archive-plugin \
		thunar-volman \
		tumbler \
		udisks2 \
		unzip \
		vim \
		wget \
		x11-xkb-utils \
		xauth \
		xclip \
		xdg-user-dirs \
		xdg-user-dirs-gtk \
		xdg-utils \
		xfce4 \
		xfce4-goodies \
		xfce4-notifyd \
		xfce4-screenshooter \
		xfce4-terminal \
		xfce4-whiskermenu-plugin \
		xfonts-100dpi \
		xfonts-base \
		xfonts-encodings \
		xfonts-scalable \
		xfonts-utils \
		xkb-data \
		xsel \
		xvfb \
		xz-utils \
		zip \
	&& apt-get clean

# Install en_US.UTF-8 locale:
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Install GitHub CLI:
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list >/dev/null \
	&& apt-get update --quiet \
	&& apt-get install --yes --quiet gh \
	&& apt-get clean

# Install TurboVNC:
ARG VNC_DEFAULT_PASSWORD=password
ARG VNC_DEFAULT_PORT=5900
ENV VNC_DEFAULT_PASSWORD="${VNC_DEFAULT_PASSWORD}"
ENV PATH="/opt/TurboVNC/bin:$PATH"
ENV TVNC_WM=xfce
ENV VNC_BASE_DIR="/vnc"
ENV VNC_LOG_FILE="${VNC_BASE_DIR}/vnc.log"
ENV VNC_SOCKET_FILE="${VNC_BASE_DIR}/vnc.socket"
ENV VNC_PASSWORD_FILE="${VNC_BASE_DIR}/passwd"
ENV VNC_PORT="${VNC_DEFAULT_PORT:-5900}"
ENV DISPLAY=":2"
ENV SHELL="${SHELL:-/bin/bash}"

ADD install-turbovnc.sh /opt/install-turbovnc.sh
RUN /opt/install-turbovnc.sh \
	&& mkdir -p "$VNC_BASE_DIR" \
	&& chown -R "$USERNAME:$USERNAME" "$VNC_BASE_DIR" \
	&& echo '$vncUserDir = "$ENV{VNC_BASE_DIR}";' >>/etc/turbovncserver.conf \
	&& echo "${VNC_DEFAULT_PASSWORD}" | vncpasswd -f >"${VNC_PASSWORD_FILE}" \
	&& chown "$USERNAME:$USERNAME" "${VNC_PASSWORD_FILE}" \
	&& chmod 600 "${VNC_PASSWORD_FILE}" \
	&& echo "Set VNC password to ${VNC_PASSWORD} in file ${VNC_PASSWORD_FILE}" \
	&& apt-get clean

# Install FreeSurfer:
ARG FREESURFER_VERSION=7.4.1
ARG FREESURFER_HOME=/usr/local/freesurfer/$FREESURFER_VERSION

# Environment Variables
ENV FREESURFER_HOME="${FREESURFER_HOME}"
ENV OS=Linux
ENV FS_OVERRIDE=0
ENV FIX_VERTEX_AREA=""
ENV FSF_OUTPUT_FORMAT="nii.gz"
ENV SUBJECTS_DIR="$FREESURFER_HOME/subjects"
ENV FUNCTIONALS_DIR="$FREESURFER_HOME/sessions"
ENV MNI_DIR="$FREESURFER_HOME/mni"
ENV LOCAL_DIR="$FREESURFER_HOME/local"
ENV MINC_BIN_DIR="$FREESURFER_HOME/mni/bin"
ENV MINC_LIB_DIR="$FREESURFER_HOME/mni/lib"
ENV MNI_DATAPATH="$FREESURFER_HOME/mni/data"
ENV PERL5LIB="$MINC_LIB_DIR/perl5/5.8.5"
ENV MNI_PERL5LIB="$MINC_LIB_DIR/perl5/5.8.5"
ENV PATH="$FREESURFER_HOME/bin:$FREESURFER_HOME/tktools:$MINC_BIN_DIR:$PATH"

# Install Freesurfer
RUN FREESURFER_VERSION="${FREESURFER_VERSION:-7.4.1}" dlpath=$(curl -w "%{filename_effective}" -fLO "https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/${FREESURFER_VERSION}/freesurfer_ubuntu22-${FREESURFER_VERSION}_amd64.deb") \
	&& apt-get update --quiet \
	&& dpkg --install --force-depends "${dlpath}" \
	&& apt-get install --fix-broken --yes --quiet \
	&& rm -f "${dlpath:-}" \
	&& apt-get clean

ADD freeview.desktop /usr/share/applications/freeview.desktop

# Set up user:
RUN groupadd --gid $USER_GID $USERNAME \
	&& useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
	&& echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
	&& chmod 0440 /etc/sudoers.d/$USERNAME

USER "$USERNAME"

EXPOSE 5900
ENTRYPOINT vncserver -fg  -rfbport 5900

LABEL org.label-schema.name="freesurfer-vnc"
LABEL org.label-schema.description="freesurfer-vnc - Container with TurboVNC and Freesurfer"
LABEL org.label-schema.url="https://github.com/uw-psych/freesurfer-vnc" 
LABEL org.label-schema.vcs-url="https://github.com/uw-psych/freesurfer-vnc"
LABEL org.label-schema.schema-version="1.0"