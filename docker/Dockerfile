FROM dopamine/atari

RUN apt-get -y install curl

RUN apt-get -y install parallel cmake zlib1g-dev
RUN pip install absl-py atari-py gin-config gym opencv-python tensorflow-gpu
RUN apt-get -y install apt-transport-https ca-certificates gnupg
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update && apt-get -y install google-cloud-cli

# RUN pip install torch IPython

ENV PYTHONPATH /root/batch_rl/dopamine

WORKDIR /root/batch_rl