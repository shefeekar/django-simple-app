FROM       python:3.7-slim
WORKDIR    /app
COPY       .  ./app/
RUN        pip install --no-cache-dir virtualenv
RUN        virtualenv -p python3.7 /env
ENV        VIRTUAL_ENV=/env
ENV        PATH="$VIRTUAL_ENV/bin:$PATH"        
COPY       ./requirements.txt requirements.txt
RUN        pip install --no-cache-dir -r requirements.txt   
EXPOSE     8001
CMD        ["python", "manage.py", "runserver", "0.0.0.0:8001"]

