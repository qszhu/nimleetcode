import std/[
  htmlparser,
  os,
  strutils,
  xmltree,
]



type
  # wrapped node that can access its parent
  Node = ref object
    raw: XmlNode
    parent: Node
    children: seq[Node]
    index: int
    text: string

proc wrap(node: XmlNode, parent: Node = nil): Node =
  result.new
  result.raw = node
  result.parent = parent

  if node.kind == xnElement:
    for child in node.items:
      result.children.add wrap(child, result)
  elif node.kind == xnText:
    result.text = node.text

  # merge neighboring texts
  var children = newSeq[Node]()
  for child in result.children:
    if child.raw.kind == xnText:
      if children.len > 0 and children[^1].raw.kind == xnText:
        children[^1].text &= child.text
        continue
    child.index = children.len
    children.add child
  result.children = children



proc matchesText(node: Node, text: string): bool {.inline.} =
  node.raw.innerText.strip(trailing = false).toLowerAscii.startsWith(text.toLowerAscii)

proc isAfterText(node: Node, text: string): bool =
  if node == nil or node.index == 0: return
  let parent = node.parent
  if parent == nil: return
  # echo (node.raw.kind, node.index, parent.raw.innerText)
  if parent.matchesText(text): return true
  if parent.children.len > 0:
    let prev = parent.children[node.index - 1]
    if prev.matchesText(text): return true

proc extractOutput*(html: string): string =
  let root = parseHtml(html)
  var res = newSeq[string]()
  proc visit(node: Node, depth = 0) =
    case node.raw.kind
    of xnElement:
      # echo " ".repeat(depth), node.raw.tag
      for child in node.children:
        visit(child, depth + 2)
    of xnText:
      # echo " ".repeat(depth), "|", node.text, "|"
      let text = node.text.strip
      if text.len > 0:
        if node.isAfterText("output") or node.parent.isAfterText("output"):
          res.add text
    of xnComment:
      discard
    else:
      raise newException(ValueError, "Unsupported node kind " & $node.raw.kind)
  visit(wrap(root))
  res.join("\n")



when isMainModule:
  const rootDir = "questions"

  block:
    let src = readFile(rootDir / "weekly-contest-401" / "find-the-child-who-has-the-ball-after-k-seconds" / "source.html")
    doAssert extractOutput(src) == """
1
2
2
""".strip

  block:
    let src = readFile(rootDir / "weekly-contest-388" / "apple-redistribution-into-boxes" / "source.html")
    doAssert extractOutput(src) == """
2
4
""".strip

  block:
    let src = readFile(rootDir / "biweekly-contest-4" / "remove-vowels-from-a-string" / "source.html")
    doAssert extractOutput(src) == """
"ltcdscmmntyfrcdrs"
""
""".strip

  block:
    let src = readFile(rootDir / "biweekly-contest-8" / "before-and-after-puzzle" / "source.html")
    doAssert extractOutput(src) == """
["writing code rocks"]
["a chip off the old block party","a man on a mission impossible","a man on a mission statement","a quick bite to eat my words","chocolate bar of soap"]
["a"]
""".strip

  when true:
    for kind, path in walkDir(rootDir):
      if kind != pcDir: continue
      for kind, path in walkDir(path):
        if kind != pcDir: continue
        echo path
        let src = readFile(path / "source.html")
        let output = extractOutput(src)
        if output.strip.len == 0:
          raise newException(ValueError, "extraction failed")
        let gt = readFile(path / "outputGT.txt")
        doAssert output == gt

# biweekly-contest-20