package main

import (
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
)

type RequestBody struct {
	Iterator int `json:"iterator" binding:"required"`
}

func main() {
	// new gin router
	router := gin.New()

	// Logging to a file.
	logfile, _ := os.Create("log/app.log")
	router.Use(gin.LoggerWithConfig(gin.LoggerConfig{
		Formatter: func(param gin.LogFormatterParams) string {
			return fmt.Sprintf("%s - [%s] \"%s %s %s %d %s \"%s\" %s\"\n",
				param.ClientIP,
				param.TimeStamp.Format(time.RFC3339),
				param.Method,
				param.Path,
				param.Request.Proto,
				param.StatusCode,
				param.Latency,
				param.Request.UserAgent(),
				param.ErrorMessage,
			)
		},
		Output: logfile,
	}))

	// go panic -> recover 하는 미들웨어.
	router.Use(gin.Recovery())

	// 기본 path
	router.GET("/healthcheck", healthcheck)

	// 라우팅을 그룹으로 묶을 수 있음. 버전별 API 만들 때 좋음.
	v1 := router.Group("/v1")
	{
		v1.GET("/foo", getFoo)
	}

	// http 설정을 커스텀하고 싶으면 요렇게.
	server := &http.Server{
		Addr:         ":8080", // port
		Handler:      router,
		ReadTimeout:  10 * time.Second,
		WriteTimeout: 10 * time.Second,
	}

	server.ListenAndServe()
}

// health check api
func healthcheck(c *gin.Context) {
	c.JSON(200, gin.H{
		"status": "ok.",
	})
}

// get version
func getFoo(c *gin.Context) {
	c.JSON(200, gin.H{
		"application": "foo",
	})
}
