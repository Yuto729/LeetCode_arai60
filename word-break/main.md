## Step1
Given a string `s` and a dictionary of strings `wordDict`, return true if s can be segmented into a space-separated sequence of one or more dictionary words.
Note that the same word in the dictionary may be reused multiple times in the segmentation.
 
Example 1:
Input: s = "leetcode", wordDict = ["leet","code"]
Output: true
Explanation: Return true because "leetcode" can be segmented as "leet code".

Example 2:
Input: s = "applepenapple", wordDict = ["apple","pen"]
Output: true
Explanation: Return true because "applepenapple" can be segmented as "apple pen apple".
Note that you are allowed to reuse a dictionary word.

Example 3:
Input: s = "catsandog", wordDict = ["cats","dog","sand","and","cat"]
Output: false
 
Example 4:
Input: s = "golila", wordDict = ["cats","dog","sand","and","cat"]
Output: false

Constraints:
- 1 <= s.length <= 300
- 1 <= wordDict.length <= 1000 = 10^3
- 1 <= wordDict[i].length <= 20
- s and wordDict[i] consist of only **lowercase English letters**.
- All the strings of wordDict are unique.

Approach
sを辞書にある単語できれいに分割できる組み合わせが１つでもあるかどうかを調べる
例3だと最初に見つけられるのがcat, catsの２択
- 文字を１つずつ見ていって、逐一単語を辞書で調べ、見つかったらそこで単語を区切る。
- catとcatsのように見つかってもまだ文字を進めるほうが良いケースがあるのでそれぞれの文字に対して単語に含めるか含めないかを選べる
- 辞書を最初の１文字とそれに対応する単語のhashmapにする
- sの中で新しい単語の区切りが開始されるたびに最初の１文字で候補を絞り、候補から外れるとすぐにfalseを返せばいい
=> 最初の１文字がわかれば単語の文字数の候補がわかるので、単語のスタートから文字数分インクリメントして単語が一致するか確認すればいいのでは
-> stackを用いる

40mくらいかかってしまった
- `visited`がないと一度訪れたposをもう一度訪れてしまうので無駄が発生する
- `char_to_words`のバリューを最初リストにするのを忘れていたためただしく索引が作れていなかった
- `pos + len(word)`が`s`の範囲ないにあるかどうかをチェックし忘れていた

時間計算量: O(n * |wordDict|)
```py
class Solution:
    def wordBreak(self, s: str, wordDict: List[str]) -> bool:
        if not s:
            return False

        char_to_words = defaultdict(list)
        for word in wordDict:
            char_to_words[word[0]].append(word)

        wordSet = set(wordDict)
        stack = [0]
        visited = set()
        while stack:
            pos = stack.pop()
            if pos == len(s):
                return True

            for word in char_to_words[s[pos]]:
                if pos + len(word) > len(s):
                    continue

                if s[pos: pos + len(word)] in wordSet:
                    if pos + len(word) in visited:
                        continue

                    stack.append(pos + len(word))
                    visited.add(pos + len(word))
                    continue

        return False
```
🤖
- `wordSet`は実はいらない。`if s[pos: pos + len(word)] == word`と比較すれば良い
- `pos` -> `start`, `start_index`
- ループ末尾のcontinueが不要
- 再帰+ `@cache`でも解ける

DPで解く
詰まった点
- forループの範囲
- 各所スライスのインデックス

時間計算量: O(n^2)
```py
class Solution:
    def wordBreak(self, s: str, wordDict: List[str]) -> bool:
        if not s:
            return False
        
        # dp[i] = s[0:i]が分割できるかどうかを表すbool配列
        wordSet = set(wordDict)
        dp = [False] * (len(s) + 1)
        for i in range(1, len(s) + 1):
            if s[:i] in wordSet:
                dp[i] = True
                continue

            for j in range(i):
                if dp[j] and s[j: i] in wordSet:
                    dp[i] = True
                    break
        
        return dp[len(s)]
```
🤖
- `dp` -> `breakable`, `segmentable`などが良さそう
- `segmented`は問題文中にあるのでそれをヒントに変数名とか考える
- `if s[:i] in wordSet`の分岐はいらない(j = 0のときなので)

follow up
- 形態要素解析とかに使いそう
- sの長さが10^6とかになったら？ -> DFSを用いる、wordDictの最大単語長が20なのですべてのjではなく、iから最大20まで戻ったjを探索することで計算量をO(n * 20)に抑えることができる
- Trie (前置木)を用いる方法がある

```py
class TrieNode:                                     
    def __init__(self):                               
        self.children = {}  # 文字 → TrieNode         
        self.is_end = False  # 単語の終端かどうか     
                                              
  構築例:                                               
                                                        
    root = TrieNode()                                     
    for word in ["cat", "cats"]:                          
    node = root                                       
    for char in word:                               
        if char not in node.children:               
            node.children[char] = TrieNode()          
        node = node.children[char]
    node.is_end = True                                
                                                      
  検索:                                               

    node = root                                           
    for char in "cat":
    if char not in node.children:                     
        break  # ← ここで打ち切れる                 
    node = node.children[char]                      
# node.is_end == True なら単語が存在
```

```py
for i in range(len(s) + 1):                           
    if not dp[i]:                                     
        continue                                      
    node = root                                     
    for j in range(i, len(s)):                        
        c = s[j]                                      
        if c not in node.children:                    
            break                                     
        node = node.children[c]                       
        if node.is_end:                               
            dp[j + 1] = True
```


## Step2

### 正規表現

[hayashi-ay#61](https://github.com/hayashi-ay/leetcode/pull/61)
> この問題、まず正規表現で書くことができるので O(n) で解けるはずとまず初めに考えました。

`wordDict = ["apple", "pen"]` なら `((apple)|(pen))*` という正規表現で表現できる。正規言語 = 有限オートマトンで認識できる言語であり、DFA型エンジンなら入力長 n に対して厳密に O(n)。

ただし、Pythonの `re` モジュールはバックトラック型エンジンのため、悪意ある入力でReDoS（Regular Expression Denial of Service）が発生しうる。ユーザー入力を正規表現に通す際は `re.escape` でエスケープが必須。安全性が必要な場合はDFA型の RE2 を使う。

---

### Priority Queue で "最遠インデックス優先" 探索

[Discord](https://discord.com/channels/1084280443945353267/1200089668901937312/1221781262109380699)
> priority queue を用意して、そこに数字 N が入っている場合は「先頭から N 文字目までの部分文字列は、wordDict の結合で表現できる」ということを意味する。初期値は [0]。

DFAとして設計すると
- 状態 = インデックス（0〜len(s)
- 遷移 = 単語1つ分のジャンプ
- 受理状態 = `len(s)`
max-heapで受理状態に近いインデックスを優先的に探索することで、早期に True を返せる可能性がある。ただし最悪計算量はDFS+visitedと同じ。

優先度のキーは **インデックス値（大きいほど優先）**
Pythonの`heapq`はmin-heapなので負値で扱う。

```python
import heapq

class Solution:
    def wordBreak(self, s: str, wordDict: List[str]) -> bool:
        wordSet = set(wordDict)
        heap = [0]          # max-heap（負値で管理）→ 初期状態: インデックス0
        visited = set()

        while heap:
            pos = -heapq.heappop(heap)  # 最も遠いインデックスを取り出す
            if pos == len(s):
                return True

            for word in wordDict:
                next_pos = pos + len(word)
                if next_pos <= len(s) and s[pos:next_pos] == word and next_pos not in visited:
                    visited.add(next_pos)
                    heapq.heappush(heap, -next_pos)  # 負値でpush

        return False
```

---

### Trie + Aho-Corasick

[hayashi-ay#61](https://github.com/hayashi-ay/leetcode/pull/61)

- 通常のTrieでは各posでO(max_word_len)のチェックが可能
- Aho-Corasickはfailure_linkを構成することでsを1回走査するだけで全マッチを検出できる。計算量 O(n + m)（nはs.length、mはworldDictの総文字数）
- 名称メモ: "PrefixTree" や "Trie" が正式名。"TrieTree" はRedundant

---

### `s[i:j]` のコストと `startswith` による最適化

[hayashi-ay#61](https://github.com/hayashi-ay/leetcode/pull/61)
> startswithの方が早期に打ち切れるので実際の処理的にはスライスの方が掛かりますね

`s[i:j]` はO(j-i)の文字列コピーを発生させる。`str.startswith(word, start)` を使うとコピーなしに比較でき、途中不一致で即打ち切れる。

```python
# Before
if s[pos:pos+len(word)] == word:

# After
if s.startswith(word, pos):
```

---

### 単語長の範囲でループを絞る

複数PRで言及
```python
word_min_len = min(len(w) for w in wordDict)
word_max_len = max(len(w) for w in wordDict)
# jの探索範囲を [i-max_word_len, i-min_word_len] に限定
```

またはwordDictに含まれる単語長のsetを作り、その長さのみチェックする方法もある。

---

### 変数命名

複数PRで指摘
- `is_word_break` → `breakable` or `segmented`（動詞形に見えるため）
- `dp` の意味が自明でない場合は `breakable` のような具体名が読みやすい

## Step3
DPで解いてみる
```py
class Solution:
    def wordBreak(self, s: str, wordDict: List[str]) -> bool:
        if not s:
            return False
        
        wordSet = set(wordDict)
        word_min_len = min([len(w) for w in wordDict])
        word_max_len = max([len(w) for w in wordDict])
        # dp[i] -> s[:i]が分割可能
        dp = [True] + [False] * len(s)
        for i in range(1, len(s) + 1):
            for j in range(max(0, i - word_max_len), i - word_min_len + 1):
                if dp[j] and s[j:i] in wordSet:
                    dp[i] = True
                    break
        
        return dp[len(s)]
```