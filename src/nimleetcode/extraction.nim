import std/[
  htmlparser,
  os,
  sequtils,
  strutils,
  unicode,
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
  strutils.strip(node.raw.innerText, trailing = false).toLowerAscii.startsWith(text.toLowerAscii)

proc isAfterText(node: Node, text: string): bool =
  if node == nil or node.index == 0: return
  let parent = node.parent
  if parent == nil: return
  # echo (node.raw.kind, node.index, parent.raw.innerText)
  if parent.matchesText(text): return true
  if parent.children.len > 0:
    let prev = parent.children[node.index - 1]
    if prev.matchesText(text): return true

proc singleLine(text: string): string {.inline.} =
  text.split("\n").mapIt(unicode.strip(it)).join

proc firstLine(text: string): string {.inline.} =
  text.split("\n")[0]

proc extractList(text: string): string =
  var res = newSeq[char]()
  var d = 0
  for ch in text:
    if ch == '[': d += 1
    elif ch == ']': d -= 1
    res.add ch
    if d == 0: break
  res.join.singleLine

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
      let text = strutils.strip(node.text)
      if text.len > 0:
        if node.isAfterText("output") or node.parent.isAfterText("output"):
          if text.startsWith("["):
            res.add text.extractList
          else:
            res.add text.firstLine
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
    doAssert extractOutput(src) == strutils.strip("""
1
2
2
""")

  block:
    let src = readFile(rootDir / "weekly-contest-388" / "apple-redistribution-into-boxes" / "source.html")
    doAssert extractOutput(src) == strutils.strip("""
2
4
""")

  block:
    let src = readFile(rootDir / "biweekly-contest-4" / "remove-vowels-from-a-string" / "source.html")
    doAssert extractOutput(src) == strutils.strip("""
"ltcdscmmntyfrcdrs"
""
""")

  block:
    let src = readFile(rootDir / "biweekly-contest-8" / "before-and-after-puzzle" / "source.html")
    doAssert extractOutput(src) == strutils.strip("""
["writing code rocks"]
["a chip off the old block party","a man on a mission impossible","a man on a mission statement","a quick bite to eat my words","chocolate bar of soap"]
["a"]
""")

  block:
    let src = readFile(rootDir / "biweekly-contest-36" / "find-valid-matrix-given-row-and-column-sums" / "source.html")
    doAssert extractOutput(src) == strutils.strip("""
[[3,0],[1,7]]
[[0,5,0],[6,1,0],[2,0,8]]
""")

  block:
    let src = readFile(rootDir / "weekly-contest-257" / "gcd-sort-of-an-array" / "source.html")
    doAssert extractOutput(src) == strutils.strip("""
true
false
true
""")

  block:
    let src = readFile(rootDir / "weekly-contest-91" / "all-nodes-distance-k-in-binary-tree" / "source.html")
    doAssert extractOutput(src) == strutils.strip("""
[7,4,1]
[]
""")

  let skips: seq[string] = @[
  ]
  when true:
    for kind, path in walkDir(rootDir):
      if kind != pcDir: continue
      for kind, path in walkDir(path):
        if kind != pcDir: continue
        echo path
        if path in skips: continue
        let src = readFile(path / "source.html")
        let output = extractOutput(src)
        if strutils.strip(output).len == 0:
          raise newException(ValueError, "extraction failed")
        let gt = readFile(path / "outputGT.txt")
        doAssert output == gt, "Expected: |" & gt & "|, got |" & output & "|"

# biweekly-contest-110