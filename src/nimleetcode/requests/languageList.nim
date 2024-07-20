import common



proc languageList*(client: AsyncHttpClient,
  host: Uri,
): Future[JsonNode] {.async.} =
  let url = host / "graphql/"
  let body = %*{
    "operationName": "languageList",
    "query": """
query languageList {
  languageList {
    id
    name
  }
}
""",
  }

  await client.post(url, body)
