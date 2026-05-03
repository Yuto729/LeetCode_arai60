Given an array nums of distinct integers, return all the possible permutations. You can return the answer in any order.

Example 1:
Input: nums = [1,2,3]
Output: [[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]

Example 2:
Input: nums = [0,1]
Output: [[0,1],[1,0]]

Example 3:
Input: nums = [1]
Output: [[1]]

Constraints:
- 1 <= nums.length <= 6
- -10 <= nums[i] <= 10
- All the integers of nums are unique.

## Step1
Approach
手作業でどうやるか考えてみる。樹形図をトレースするイメージ
EX. [1,2,3]
1. 1,2,3のどれから始めるか決める。一旦1とする
2. まだ訪れていないのは2か3なのでどちらかから選ぶ。2とする
3. まだ訪れていないのは3なので、3を選ぶ。[1,2,3]が組みとなりnumsの要素を網羅しているので1通り
4. ステップを1つ戻って、1の次に3を選ぶ。残りは2なので[1,3,2]が組み
5. 1 ~ 4を繰り返し、3で1~3を網羅 -> 2で1~3を網羅 -> 1で1~3を網羅。これで全ての組みがもとまる

```py
class Solution:
    def permute(self, nums: List[int]) -> List[List[int]]:
        # element of nums is distinct
        # len(nums) <= 6, nums[i] < 0もありうる
        # 計算量最大 -> 6 * 6!
        result = []
        def backtrack(start, visited, comb):
            if len(visited) == len(nums):
                result.append(comb)
                return

            for i in range(len(nums)):
                if i in visited:
                    continue
                
                visited.add(i)
                comb.append(nums[i])
                backtrack(i, visited, comb)

        visited = set()
        comb = []
        for i in range(len(nums)):
            visited.add(i)
            comb.append(nums[i])
            backtrack(i, visited, comb)
        
        return result
```

バックトラックのやり方を忘れていて、上記のコードを書いたがReject
ステップを１つ戻す部分を忘れていた。
正しく書き直す

- 時間計算量: O(n * n!) 深さ0でn通り, 1でn-1通り ... = n!。葉に到達するたびにO(n)で配列をコピーする。
- 空間計算量: O(n * n!) 再帰の深さO(n) + visited, comb変数 O(n) + result O(n * n!)
⚠️
忘れていたが、Pythonはデフォルト参照渡しなのでcombはグローバルに変更されている。スライスや `+`でリストを結合するときはshallow copy（要素の追加に対して元の配列は変更されないが、要素自体の変更は反映） < - > deep copy
```py
class Solution:
    def permute(self, nums: List[int]) -> List[List[int]]:
        # element of nums is distinct
        # len(nums) <= 6, nums[i] < 0もありうる
        # 計算量最大 -> 6!
        result = []
        def backtrack(visited, comb):
            if len(comb) == len(nums):
                # O(n)
                result.append(comb[:])
                return
                
            for i in range(len(nums)):
                if visited[i]:
                    continue
                
                visited[i] = True
                comb.append(nums[i])
                backtrack(visited, comb)
                visited[i] = False
                comb.pop()

        visited = [False] * len(nums)
        comb = []
        backtrack(visited, comb)

        return result
```

### 再帰をiterativeに直す

a. stackを使って再帰を自然に変換していく
時間計算量：O(n^2 * n!) -> forループの中で毎回stackに追加する際にコピーするから
空間計算量：O(n^3)
```py
class Solution:
    def permute(self, nums: List[int]) -> List[List[int]]:
        visited = [False] * len(nums)
        comb = []
        # stackの各要素 = 再帰の1フレーム = (visited, comb)
        stack = [(visited, comb)]
        result = []
        while stack:
            visited, comb = stack.pop()
            # base case: 葉に到達
            if len(comb) == len(nums):
                result.append(comb[:])
                continue

            # for ループの各iがstackへのpushに対応
            for i in range(len(nums)):
                if visited[i]:
                    continue

                # 再帰呼び出し直前の状態をスナップショットしてpushする. O(n + k)
                stack.append((visited[:i] + [True] + visited[i + 1: ], comb + [nums[i]]))

        return result
```
- 「引き継ぎ(numsの1番目は並べたので、あとは0番目と2番目をよろしく)」をスタックで表現したものと考える
- 計算量を落とす方法
    > 再帰をスタックに直すときにどうするかというので、箱に「これからしなきゃいけない内容の書かれた紙」を入れていって箱が空になったら終わりという説明をしたことがあります。
    https://discord.com/channels/1084280443945353267/1233603535862628432/1238707903196565546
    - アクションをスタックに積む
    - 再帰では、行きがけに状態（comb, visited）に値を追加、帰りがけに状態（comb, visited）を元に戻す。帰りがけの操作は「未来にやるべきアクション」なので命令としてスタックに積む。
    - stackに積まれているのは、「これから探索すべき分岐（try）」と「子の探索が終わったら実行すべき後処理（undo）」

O(n * n!)まで落とせる
空間計算量は、O(n^2) -> 各深さkで、未試行のtryがn - k - 1個あるので和はO(n 
^2)

```py
class Solution:
    def permute(self, nums: List[int]) -> List[List[int]]:
        n = len(nums)
        visited = [False] * n
        comb = []
        result = []
        # 命令：('try', i) = nums[i]を選ぶ / ('undo', i) = 戻す
        stack = [('try', i) for i in range(n - 1, -1, -1)]
        while stack:
            op, i = stack.pop()
            if op == 'undo':
                visited[i] = False
                comb.pop()
                continue
            
            if visited[i]:
                continue
            
            visited[i] = True
            comb.append(nums[i])
            if len(comb) == n:
                result.append(comb[:])
                visited[i] = False
                comb.pop()
                continue
            
            # 「子を全部処理した後にundo」をLIFOで実現
            # undoを先に積む -> 子のtryを後に積む -> popでは子が先に出る
            stack.append(('undo', i))
            for j in range(n - 1, -1, -1):
                if not visited[j]:
                    stack.append(('try', j))
        
        return result
```

b.　別のやり方 
順列を逐次的に作るときに、前のループ（作業）で何を保持していたら楽にできるか？
-> 長さが１つ短い順列が全て分かれば、各々に未使用要素を足して順列が新たに作れる

- 時間計算量: O(n*2 * n!)計算はよくわからない
- 空間計算量: O(n * n!)
```py
class Solution:
    def permute(self, nums: List[int]) -> List[List[int]]:
        permutations = [[]]
        for _ in range(len(nums)):
            next_permutations = []
            for p in permutations:
                for num in nums:
                    if num not in p:
                        next_permutations.append(p + [num])
            permutations = next_permutations
        
        return permutations
```
計算量を落とす方法
- `if num not in p`の線形探索、ループが毎回nums全体を走査する部分がボトルネック
上記に対して、各順列に未使用集合を持たせる方法
時間計算量：O(n * n!) -> 出力下限なのでこれ以上改善しない
```py
class Solution:
    def permute(self, nums: List[int]) -> List[List[int]]:
        states = [([], set(nums))]
        for _ in range(len(nums)):
            next_states = []
            for p, remaining in states:
                for num in remaining:
                    next_states.append((p + [num], remaining - {num}))
            states = next_states
        
        return [p for p, _ in states]
```


フォローアップ
- nums に重複がある場合は？（Permutations II） -> numsをソートした上で、各ループで同じ値が連続していて直前の同値が未使用のときスキップする

- n=6 の制約が外れて n=12 になったら 12!≈4.8億で厳しい。実用上どうする？ -> Generator, 枝刈り, 早期return

## Step2

### 未使用要素は set で管理して O(n) を削る
[Ryotaro25#54](https://github.com/Ryotaro25/leetcode_first60/pull/54#discussion_r1986035628)
> ここで nums で回すと計算量が少し悪くなりますが、そもそも重いので状況次第ですね。
> set で notused を持てばいいです。
> ただ、変更しながらループで回すことはできないので、コピーすることになります。それでも、最後の n はなくなります。

各再帰階層で `nums` 全体を走査して未使用判定すると、残り候補が `n - depth` 個しかないのに毎回 n 回ループする無駄が出る。`notused: set` を持ち回り、`for num in list(notused)` で回せば走査回数が `n - depth` に減って O(n²·n!) → O(n·n!) になる。`list()` でコピーするのは**反復中の mutation** を避けるため。

visitedも不要になるが、**全ての要素が異なることが前提**
setから要素を除く方法は以下の２つ
- set.remove -> 計算量: O(1), set自体を書き換える
- set - {x} -> 計算量: O(n) (copyするため)。iterative版ではこちらを使う

### `for x in collection` 中の mutation はライブ参照される
> コレクションオブジェクトの値を反復処理をしているときに、そのコレクションオブジェクトを変更するコードは理解するのが面倒になり得ます。

ポイント:
- `for x in ls:` は最初に1回だけ `iter(ls)` を作るが、そのイテレータは元コレクションを**ライブ参照**する → 反復中の mutation が挙動に反映される
- list は無音で挙動が変わる。dict/set は `RuntimeError: dictionary/set changed size during iteration` で落ちる
- 対策: スナップショット `for x in list(ls):` か `while ls: ls.pop()` の形に倒す
上記のset解法に関連

### 変数名は「形式」より「意味」でつける
[naoto-iwase#51](https://github.com/naoto-iwase/leetcode/pull/51#discussion_r2451700111)
> path や traverse_remainings は操作の形式からつけている名前で、操作の意味からつけると permutation_prefix や build_permutation のような感じになると思いました。

`path`（DFS的な「経路」という形式）より `permutation_prefix`（順列の途中状態という意味）の方がドメインに即していて読みやすい、というレビュー観点。形式から名付ける場合はコメントで意図を補足する。

### shallow / deep copy の境目
[mamo3gr#47](https://github.com/mamo3gr/arai60/pull/47#discussion_r2691193691)
> `permutation[:]` は permutationの shallow copy を返すように思います。`list[int]` は中の要素がimmutableなので、shallowでもdeepでも同じ結果になる。deep copy は中にmutableなものが入る時しか使わない。

整理:
- `result.append(permutation)` → 参照のコピー（外側もコピーされない）
- `result.append(permutation[:])` → shallow copy（外側は新規・中身は参照共有）
- `copy.deepcopy(permutation)` → 中までコピー

`list[int]` は**中身 immutable** なので shallow で十分。`list[list[int]]` などネストがある時に初めて deep が要る。

### swap でin-place backtracking → 空間 O(1)（出力除く）
[mamo3gr#47](https://github.com/mamo3gr/arai60/pull/47) の `permuteSwap`:
```python
def permute_from(start):
    if start == n: permutations.append(nums.copy())
    for i in range(start, n):
        nums[start], nums[i] = nums[i], nums[start]
        permute_from(start + 1)
        nums[start], nums[i] = nums[i], nums[start]
```
visited配列も comb配列も使わず、nums自体を書き換えて並び替える。作業空間は再帰スタック分のみで O(n)、visited等が不要なので定数倍も軽い。デメリットは入力を破壊すること（呼び出し前にコピーが必要なら結局 O(n)）と、出力順がソートされない点。

### 償却計算量（next_permutation関連）
[tom4649#53](https://github.com/tom4649/Coding/pull/53)
> ひっくり返すポイントを見つけるのに、自乗のオーダーがかかっているので、これの最悪計算量は O(n²) ですね。しかし、償却計算量を考えると、そうではなさそうです。長さ k がひっくり返る確率は ... ∑ k²/k! で上から抑えられるので定数時間。

next_permutation の1回呼び出しの**償却計算量は O(1)**。各位置がひっくり返る確率が k!ベースで急減衰し、期待値が ∑k²/k! → 2e で有界になるため。`list.append` のリアロケーションが倍々戦略で償却 O(1) なのと同じ構造。最悪 O(n) でも、全順列を列挙する文脈では1個あたり定数で済む。

---

## Step3
標準的な解法を練習する。回答を書いたら、コールスタックをトレースしながらどの順で順列がresultに追加されるか考える。

```py
class Solution:
    def permute(self, nums: List[int]) -> List[List[int]]:
        def backtrack(comb, visited):
            if len(comb) == len(nums):
                result.append(comb[:])
                return

            for i in range(len(nums)):
                if visited[i]:
                    continue
                    
                comb.append(nums[i])
                visited[i] = True
                backtrack(comb, visited)
                comb.pop()
                visited[i] = False
        
        comb = []
        visited = [False] * len(nums)
        result = []
        backtrack(comb, visited)
        return result
```

### コールスタックのトレース（nums=[1,2,3]）

インデント＝再帰の深さ。`★` で result.append。

```
backtrack([], [F,F,F])                          ← depth 0
│ i=0: visited[0]=T, comb=[1]
│ → backtrack([1], [T,F,F])                     ← depth 1
│   │ i=1: visited[1]=T, comb=[1,2]
│   │ → backtrack([1,2], [T,T,F])               ← depth 2
│   │   │ i=2: visited[2]=T, comb=[1,2,3]
│   │   │ → backtrack([1,2,3], [T,T,T])         ← depth 3
│   │   │   │ ★ result.append([1,2,3])         (1)
│   │   │   ← return
│   │   │ undo: comb=[1,2], visited[2]=F
│   │   ← return
│   │ undo: comb=[1], visited[1]=F
│   │ i=2: visited[2]=T, comb=[1,3]
│   │ → backtrack([1,3], [T,F,T])
│   │   │ i=1: comb=[1,3,2]
│   │   │ → backtrack([1,3,2], [T,T,T])
│   │   │   │ ★ result.append([1,3,2])         (2)
│   │   │   ← return
│   │   ← return
│   ← return
│ undo: comb=[], visited[0]=F
│ i=1: comb=[2]
│ → backtrack([2], [F,T,F])
│   │ i=0: comb=[2,1]
│   │ → backtrack([2,1], [T,T,F])
│   │   │ i=2: comb=[2,1,3] → ★ append([2,1,3])  (3)
│   │   ← return
│   │ i=2: comb=[2,3]
│   │ → backtrack([2,3], [F,T,T])
│   │   │ i=0: comb=[2,3,1] → ★ append([2,3,1])  (4)
│   │   ← return
│   ← return
│ i=2: comb=[3]
│ → backtrack([3], [F,F,T])
│   │ i=0: comb=[3,1] → … → ★ append([3,1,2])    (5)
│   │ i=1: comb=[3,2] → … → ★ append([3,2,1])    (6)
│   ← return
└ depth 0 終了
```

**追加順**: `[1,2,3] → [1,3,2] → [2,1,3] → [2,3,1] → [3,1,2] → [3,2,1]`

ポイント:
- 葉（depth=n）に到達したタイミングだけ result に追加
- `comb[:]` でスナップショットしないと、全要素が同じ参照になって最終的に空リスト6個になる
- undo（`pop` / `visited[i]=False`）は再帰から戻ってきた直後に実行 → これで状態が呼び出し前に復元される

## 類題
- [47. Permutations II](https://leetcode.com/problems/permutations-ii/)
- [78. Subsets](https://leetcode.com/problems/subsets/)
- [90. Subsets II](https://leetcode.com/problems/subsets-ii/)
- [39. Combination Sum](https://leetcode.com/problems/combination-sum/)
- [31. Next Permutation](https://leetcode.com/problems/next-permutation/)
- [60. Permutation Sequence](https://leetcode.com/problems/permutation-sequence/)