import common



proc questionStats*(client: AsyncHttpClient,
  host: Uri,
  titleSlug: string,
): Future[JsonNode] {.async.} =
  let url = host / "graphql/"
  let body = %*{
    "operationName": "questionStats",
    "query": """
query questionStats($titleSlug: String!) {
  question(titleSlug: $titleSlug) {
    stats
  }
}
""",
    "variables": %*{
      "titleSlug": titleSlug
    }
  }

  await client.post(url, body)
