import common



proc userQuestionStatus*(client: AsyncHttpClient,
  host: Uri,
  titleSlug: string,
): Future[JsonNode] {.async.} =
  let url = host / "graphql/"
  let body = %*{
    "operationName": "userQuestionStatus",
    "query": """
query userQuestionStatus($titleSlug: String!) {
  question(titleSlug: $titleSlug) {
    status
  }
}
""",
    "variables": %*{
      "titleSlug": titleSlug
    }
  }

  await client.post(url, body)
