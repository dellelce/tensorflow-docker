ARG BASE=dellelce/py-base
FROM $BASE as build

LABEL maintainer="Antonio Dell'Elce"
ARG USERNAME=tf
ARG TFENV=/home/${USERNAME}/tf-env
ARG GID=2001
ARG UID=2000

# temp install line before switching to use multi-stage install
RUN apk add --no-cache gcc g++ binutils gfortran make libc-dev linux-headers \
                       libxslt-dev

WORKDIR $TFENV
COPY requirements.txt  /tmp/requirements.txt

# install requirements
RUN cd "${TFENV}" && "${INSTALLDIR}/bin/python3" -m venv . \
 && . ${TFENV}/bin/activate \
 && pip install -U pip setuptools \
 && pip install -r /tmp/requirements.txt \
 && chown -R ${UID}:${GID} /app

ARG BASE=dellelce/py-base
FROM $BASE as finale

# commands are intended for busybox: if BASE is changed to non-BusyBox these may fail!
ARG GID=2001
ARG UID=2000
ARG GROUP=tf
ARG USERNAME=tf
ARG BASEDATA=/app/data
ARG DATA=${BASEDATA}/${USERNAME}
ARG TFPORT=8000
ARG TFHOME=/home/${USERNAME}
ARG TFENV=/home/${USERNAME}/tf-env

ENV ENV   $TFHOME/.profile

# copy virtualenv from first stage
COPY --from=build ${TFENV} ${TFENV} 

RUN mkdir -p ${BASEDATA} && chmod 777 ${BASEDATA} \
    && addgroup -g "${GID}" "${GROUP}" && adduser -D -s /bin/sh \
       -g "TensorFlow user" \
       -G "${GROUP}" -u "${UID}" \
       "${USERNAME}"

RUN    mkdir -p "${TFENV}" && chown "${USERNAME}":"${GROUP}" "${TFENV}" \
    && chown -R "${USERNAME}:${GROUP}" "${TFHOME}" \
    && mkdir -p "${DATA}" && chown "${USERNAME}":"${GROUP}" "${DATA}" \
    && echo '. '${TFENV}'/bin/activate'           >> ${TFHOME}/.profile

USER ${USERNAME}

VOLUME ${DATA}
ENV TFDATA  ${DATA}

EXPOSE ${TFPORT}:${TFPORT}

