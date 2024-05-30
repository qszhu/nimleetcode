import std/[
  os,
  times,
]

import pkg/nimbrowsercookies

import jwts
import types

export jwts



const SESSION_KEY = "LEETCODE_SESSION"

proc readSession*(browser: Browser, profilePath: string, host = "leetcode.cn"): JsonWebToken =
  case browser
  of Browser.FIREFOX:
    let dbFn = profilePath / "cookies.sqlite"
    initJWT(readCookiesFromFirefox(dbFn, host)[SESSION_KEY])
  of Browser.CHROME:
    let dbFn = profilePath / "Cookies"
    initJWT(readCookiesFromChrome(dbFn, host)[SESSION_KEY])

proc getUserName*(jwt: JsonWebToken): string {.inline.} =
  jwt.payload["username"].getStr

proc getExpireTimestamp*(jwt: JsonWebToken): int64 {.inline.} =
  jwt.payload["expired_time_"].getBiggestInt

proc getExpireTime*(jwt: JsonWebToken): string =
  jwt.getExpireTimestamp.fromUnix.format("yyyy-MM-dd HH:mm:ss")



when isMainModule:
  echo readSession(Browser.CHROME, getDefaultChromeProfilePath())
