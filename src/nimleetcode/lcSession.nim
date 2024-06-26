import std/[
  times,
]

import pkg/nimbrowsercookies

import jwts

export jwts, nimbrowsercookies



const SESSION_KEY = "LEETCODE_SESSION"

proc readSession*(browser: Browser, profilePath: string, host = "leetcode.cn"): JsonWebToken {.inline.} =
  initJWT(readCookies(browser, profilePath, host)[SESSION_KEY])

proc getUserName*(jwt: JsonWebToken): string {.inline.} =
  jwt.payload["username"].getStr

proc getExpireTimestamp*(jwt: JsonWebToken): int64 {.inline.} =
  jwt.payload["expired_time_"].getBiggestInt

proc getExpireTime*(jwt: JsonWebToken): string =
  jwt.getExpireTimestamp.fromUnix.format("yyyy-MM-dd HH:mm:ss")



when isMainModule:
  echo readSession(Browser.CHROME, getDefaultChromeProfilePath())
