import common



proc solutionTags*(client: AsyncHttpClient,
  host: Uri,
  questionSlug: string,
): Future[JsonNode] {.async.} =
  let url = host / "graphql/"
  let body = %*{
    "operationName": "solutionTags",
    "query": """
query solutionTags($questionSlug: String!) {
  solutionTags(questionSlug: $questionSlug) {
    allTags {
      name
      nameTranslated
      slug
    }
    languageTags {
      name
      nameTranslated
      slug
    }
    otherTags {
      name
      nameTranslated
      slug
    }
    myTag
  }
}
""",
    "variables": %*{
      "questionSlug": questionSlug
    }
  }

  await client.post(url, body)
