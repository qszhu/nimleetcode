import common



proc questionTitle*(client: AsyncHttpClient,
  host: Uri,
  titleSlug: string,
): Future[JsonNode] {.async.} =
  let url = host / "graphql/"
  let body = %*{
    "operationName": "questionTitle",
    "query": """
query questionTitle($titleSlug: String!) {
  question(titleSlug: $titleSlug) {
    questionId
    questionFrontendId
    title
    titleSlug
    isPaidOnly
    difficulty
    likes
    dislikes
    categoryTitle
  }
}
""",
    "variables": %*{
      "titleSlug": titleSlug
    }
  }

  await client.post(url, body)
