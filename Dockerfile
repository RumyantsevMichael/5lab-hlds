###########################################################
# Dockerfile that builds a CS 1.6 Gameserver
###########################################################
FROM cm2network/steamcmd:root

LABEL maintainer="Rumyantsev.Michael@gmail.com"

ENV STEAMAPPID 90
ENV STEAMAPP cs
ENV STEAMAPPDIR "/home/steam/${STEAMAPP}-dedicated"
ENV DLURL https://raw.githubusercontent.com/CM2Walki/CSGO

# Create autoupdate config
# Add entry script & ESL config
# Remove packages and tidy up
RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		wget=1.20.1-1.1 \
		libsdl2-2.0-0=2.0.9+dfsg1-1 \
		ca-certificates=20190110 \
	&& mkdir -p "${STEAMAPPDIR}/${STEAMAPP}" \
	&& wget "${DLURL}/master/etc/entry.sh" -O "${STEAMAPPDIR}/entry.sh" \
	&& chmod 755 "${STEAMAPPDIR}/entry.sh" \
	&& { \
		echo '@ShutdownOnFailedCommand 1'; \
		echo '@NoPromptForPassword 1'; \
		echo 'login anonymous'; \
		echo 'force_install_dir "${STEAMAPPDIR}"'; \
		echo 'app_update "${STEAMAPPID}"'; \
		echo 'quit'; \
	   } > "${STEAMAPPDIR}/${STEAMAPP}_update.txt" \
	&& wget -qO- "${DLURL}/master/etc/cfg.tar.gz" | tar xvzf - -C "${STEAMAPPDIR}/${STEAMAPP}" \
	&& chown -R steam:steam "${STEAMAPPDIR}" \
	&& rm -rf /var/lib/apt/lists/*

ENV SRCDS_FPSMAX=300 \
	SRCDS_TICKRATE=128 \
	SRCDS_PORT=27015 \
	SRCDS_TV_PORT=27020 \
	SRCDS_CLIENT_PORT=27005 \
	SRCDS_NET_PUBLIC_ADDRESS="0" \
	SRCDS_IP="0" \
	SRCDS_MAXPLAYERS=14 \
	SRCDS_TOKEN=0 \
	SRCDS_RCONPW="changeme" \
	SRCDS_PW="changeme" \
	SRCDS_STARTMAP="de_dust2" \
	SRCDS_REGION=3 \
	SRCDS_MAPGROUP="mg_active" \
	SRCDS_GAMETYPE=0 \
	SRCDS_GAMEMODE=1 \
	SRCDS_HOSTNAME="New \"${STEAMAPP}\" Server" \
	SRCDS_WORKSHOP_START_MAP=0 \
	SRCDS_HOST_WORKSHOP_COLLECTION=0 \
	SRCDS_WORKSHOP_AUTHKEY=""

USER steam

WORKDIR ${STEAMAPPDIR}

CMD ["bash", "entry.sh"]

# Expose ports
EXPOSE 27015/tcp 27015/udp 27020/udp
