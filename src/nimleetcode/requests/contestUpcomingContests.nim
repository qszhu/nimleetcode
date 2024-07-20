import common



proc contestUpcomingContests*(client: AsyncHttpClient,
  host: Uri,
): Future[JsonNode] {.async.} =
  let url = host / "graphql/"
  let body = %*{
    "operationName": nil,
    "query": """
{
  contestUpcomingContests {
    containsPremium
    title
    cardImg
    titleSlug
    description
    startTime
    duration
    originStartTime
    isVirtual
    isLightCardFontColor
    company {
      watermark
      __typename
    }
    __typename
  }
}
""",
    "variables": %*{}
  }

  await client.post(url, body)
