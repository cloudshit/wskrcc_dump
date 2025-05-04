FROM python:3.9-alpine

COPY app.py .

RUN pip3 install -r requirements.txt
# curl 설치는 수정하지 마세요
RUN apk update && apk add --no-cache curl

EXPOSE 8080

CMD ["python3", "app.py"]