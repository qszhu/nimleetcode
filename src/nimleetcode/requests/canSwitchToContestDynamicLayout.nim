import common



proc canSwitchToContestDynamicLayout*(client: AsyncHttpClient,
  host: Uri,
  contestSlug: string
): Future[JsonNode] {.async.} =
  let url = host / "graphql/"
  let body = %*{
    "operationName": "canSwitchToContestDynamicLayout",
    "query": """
query canSwitchToContestDynamicLayout($contestSlug: String!) {
  contestDetail(contestSlug: $contestSlug) {
    enableContestDynamicLayout
    __typename
  }
}
""",
    "variables": %*{
      "contestSlug": contestSlug,
    },
  }

  await client.post(url, body)
