import common



proc toggleContestDynamicLayout*(client: AsyncHttpClient,
  host: Uri,
  enable: bool
): Future[JsonNode] {.async.} =
  let url = host / "graphql/"
  let body = %*{
    "operationName": "toggleContestDynamicLayout",
    "query": """
mutation toggleContestDynamicLayout($enable: Boolean) {
  toggleContestDynamicLayout(enable: $enable) {
    error
    ok
  }
}
""",
    "variables": %*{
      "enable": enable
    },
  }

  let res = await client.request(url, httpMethod = HttpPost, body = $body)
  return (await res.body).parseJson
