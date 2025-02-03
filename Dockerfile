FROM       python:3.8
WORKDIR    /app
RUN        apt-get update && apt-get install -y --no-install-recommends \
           default-libmysqlclient-dev \
           build-essential \
           && rm -rf /var/lib/apt/lists/*

COPY       . .
RUN        pip install --no-cache-dir virtualenv
RUN        virtualenv -p python3.8 /env
ENV        VIRTUAL_ENV=/env
ENV        PATH="$VIRTUAL_ENV/bin:$PATH"        
COPY       ./requirements.txt requirements.txt
RUN        pip install --no-cache-dir -r requirements.txt   
EXPOSE     8001
CMD        ["python", "manage.py", "runserver", "0.0.0.0:8001"]

