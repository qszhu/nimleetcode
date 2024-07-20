import common



proc premiumQuestion*(client: AsyncHttpClient,
  host: Uri,
  titleSlug: string,
): Future[JsonNode] {.async.} =
  let url = host / "graphql/"
  let body = %*{
    "operationName": "premiumQuestion",
    "query": """
query premiumQuestion($titleSlug: String!) {
  question(titleSlug: $titleSlug) {
    isPaidOnly
  }
}
""",
    "variables": %*{
      "titleSlug": titleSlug
    }
  }

  await client.post(url, body)
