from fastapi import FastAPI, Request
import logging
from uvicorn import run
import os
from time import time

app = FastAPI()

os.makedirs("log", exist_ok=True)

# 사용자 정의 로그 포맷
log_formatter = logging.Formatter(
    '[%(asctime)s] Service A %(clientip)s "%(method)s %(path)s" %(responsetime)sms %(status_code)s'
)

# 로깅 핸들러 설정
file_handler = logging.FileHandler("log/app.log")
file_handler.setFormatter(log_formatter)
file_handler.setLevel(logging.INFO)

# 루트 로거에 핸들러 추가
logger = logging.getLogger()
logger.addHandler(file_handler)
logger.setLevel(logging.INFO)


# 사용자 정의 로깅 미들웨어
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time()
    response = await call_next(request)
    process_time = (time() - start_time) * 1000

    log_data = {
        "clientip": request.client.host,
        "method": request.method,
        "path": request.url.path,
        "responsetime": round(process_time, 2),
        "status_code": response.status_code,
    }

    logger.info("", extra=log_data)
    return response


@app.get("/")
async def read_root(request: Request):
    return {"message": "Hello I'm Service A"}


if __name__ == "__main__":
    run(app, host="0.0.0.0", port=8080)
