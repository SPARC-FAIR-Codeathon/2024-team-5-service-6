

# quay.io/jupyter/minimal-notebook:python-3.11 is one possible base image, you can find information about others here: https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html
# Check the Jupyter/docker-stacks repo for more information about other versions of Python/OS: https://github.com/jupyter/docker-stacks
FROM quay.io/jupyter/minimal-notebook:python-3.11 as base






LABEL maintainer=appukuttan-shailesh

ENV JUPYTER_ENABLE_LAB="yes"
# autentication is disabled for now
ENV NOTEBOOK_TOKEN=""
ENV NOTEBOOK_BASE_DIR="$HOME/work"

USER root

ENV HOME="/home/$NB_USER"

# --------------- Add additional system libraries -------------------
# TODO: do you need additional system libraries (e.g. zip, bc, etc...)?
# If yes, uncomment the following and adapt
# If not, remove the following (or leave commented)

# RUN apt-get update && \
#   apt-get install -y --no-install-recommends \
#   bc \
#   zip \
#   && \
#   apt-get clean && rm -rf /var/lib/apt/lists/* 


ENV REQ_FILE="requirements.txt"
# ------------------------------  Python packages   --------------
# This will install the additional packages that you specified in requirements.txt in the pre-existing Python kernel
# Like in: https://github.com/jupyter/docker-stacks/blob/main/images/scipy-notebook/Dockerfile

COPY --chown=$NB_UID:$NB_GID env-config/python/${REQ_FILE} ${NOTEBOOK_BASE_DIR}/${REQ_FILE}
RUN pip install -r ${NOTEBOOK_BASE_DIR}/${REQ_FILE}

## ----------------------------------------------------------------------







# ---------------- Final setup  --------------------------------------------------------

USER root

RUN apt-get update && \
   apt-get install -y --no-install-recommends \
   gosu \
   && \
   apt-get clean && rm -rf /var/lib/apt/lists/* 

# Run a script from the base image to fix files permission
#RUN fix-permissions /home/$NB_USER

# copy README and CHANGELOG
COPY --chown=$NB_UID:$NB_GID README.ipynb ${NOTEBOOK_BASE_DIR}/README.ipynb
COPY --chown=$NB_UID:$NB_GID voila.ipynb ${NOTEBOOK_BASE_DIR}/voila.ipynb
COPY --chown=$NB_UID:$NB_GID demo_expression_data.csv ${NOTEBOOK_BASE_DIR}/demo_expression_data.csv
COPY --chown=$NB_UID:$NB_GID CHANGELOG.md ${NOTEBOOK_BASE_DIR}/CHANGELOG.md

# remove write permissions from files which are not supposed to be edited
RUN chmod gu-w ${NOTEBOOK_BASE_DIR}/CHANGELOG.md && \
  chmod gu-w ${NOTEBOOK_BASE_DIR}/${REQ_FILE}

RUN mkdir --parents "/home/${NB_USER}/.virtual_documents" && \
  chown --recursive "$NB_USER" "/home/${NB_USER}/.virtual_documents"
ENV JP_LSP_VIRTUAL_DIR="/home/${NB_USER}/.virtual_documents"

# Copying boot scripts
COPY --chown=$NB_UID:$NB_GID boot_scripts/ /docker

ENTRYPOINT [ "/bin/bash", "/docker/entrypoint.bash" ]