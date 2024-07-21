import common



proc updateContestDynamicLayout*(client: AsyncHttpClient,
  host: Uri,
  enable: bool
): Future[JsonNode] {.async.} =
  let url = host / "graphql/"
  let body = %*{
    "operationName": "updateContestDynamicLayout",
    "query": """
mutation updateContestDynamicLayout($enable: Boolean) {
  toggleContestDynamicLayout(enable: $enable) {
    error
    ok
    __typename
  }
}
""",
    "variables": %*{
      "enable": enable
    },
  }

  await client.post(url, body)
