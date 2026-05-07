392. Is Subsequence

Given two strings s and t, return true if s is a subsequence of t, or false otherwise.
A subsequence of a string is a new string that is formed from the original string by deleting some (can be none) of the characters without disturbing the relative positions of the remaining characters. (i.e., "ace" is a subsequence of "abcde" while "aec" is not).

Example 1:
Input: s = "abc", t = "ahbgdc"
Output: true

Example 2:
Input: s = "axc", t = "ahbgdc"
Output: false

追加ケース
Example 3:
- 同じ文字を含む場合
Input: s = "aac", t = "ahagdc"
Output: true

Constraints:
- 0 <= s.length <= 100
- 0 <= t.length <= 10^4
- s and t consist only of lowercase English letters.

Follow up: Suppose there are lots of incoming s, say s1, s2, ..., sk where k >= 10^9, and you want to check one by one to see if t has its subsequence. In this scenario, how would you change your code?

## Step1
Example1を例にする。
sの先頭から見ていく。tの中にs[0]=aがある。次にs[1]=bだが同じくtの中にある。そしてbはaより後に登場する。最後にs[2]=cもtの中に登場し、bより後に登場する。よって全ての文字が登場するかつ順番通りになっている。
上記の手順で考えると、以下のように一般化できる
- tの中に特定の文字があるかどうかを高速に計算するために、hashmapを構築する。値にはindexを入れておく。
- sを順に走査し、tの中でsが登場するインデックスを見るのだが、最初に、次回からはこれ以降を探すという目印を記録するために`search_from`という変数を用意しておく。tの中に一致する要素を見つけるたびに、そのインデックスで`search_from`を置き換える。
- 基本的に上記のアルゴリズムで解けるが、s, tの中に、同じ要素が存在する場合も考えないといけない（上記のExample 3）。hashmapはDict[char, list[int]]で構築する

18分ほど
一度 s="aza", t="abzba"のテストケースで間違えてしまった。内側のループを早期で抜けるのを忘れていた

Time: 最悪 O(S*T)
Space: O(T)
```py
class Solution:
    def isSubsequence(self, s: str, t: str) -> bool:
        char_to_indices = defaultdict(list)
        for i, c in enumerate(t):
            char_to_indices[c].append(i)
        
        search_from = 0
        num_matches = 0
        for c in s:
            if c not in char_to_indices:
                return False
            
            for index in char_to_indices[c]:
                if index >= search_from:
                    search_from = index + 1
                    num_matches += 1
                    # 早期に抜ける
                    break
        
        return num_matches == len(s)
```
おそらく上記の解法がFollow Upの回答になっているはず。つまり、毎回tを走査するわけではなく一度だけtを前処理し、各クエリだけ走査して回答がもとまること

🤖review
- 以下のチェックは、.get(c, [])を使うといらなくなる。`indices = char_to_indices.get(c, [])`. indicesが空の時、走査すべき`index`がなくなるので挙動は変わらない
```py
if c not in char_to_indices:
    return False
```
- 上記のコードは最悪 O(S*T)の計算量になってしまう。原因は`for index in char_to_indices[c]`で線形探索していること。この部分を二分探索にすればO(SlogT)に改善する。
前提：`char_to_index[c]`は単調増加のインデックス列。二分探索では、「search_from以上となる最初のindex」を探す。bisect_leftが使える。

```py
class Solution:
    def isSubsequence(self, s: str, t: str) -> bool:
        char_to_indices = defaultdict(list)
        for i, c in enumerate(t):
            char_to_indices[c].append(i)
        
        search_from = 0
        for c in s:
            if c not in char_to_indices:
                return False
            
            pos = bisect_left(char_to_indices[c], search_from)
            if pos == len(char_to_indices[c]):
                return False
            
            # search_from = index + 1とすると間違い
            search_from = char_to_indices[c][pos] + 1

        return True
```

💡 two pointerでもできるらしいのでやってみる
sの要素とtの要素が等しい時はポインタを両方進める。等しくない時は、見つかるまでtを走査したいのでtのポインタのみ更新する。
sのポインタは「今クエリとなっている文字」、tのポインタは「今ここまでは探したのでこれ以降を探す」ということを表している。

> 不変条件: s[0:s_ptr] は t[0:t_ptr] の subsequence として既に確認済み
不変条件から、ループ終了時に、s_ptr == len(s)なら全体がsubsequenceである。

Time: O(S + T)
Space: O(1)
```py
class Solution:
    def isSubsequence(self, s: str, t: str) -> bool:
        s_ptr = 0
        t_ptr = 0
        while s_ptr < len(s) and t_ptr < len(t):
            if s[s_ptr] == t[t_ptr]:
                s_ptr += 1
                t_ptr += 1
            
            else:
                t_ptr += 1
        
        return s_ptr == len(s)
```

🤖review
- elseを省略できる。一致してもしなくてもt_ptrは更新するため
- tの走査はfor文を使っても書ける

## Two pointerをどこで使うか
「2つのインデックスを単調に動かすだけで、各ステップの判断が局所的に決まる」構造のときに使う。鍵は**後戻りしない**こと。

成立条件:
1. **単調性**: ポインタを戻す必要がない。一方を進めると、もう一方を戻す意味がない。
2. **状態が局所的**: 各ステップの判断が「現在のポインタ位置」だけで決まる。
3. **線形で十分**: O(n^2)の総当たりをO(n)に落とせる構造。

典型パターン:
- ソート済み配列で2要素を探す (Two Sum II, 3Sum)
- 2つの列を同時に走査・比較・マージ (Is Subsequence, Merge Sorted Array)
- 両端から狭めていく (Container With Most Water, Valid Palindrome)
- Sliding window (Longest Substring Without Repeating)
- In-placeで配列を書き換える (Remove Duplicates, Move Zeroes)

使えないサイン:
- ハッシュが必要 (Two Sum 未ソート版)
- 後戻りが必要・状態が大域依存 (DPの領域)

Is Subsequenceがハマる理由:
- s, tを同方向に進めるだけ。tでスキップした文字は順序保存ゆえ二度と必要にならない（単調性）。
- 各ステップは `s[i] == t[j]` の局所判定のみ（局所性）。

## Follow upについての考察
Follow upの意図は「並行処理やストリーミング」ではなく、**tを前処理して各クエリを高速化する**こと。
tは固定でsだけが大量に来るので、共通部分tを使い回すのが本質。DBのインデックスと同じ発想。

| 解法 | 前処理 | クエリ毎 | 合計 |
|------|--------|---------|------|
| two pointer | なし | O(S+T) | k(S+T) |
| bisect | O(T) | O(S log T) | T + kS log T |

逆転点:
```
k(S+T) = T + kS log T
k = T / (S + T - S log T)
```

S=100, T=10^4, log2(T)≈13.3 を入れると:
- S log T ≈ 1330
- S + T = 10100
- 分母 = 10100 - 1330 = 8770
- k ≈ 10000 / 8770 ≈ 1.14

**k = 2 ですでに二分探索の方が速い**。直感的には、two pointerは毎回T全体を舐めるが、bisectは前処理でTを「圧縮」してクエリ毎にはS側だけ触るから。`S << T` の前提下でこの差が大きい。

| 解法 | Time | Space | 単発 | Follow up |
|------|------|-------|------|-----------|
| Step1 (linear) | 最悪 O(S*T) | O(T) | △ | △ |
| bisect | O(T + S log T) | O(T) | ○ | ◎ |
| two pointer | O(S+T) | O(1) | ◎ | × |

## Step2

### `t.find(c, start)` でネイティブC実装に処理を寄せる
[naoto-iwase#58](https://github.com/naoto-iwase/leetcode/pull/58)
```py
position = -1
for query in s:
    position = t.find(query, position + 1)
    if position == -1:
        return False
return True
```
こちらのコメントでも同じ発想:
- https://discord.com/channels/1084280443945353267/1201211204547383386/1231637671831408821
> これは、正規表現で s の文字のすべての間に .* を挟み込んで、マッチすればいいので、一回舐めれば解けそうですね。
> ...
> findの開始インデックスを指定すれば制約を組み込めた

計算量はO(S＊T)だが次の理由で高速になる
`str.find` はCで実装されたネイティブメソッドで、Pythonループでt_ptrを進めるより速いことが多い。「探索の開始位置を引数で渡せる」というAPIは覚えておく

関連: `str.rfind(sub, start, end)` は **末尾から検索**して最後にマッチする位置を返すAPI。`find` と対になる。`str.find` と同じく見つからない時は `-1`。範囲指定 `start, end` は両方ともサポート。Is Subsequenceでは `find` を使うが、「右側から最も近い位置」を取りたい問題（例: 末尾の特定パターン検出、文字列の末尾整形）で活きる。

#### CPythonでC実装されているもの
`str`, `list`, `dict`, `set` などの**組み込み型のメソッドはC実装**。Pythonでループを書くより、組み込みのCメソッドに処理を委譲するほうが10〜100倍速い。

判別の原則:
- **組み込み型メソッド**（`str.find`, `list.sort`, `dict.get`, `set.intersection` など）→ C実装
- **builtins**（`len`, `sum`, `min`, `max`, `sorted`, `map`, `filter`, `any`, `all`, `zip`, `enumerate` など）→ C実装
- **速度を売りにする標準ライブラリ**（`re`, `bisect`, `heapq`, `collections.deque/Counter`, `itertools`, `math`）→ C実装
- **抽象化系**（`functools`の一部, `typing`, `dataclasses` など）→ Python実装

| カテゴリ | API |
|---------|------|
| 文字列 | `find`, `rfind`, `split`, `join`, `replace`, `count`, `index`, `startswith`, `endswith` |
| リスト | `sort`, `index`, `count`, `reverse`, `extend` |
| 辞書/集合 | `get`, `setdefault`, `update`, `intersection`, `union` |
| 検索 | `bisect_left`, `bisect_right`, `insort` |
| キュー | `collections.deque` (`append`, `popleft` が O(1)) |
| 集計 | `Counter`, `sum`, `min`, `max` |
| ヒープ | `heapq.heappush`, `heappop` |
| 正規表現 | `re.match`, `re.search`, `re.findall` |

### 正規表現解
[tom4649#52](https://github.com/tom4649/Coding/pull/52) sol4.py
```py
pattern = ""
for c in s:
    pattern += ".*" + re.escape(c)
return re.match(pattern, t) is not None
```
> 正規表現で s の文字のすべての間に .* を挟み込んで、マッチすればいい

`re.escape` を忘れると `.` や `*` が含まれた時に壊れる点が学び。発想としてはエレガントだが、正規表現エンジンのオーバーヘッドで実測は遅い。

### Follow upのDP解（O(|s|) per query）
[mamo3gr#52](https://github.com/mamo3gr/arai60/pull/52#discussion_r2864553208)
> `index_and_char_to_index[t_index][ch]` = `t_index以降で直近で ch が現れるインデックス + 1` というテーブルを作ってあげると、 s の中の 1 文字あたりの処理の時間計算量が O(1) となり、 s 一つあたり O(|s|) となる

bisect版より一段速い (O(S log T) → **O(S)** per query)。前処理は **後ろから** O(T × 26) で構築するのがミソ。
> `t.find(ch, start)` のDPですね。

これは「`find`を毎回呼ばずに前計算」と捉えると分かりやすい。クエリ数が膨大なFollow upでは、前処理を重くしてもクエリ毎を最速にする方針が活きる。
```py
class Solution:
    def isSubsequence(self, s: str, t: str) -> bool:
        # next_appearance[i][c] = t[i:]で初めてcが現れるindex（なければキーなし）
        n = len(t)
        next_appearance = [{} for _ in range(n + 1)]
        for ch in set(t): # 最大O(26)
            nxt = -1
            for i in reversed(range(n)):
                if t[i] == ch:
                    nxt = i
                if nxt != -1:
                    next_appearance[i][ch] = nxt

        i = 0
        for ch in s:
            # O(1)
            nxt = next_appearance[i].get(ch, -1)
            if nxt == -1:
                return False
            i = nxt + 1
        return True
```

### bisectの参照値: `last_used_index` の自然な表現
[naoto-iwase#58](https://github.com/naoto-iwase/leetcode/pull/58#discussion_r...)
> last が、ある文字に関して最後にマッチした index になっていると読みましたが、単に直近の index で良いように思います。
```py
last_used_index = -1
for c in s:
    positions_in_t = self.char_to_positions.get(c)
    if positions_in_t is None:
        return False
    next_position_index = bisect.bisect_right(positions_in_t, last_used_index)
    if next_position_index == len(positions_in_t):
        return False
    last_used_index = positions_in_t[next_position_index]
return True
```
自分の実装では `search_from = index + 1` というオフセット管理をしていたが、`bisect_right(positions, last_used_index)` を使えば「**最後に使ったtのindex**」をそのまま保持でき、+1 を意識せずに済む。`bisect_left` vs `bisect_right` の使い分けで、状態の意味が変わる例。

### whileの内外で責務を分ける
[olsen-blue#58](https://github.com/olsen-blue/Arai60/pull/58)
```py
# パターンA: 無限ループで両方の終了条件をif/return
while True:
    if A: return B
    if C: return D
    ...

# パターンB: 主役の条件をwhileに掲げる
while not A:
    if C: return D
    ...
return B
```
> whileに掲げるものは主役であることが多い

主役が「残り処理がある間」「heapが非空である間」のような**ループ継続条件として表現できる場合**はパターンBが見通しが良い。BFS/Dijkstra/Primのように「キューに残っている間処理する」構造は典型。逆に2つのポインタが対称に動くIs Subsequenceでは、`while s_ptr < len(s) and t_ptr < len(t):` のように両条件が"主役"として並列にあるとも言える。

### early returnは制約次第で意味が薄れる
[tom4649#52](https://github.com/tom4649/Coding/pull/52)
> 制約を見ると、sは短めなので、early returnするメリットはあまりないかもしれません

`0 <= s.length <= 100` のような小さな制約下では、最後にまとめて `return s_index == len(s)` で十分。実測でもearly return版が遅い場合があった (sol3: 1710ms vs sol1: 1532ms)。Pythonでは分岐削減のほうが効くことがあるっぽい

### 命名: `char` は予約語衝突に注意
[naoto-iwase#58](https://github.com/naoto-iwase/leetcode/pull/58) / [olsen-blue#58](https://github.com/olsen-blue/Arai60/pull/58) で共通指摘
> Python には char 型はないため、_ を付ける必要はない。一方、他の言語だと型名として予約語になっているため、別の単語を用いたほうが無難。 c または ch あたりはいかが

### 関数型由来の再帰解
- https://discord.com/channels/1084280443945353267/1225849404037009609/1243290893671465080

Haskellの定義を素直にPythonに落とすと:
```py
def isSubsequence(self, s, t):
    if not s: return True
    if not t: return False
    if s[0] == t[0]:
        return self.isSubsequence(s[1:], t[1:])
    return self.isSubsequence(s, t[1:])
```
`s[1:]` のスライスはO(S)コピーが入るので、index版に置き換えると標準のtwo pointerに帰着する。**「再帰 ↔ ループ」の対応関係**が綺麗に見える例で、whileの無限ループ版もこれの直訳と捉えられる。

## Step3

`str.find`を使うパターン
```py
class Solution:
    def isSubsequence(self, s: str, t: str) -> bool:
        position = 0
        for ch in s:
            # position以降で初めてchが出てくる位置（なければ-1）
            index = t.find(ch, position)
            if index == -1:
                return False

            position = index + 1
        
        return True
```
Two Pointer
```py
class Solution:
    def isSubsequence(self, s: str, t: str) -> bool:
        s_index = 0
        t_index = 0
        # for t_index in range(len(t))でも良い
        while s_index < len(s) and t_index < len(t):
            if s[s_index] == t[t_index]:
                s_index += 1
            
            t_index += 1
        
        return s_index == len(s)
```

## 類題
- https://leetcode.com/problems/longest-common-subsequence/
- https://leetcode.com/problems/number-of-matching-subsequences/
- https://leetcode.com/problems/shortest-way-to-form-string/
- https://leetcode.com/problems/append-characters-to-string-to-make-subsequence/