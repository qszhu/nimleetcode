import std/[
  asyncdispatch,
  httpclient,
  json,
  logging,
  uri,
]

export asyncdispatch, httpclient, json, uri

proc post*(client: AsyncHttpClient, url: Uri, body: JsonNode): Future[JsonNode] {.async.} =
  logging.debug "POST ", url
  logging.debug body
  let resp = await client.request(url, httpMethod = HttpPost, body = $body)
  let respBody = await resp.body
  logging.debug respBody
  respBody.parseJson

proc get*(client: AsyncHttpClient, url: Uri): Future[JsonNode] {.async.} =
  logging.debug "GET ", url
  let resp = await client.request(url, httpMethod = HttpGet)
  let respBody = await resp.body
  logging.debug respBody
  respBody.parseJson

proc getRaw*(client: AsyncHttpClient, url: Uri): Future[string] {.async.} =
  logging.debug "GET ", url
  let resp = await client.request(url, httpMethod = HttpGet)
  let respBody = await resp.body
  logging.debug respBody
  respBody
