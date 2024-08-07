import common



proc questionContent*(client: AsyncHttpClient,
  host: Uri,
  titleSlug: string,
): Future[JsonNode] {.async.} =
  let url = host / "graphql/"
  let body = %*{
    "operationName": "questionContent",
    "query": """
query questionContent($titleSlug: String!) {
  question(titleSlug: $titleSlug) {
    content
    editorType
    mysqlSchemas
    dataSchemas
  }
}
""",
    "variables": %*{
      "titleSlug": titleSlug
    }
  }

  await client.post(url, body)
