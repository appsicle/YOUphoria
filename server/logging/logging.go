package logging

import (
	log "github.com/sirupsen/logrus"
)

func InitLogging(){
	Formatter := new(log.JSONFormatter)
    Formatter.TimestampFormat = "02-01-2006 15:04:05"
    log.SetFormatter(Formatter)
}