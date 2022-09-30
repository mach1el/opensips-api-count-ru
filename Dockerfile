FROM python:slim

ADD pyapp /pyapp
COPY requirements.txt /pyapp
COPY entrypoint.sh /pyapp
WORKDIR /pyapp

RUN chmod 775 app.py
RUN chmod +x entrypoint.sh
RUN pip3 install -r requirements.txt

ENTRYPOINT ["./entrypoint.sh"]