# simple-django-project
## Installation

### Prerequisites

#### 1. Install Python
Install ```python-3.7.2``` and ```python-pip```. Follow the steps from the below reference document based on your Operating System.
Reference: [https://docs.python-guide.org/starting/installation/](https://docs.python-guide.org/starting/installation/)

#### 2. Install MySQL
Install ```mysql-8.0.15```. Follow the steps form the below reference document based on your Operating System.
Reference: [https://dev.mysql.com/doc/refman/5.5/en/](https://dev.mysql.com/doc/refman/5.5/en/)
#### 3. Setup virtual environment
```bash
# Install virtual environment
sudo pip install virtualenv

# Make a directory
mkdir envs

# Create virtual environment
virtualenv ./envs/

# Activate virtual environment
source envs/bin/activate
```

#### 4. Clone git repository
```bash
git clone "https://github.com/Manisha-Bayya/simple-django-project.git"
```

#### 5. Install requirements
```bash
cd simple-django-project/
pip install -r requirements.txt
```

#### 6. Load sample data into MySQL
```bash
# open mysql bash
mysql -u <mysql-user> -p

# Give the absolute path of the file
mysql> source ~/simple-django-project/world.sql
mysql> exit;

```
#### 7. Edit project settings
```bash
# open settings file
vim panorbit/settings.py

# Edit Database configurations with your MySQL configurations.
# Search for DATABASES section.
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'world',
        'USER': '<mysql-user>',
        'PASSWORD': '<mysql-password>',
        'HOST': '<mysql-host>',
        'PORT': '<mysql-port>',
    }
}

# Edit email configurations.
# Search for email configurations
EMAIL_USE_TLS = True
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_HOST_USER = '<your-email>'
EMAIL_HOST_PASSWORD = '<your-email-password>'
EMAIL_PORT = 587

# save the file
```
#### 8. Run the server
```bash
# Make migrations
python manage.py makemigrations
python manage.py migrate

# For search feature we need to index certain tables to the haystack. For that run below command.
python manage.py rebuild_index

# Run the server
python manage.py runserver 0:8001

# your server is up on port 8001
```
Try opening [http://localhost:8001](http://localhost:8001) in the browser.
# **Deploying Django Application on AWS EC2 with Docker**

This guide explains how to:

✅ **Set up an Ubuntu EC2 instance**

✅ **Install prerequisites (Docker, Git, etc.)**

✅ **Build and containerize a Django application**

✅ **Run the container using Docker**

---

## **Step 1: Launch an Ubuntu EC2 Instance**

1. **Login to AWS Console** and navigate to **EC2 Dashboard**.
2. Click **Launch Instance** and select **Ubuntu 20.04** as the OS.
3. Choose an appropriate instance type (e.g., `t2.micro` for testing).
4. Configure **Security Groups**:
    - Allow **SSH (port 22)** for remote access.
    - Allow **Custom TCP Rule (port 8001)** for the Django app.
5. **Launch the instance** and download the **.pem key**.

---

## **Step 2: Connect to EC2 Instance**

Use SSH to connect:

```bash
bash
CopyEdit
ssh -i your-key.pem ubuntu@your-ec2-public-ip

```

> Replace your-key.pem with your key file and your-ec2-public-ip with your instance IP.
> 

---

## **Step 3: Install Prerequisites**

### **Update and Install Docker**

```bash
bash
CopyEdit
sudo apt update -y
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

```

### **Verify Docker Installation**

```bash
bash
CopyEdit
docker --version

```

### **Install Git (If Not Installed)**

```bash
bash
CopyEdit
sudo apt install -y git

```

---

## **Step 4: Clone Your Django Application**

```bash
bash
CopyEdit
git clone https://github.com/shefeekar/django-simple-app.git
cd django-simple-app

```

---

## **Step 5: Understanding the Dockerfile**

The following **Dockerfile** containerizes the Django application:

```
Dockerfile

# Use official Python 3.8 base image
FROM python:3.8

# Set working directory
WORKDIR /app

# Install required system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    default-libmysqlclient-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy application files into the container
COPY . .

# Install virtualenv
RUN pip install --no-cache-dir virtualenv

# Create a virtual environment inside the container
RUN virtualenv -p python3.8 /env

# Set environment variables
ENV VIRTUAL_ENV=/env
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install dependencies
COPY ./requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expose port 8001
EXPOSE 8001

# Start Django application
CMD ["python", "manage.py", "runserver", "0.0.0.0:8001"]

```

---

### **. Define the Base Image**

```
FROM python:3.8

```

- Uses the official **Python 3.8** image from Docker Hub.
- Provides a pre-installed Python environment.

---

### **2. Set the Working Directory**

```

WORKDIR /app

```

- Creates and sets `/app` as the **working directory** inside the container.
- All subsequent commands will be executed in this directory.

---

### **3. Install System Dependencies**

```
RUN apt-get update && apt-get install -y --no-install-recommends \
    default-libmysqlclient-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

```

- **Updates the package list** to fetch the latest versions.
- Installs essential packages:
    - `default-libmysqlclient-dev` → Required for **MySQL database connectivity**.
    - `build-essential` → Includes tools like `gcc` needed for compiling dependencies.
- Cleans up unnecessary files to **reduce image size**.

---

### **4. Copy Application Files**

```

COPY . .

```

- Copies all project files from the host system to the `/app` directory inside the container.

---

### **5. Install Virtualenv and Create a Virtual Environment**

```
RUN pip install --no-cache-dir virtualenv
RUN virtualenv -p python3.8 /env

```

- Installs `virtualenv` to manage Python dependencies in an isolated environment.
- Creates a virtual environment (`/env`) using Python 3.8.

---

### **6. Set Environment Variables**

```
ENV VIRTUAL_ENV=/env
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

```

- Defines `VIRTUAL_ENV` so that the application uses the virtual environment.
- Updates `PATH` so that installed packages inside `/env/bin` are accessible.

---

### **7. Install Python Dependencies**

```
COPY ./requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

```

- Copies the `requirements.txt` file into the container.
- Installs all required Python dependencies without caching to reduce image size.

---

### **8. Expose the Application Port**

```
EXPOSE 8001

```

- Informs Docker that the application **runs on port 8001**.

---

### **9. Define the Startup Command**

```

CMD ["python", "manage.py", "runserver", "0.0.0.0:8001"]

```

## **Step 6: Build and Run the Docker Container**

### **Build the Docker Image**

```bash
bash
CopyEdit
sudo docker build -t django-app .

```

### **Run the Container using `-network=host`**

```bash
bash
CopyEdit
sudo docker run -d --network=host django-app

```

> The --network=host flag allows the container to use the host network, avoiding port-mapping issues.
> 

### **Verify Running Container**

```bash

sudo docker ps

```

---

## **Step 7: Access the Django Application**

Find the **EC2 public IP** and open in a browser:

```

http://your-ec2-public-ip:8001

```

---

## **Step 8: Managing the Container**

### **Stop the Container**

```bash
bash
CopyEdit
sudo docker stop <container_id>

```

### **Restart the Container**

```bash
sudo docker restart <container_id>

```

### **Remove the Container**

```bash
bash
CopyEdit
sudo docker rm <container_id>

```

---

---

## **Author**

📌 Maintained by shefeekar

📌 GitHub: https://github.com/shefeekar/django-simple-app

