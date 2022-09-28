FROM python:slim

ADD pyapp /pyapp
COPY requirements.txt /pyapp
WORKDIR /pyapp

RUN chmod 775 app.py
RUN pip3 install -r requirements.txt

ENTRYPOINT ["./app.py"]