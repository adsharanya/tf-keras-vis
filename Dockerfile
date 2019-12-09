FROM nvidia/cuda:10.0-devel-ubuntu18.04

# Settings
ENV DEBIAN_FRONTEND noninteractive
ENV CUDNN_VERSION 7.6.2.24
ENV PYTHON_VER 3.6.9

LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

# Install essential libraries
RUN apt update
RUN apt upgrade -y
RUN apt install -y --no-install-recommends \
      libcudnn7=$CUDNN_VERSION-1+cuda10.0 \
      libcudnn7-dev=$CUDNN_VERSION-1+cuda10.0
RUN apt install -y --no-install-recommends \
      bash-completion curl wget less
RUN apt install -y --no-install-recommends \
      git build-essential \
      libffi-dev libssl-dev zlib1g-dev \
      libbz2-dev libreadline-dev libsqlite3-dev

# Install pyenv
RUN git clone git://github.com/yyuu/pyenv.git /root/.pyenv
RUN git clone https://github.com/yyuu/pyenv-pip-rehash.git /root/.pyenv/plugins/pyenv-pip-rehash
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/bin:$PATH
RUN echo 'eval "$(pyenv init -)"' >> .bashrc

ENV LD_LIBRARY_PATH=/lib/x86_64-linux-gnu:$PYENV_ROOT/versions/$PYTHON_VER/lib
RUN pyenv install $PYTHON_VER
RUN pyenv global $PYTHON_VER
ENV PATH $PYENV_ROOT/versions/$PYTHON_VER/bin:$PATH

# Install essential python libraries
RUN pip install --no-cache-dir --upgrade pip setuptools

# Setting for jupyter
RUN mkdir /root/.jupyter
RUN touch /root/.jupyter/jupyter_notebook_config.py
RUN echo 'c.NotebookApp.allow_root = True' >> /root/.jupyter/jupyter_notebook_config.py
RUN echo 'c.NotebookApp.ip = "0.0.0.0"' >> /root/.jupyter/jupyter_notebook_config.py
RUN echo 'c.NotebookApp.open_browser = False' >> /root/.jupyter/jupyter_notebook_config.py
RUN echo 'c.NotebookApp.token = ""' >> /root/.jupyter/jupyter_notebook_config.py

ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

RUN pip install --no-cache-dir \
        numpy scipy imageio tensorflow-gpu>=2.0 \
        flake8 isort==4.3.* yapf==0.28.* pytest pytest-pep8 pytest-xdist pytest-cov \
        jupyterlab matplotlib pillow
