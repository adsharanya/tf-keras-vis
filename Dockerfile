FROM tensorflow/tensorflow:2.1.0-py3

# Default ENV Settings
ARG TF_KERAS_VIS_VERSION=0.2.0

# Setting for jupyter
RUN export JUPYTER_HOME=/root/.jupyter                           && \
    export JUPYTER_CONF=$JUPYTER_HOME/jupyter_notebook_config.py && \
    mkdir -p $JUPYTER_HOME                                       && \
    touch $JUPYTER_CONF                                          && \
    echo 'c.NotebookApp.allow_root = True' >> $JUPYTER_CONF      && \
    echo 'c.NotebookApp.ip = "0.0.0.0"' >> $JUPYTER_CONF         && \
    echo 'c.NotebookApp.token = ""' >> $JUPYTER_CONF

# Install essential python libraries
RUN pip install --no-cache-dir            \
      tf-keras-vis==$TF_KERAS_VIS_VERSION \
      numpy scipy imageio pillow          \
      jupyterlab matplotlib
