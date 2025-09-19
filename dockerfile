FROM python:3.10-slim

WORKDIR /opt/status-page/

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
        libjpeg-dev zlib1g-dev libfreetype6-dev \
        libwebp-dev libtiff5-dev liblcms2-dev \
        tcl8.6-dev tk8.6-dev libharfbuzz-dev libfribidi-dev libxcb1-dev \
    && rm -rf /var/lib/apt/lists/*

# העתקת קבצי requirements
COPY . .

# התקנת תלויות
RUN pip install --upgrade pip setuptools wheel
RUN pip install wheel
RUN pip install --no-cache-dir -r requirements.txt
RUN chmod +x ./entrypoint.sh

EXPOSE 8000
WORKDIR /opt/status-page/statuspage
CMD ["../entrypoint.sh"]

