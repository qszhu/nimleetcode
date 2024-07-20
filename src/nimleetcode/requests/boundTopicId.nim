import common



proc boundTopicId*(client: AsyncHttpClient,
  host: Uri,
  titleSlug: string,
): Future[JsonNode] {.async.} =
  let url = host / "graphql/"
  let body = %*{
    "operationName": "boundTopicId",
    "query": """
query boundTopicId($titleSlug: String!) {
  question(titleSlug: $titleSlug) {
    boundTopicId
  }
}
""",
    "variables": %*{
      "titleSlug": titleSlug
    }
  }

  await client.post(url, body)
