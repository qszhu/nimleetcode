import std/[
  asyncdispatch,
  httpclient,
  json,
  uri,
  strformat,
]

import requests/[
  # contest
  contestUpcomingContests,
  contestHistory,
  canSwitchToContestDynamicLayout,
  updateContestDynamicLayout,

  # question
  boundTopicId,
  consolePanelConfig,
  premiumQuestion,
  questionContent,
  questionEditorData,
  questionStats,
  questionTitle,
  questionTranslations,
  singleQuestionTopicTags,

  # question user
  userQuestionStatus,

  # question topic
  questionTopicsList,
  solutionTags,

  # topic
  discussTopic,
  questionDiscussComments,

  # topic user
  profileSolutionArticles,

  # language
  languageList,

  # submission
  submissionDetails,
  submissionList,

  common,
]

export asyncdispatch, json



const HOST = "https://leetcode.cn".parseUri

type ListOrder {.pure.} = enum
  DEFAULT = "DEFAULT"
  MOST_UPVOTE = "MOST_UPVOTE"

type LcClient* = ref object
  host: Uri
  client: AsyncHttpClient
  token: string

proc newLcClient*(host = HOST, proxyUrl = ""): LcClient =
  result.new
  result.host = host

  var proxy: Proxy = nil
  if proxyUrl.len > 0: proxy = newProxy(proxyUrl)

  result.client = newAsyncHttpClient(proxy = proxy)
  result.client.headers = newHttpHeaders({
    "Content-Type": "application/json"
  })

proc setToken*(self: LcClient, token: string) =
  self.token = token

proc setSessionCookie(self: LcClient) =
  doAssert self.token.len > 0
  self.client.headers["Cookie"] = &"LEETCODE_SESSION={self.token}"

proc setReferer(self: LcClient, url: string) =
  self.client.headers["Referer"] = url



proc boundTopicId*(self: LcClient,
  titleSlug: string
): Future[JsonNode] {.async.} =
  return await boundTopicId(self.client, self.host, titleSlug)

proc canSwitchToContestDynamicLayout*(self: LcClient,
  contestSlug: string,
): Future[JsonNode] {.async.} =
  return await canSwitchToContestDynamicLayout(self.client, self.host, contestSlug)

proc consolePanelConfig*(self: LcClient,
  titleSlug: string
): Future[JsonNode] {.async.} =
  return await consolePanelConfig(self.client, self.host, titleSlug)

proc contestHistory*(self: LcClient,
  pageNum = 1,
  pageSize = 10,
): Future[JsonNode] {.async.} =
  return await contestHistory(self.client, self.host, pageNum, pageSize)

proc contestUpcomingContests*(self: LcClient,
): Future[JsonNode] {.async.} =
  return await contestUpcomingContests(self.client, self.host)

proc discussTopic*(self: LcClient,
  slug: string
): Future[JsonNode] {.async.} =
  return await discussTopic(self.client, self.host, slug)

proc languageList*(self: LcClient,
): Future[JsonNode] {.async.} =
  return await languageList(self.client, self.host)

proc premiumQuestion*(self: LcClient,
  titleSlug: string
): Future[JsonNode] {.async.} =
  return await premiumQuestion(self.client, self.host, titleSlug)

proc profileSolutionArticles*(self: LcClient,
  userSlug: string,
  first = 15,
  skip = 0,
): Future[JsonNode] {.async.} =
  return await profileSolutionArticles(self.client, self.host, userSlug, first, skip)

proc questionDiscussComments*(self: LcClient,
  topicId: int,
  orderBy = "HOT",
  numPerPage = 10,
  skip = 0,
): Future[JsonNode] {.async.} =
  return await questionDiscussComments(self.client, self.host, topicId, orderBy, numPerPage, skip)

proc questionEditorData*(self: LcClient,
  titleSlug: string,
  login = false,
): Future[JsonNode] {.async.} =
  if login: self.setSessionCookie
  return await questionEditorData(self.client, self.host, titleSlug)

proc questionContent*(self: LcClient,
  titleSlug: string
): Future[JsonNode] {.async.} =
  return await questionContent(self.client, self.host, titleSlug)

proc questionStats*(self: LcClient,
  titleSlug: string
): Future[JsonNode] {.async.} =
  return await questionStats(self.client, self.host, titleSlug)

proc questionTitle*(self: LcClient,
  titleSlug: string
): Future[JsonNode] {.async.} =
  return await questionTitle(self.client, self.host, titleSlug)

proc questionTopicsList*(self: LcClient,
  questionSlug: string,
  orderBy: ListOrder = ListOrder.DEFAULT,
  first = 15,
  skip = 0,
  tagSlugs: seq[string] = @[],
  userInput = "",
): Future[JsonNode] {.async.} =
  return await questionTopicsList(self.client, self.host, questionSlug, $orderBy, first, skip, tagSlugs, userInput)

proc questionTranslations*(self: LcClient,
  titleSlug: string
): Future[JsonNode] {.async.} =
  return await questionTranslations(self.client, self.host, titleSlug)

proc singleQuestionTopicTags*(self: LcClient,
  titleSlug: string
): Future[JsonNode] {.async.} =
  return await singleQuestionTopicTags(self.client, self.host, titleSlug)

proc solutionTags*(self: LcClient,
  questionSlug: string
): Future[JsonNode] {.async.} =
  return await solutionTags(self.client, self.host, questionSlug)

proc submissionDetails*(self: LcClient,
  submissionId: string
): Future[JsonNode] {.async.} =
  self.setSessionCookie
  return await submissionDetails(self.client, self.host, submissionId)

proc submissionList*(self: LcClient,
  questionSlug: string,
  offset = 0,
  limit = 20,
  lastKey = "",
  status = "",
): Future[JsonNode] {.async.} =
  self.setSessionCookie
  return await submissionList(self.client, self.host, questionSlug, offset, limit, lastKey, status)

proc updateContestDynamicLayout*(self: LcClient,
  contestSlug: string,
  enable: bool,
): Future[JsonNode] {.async.} =
  self.setReferer $(self.host / "contest" / contestSlug)
  self.setSessionCookie
  return await updateContestDynamicLayout(self.client, self.host, enable)

proc userQuestionStatus*(self: LcClient,
  titleSlug: string
): Future[JsonNode] {.async.} =
  self.setSessionCookie
  return await userQuestionStatus(self.client, self.host, titleSlug)

proc testSolution*(self: LcClient,
  titleSlug: string,
  questionId: string,
  lang: string,
  code: string,
  testInput: string
): Future[JsonNode] {.async.} =
  let url = self.host / "problems" / titleSlug / "interpret_solution/"
  self.setReferer $url
  self.setSessionCookie
  let body = %*{
    "data_input": testInput,
    "lang": lang,
    "question_id": questionId,
    "typed_code": code,
  }
  await self.client.post(url, body)

proc checkSubmissionResult*(self: LcClient,
  submissionId: string,
  isTest = false,
): Future[JsonNode] {.async.} =
  let url = self.host / "submissions" / "detail" / submissionId / "check/"
  if not isTest:
    self.setSessionCookie
  await self.client.get(url)

proc submitSolution*(self: LcClient,
  titleSlug: string,
  questionId: string,
  lang: string,
  code: string,
): Future[JsonNode] {.async.} =
  let url = self.host / "problems" / titleSlug / "submit/"
  self.setReferer $url
  self.setSessionCookie
  let body = %*{
    "lang": lang,
    "question_id": questionId,
    "typed_code": code,
  }
  await self.client.post(url, body)

proc register*(self: LcClient, contestSlug: string) {.async.} =
  let url = self.host / "contest" / "api" / contestSlug / "register"
  self.setReferer $url
  self.setSessionCookie
  discard await self.client.post(url, "")

proc timestamp*(self: LcClient): Future[JsonNode] {.async.} =
  let url = self.host / "timestamp/"
  await self.client.get(url)

proc contestInfo*(self: LcClient,
  contestSlug: string,
  login = true,
): Future[JsonNode] {.async.} =
  if login: self.setSessionCookie
  let url = self.host / "contest" / "api" / "info" / (contestSlug & "/")
  await self.client.get(url)

proc contestMyRanking*(self: LcClient,
  contestSlug: string,
  region = "local",
): Future[JsonNode] {.async.} =
  var url = self.host / "contest" / "api" / "myranking" / (contestSlug & "/")
  url = url ? { "region": region }
  self.setSessionCookie
  await self.client.get(url)

proc contestRanking*(self: LcClient,
  contestSlug: string,
  region = "local",
  pagination = 1,
): Future[JsonNode] {.async.} =
  var url = self.host / "contest" / "api" / "ranking" / (contestSlug & "/")
  url = url ? { "pagination": $pagination, "region": region }
  await self.client.get(url)

proc getPage*(self: LcClient, contestSlug, titleSlug: string): Future[string] {.async.} =
  let url = self.host / "contest" / contestSlug / "problems" / (titleSlug & "/")
  await self.client.getRaw(url)

proc testContestSolution*(self: LcClient,
  contestSlug: string,
  titleSlug: string,
  questionId: string,
  lang: string,
  code: string,
  testInput: string,
  judgeType = "large",
  testMode = false,
): Future[JsonNode] {.async.} =
  let url = self.host / "contest" / "api" / contestSlug / "problems" / titleSlug / "interpret_solution/"
  self.setReferer $url
  self.setSessionCookie
  let body = %*{
    "data_input": testInput,
    "judge_type": judgeType,
    "lang": lang,
    "question_id": questionId,
    "test_mode": testMode,
    "typed_code": code,
  }
  await self.client.post(url, body)

proc submitContestSolution*(self: LcClient,
  contestSlug: string,
  titleSlug: string,
  questionId: string,
  lang: string,
  code: string,
  judgeType = "large",
  testMode = false,
): Future[JsonNode] {.async.} =
  let url = self.host / "contest" / "api" / contestSlug / "problems" / titleSlug / "submit/"
  self.setReferer $url
  self.setSessionCookie
  let body = %*{
    "judge_type": judgeType,
    "lang": lang,
    "question_id": questionId,
    "test_mode": testMode,
    "typed_code": code,
  }
  await self.client.post(url, body)
